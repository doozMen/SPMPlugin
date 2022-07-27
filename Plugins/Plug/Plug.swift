import PackagePlugin
import Foundation

@main
struct Plug: BuildToolPlugin {
    enum Error: Swift.Error {
        case missingInput
    }
    
    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        guard let target = target as? SourceModuleTarget else {
            return []
        }
        let tool = try context.tool(named: "PluginMain")
        let sourceFiles = target.sourceFiles
        let pluginWorkDirectory = context.pluginWorkDirectory
        
        return try run(tool, workingDirectory: pluginWorkDirectory, on: sourceFiles.map { $0.path })
    }
    
    fileprivate func run(
        _ tool: PackagePlugin.PluginContext.Tool,
        workingDirectory: PackagePlugin.Path,
        on sourceFiles: [Path]
    ) throws -> [PackagePlugin.Command] {
        guard let input = (sourceFiles
            .first { $0.lastComponent == "Input.swift" }) else {
            throw Error.missingInput
        }
        let output = workingDirectory.appending(["Output.swift"])
        
        if !FileManager.default.fileExists(atPath: output.string) {
            FileManager.default.createFile(atPath: output.string, contents: nil)
            print("🔌 did create ouput file at \(output.string)")
        }
        return [
            .buildCommand(
                displayName: "Hello from plug into file",
                executable: tool.path,
                arguments: [input.string, output.string],
                inputFiles: [input],
                outputFiles: [output]
            )]
    }
}

    // https://developer.apple.com/forums/thread/707813
#if canImport(XcodeProjectPlugin)

import XcodeProjectPlugin

extension Plug: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        
        let tool = try context.tool(named: "PluginMain")
        let sourceFiles = target.inputFiles
        let pluginWorkingDirectory = context.pluginWorkDirectory
        
        return try run(
            tool,
            workingDirectory: pluginWorkingDirectory,
            on: sourceFiles.map { $0.path }
        )
    }
}

#endif
