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
        print("tool pre build = \(tool.path)")
       
        return [
            .prebuildCommand(
                displayName: "PRE BUILD Copy all resources",
                executable: tool.path, // ⚠️ The tool is not yet build at pre-build and so the output of this build phase will be that it cannot find the tool
                arguments: [workingDirectory.string, input.string, output.string],
                outputFilesDirectory: workingDirectory),
            .buildCommand(
                displayName: "BUILD Hello from plug into file",
                executable: tool.path, // At this point the tool works and can be found
                arguments: [input.string, output.string],
                inputFiles: [input],
                outputFiles: [output]
            )
        ]
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
        
        print("""
        🔌 PluginContext
        
        \(context)
        
        🔌
        """)
        
        return try run(
            tool,
            workingDirectory: pluginWorkingDirectory,
            on: sourceFiles.map { $0.path }
        )
    }
}

extension XcodePluginContext: CustomStringConvertible {
    public var description: String {
        return """
        XcodePluginContext
        \(xcodeProject)
        
        pluginWorkDirectory:
        \(pluginWorkDirectory)
        """
    }
}

extension XcodeProjectPlugin.XcodeProject: CustomStringConvertible {
    public var description: String {
        return """
        ----
        XcodeProjectPlugin.XcodeProject
        \(displayName)
        \(directory.string)
        
        Filepaths:
        
        \(filePaths.map { $0.string }.joined(separator: "\n"))
        
        Targets:
        
        \(targets.map { $0.description }.joined(separator: "\n"))
        ----
        """
    }
}

extension XcodeProjectPlugin.XcodeTarget: CustomStringConvertible {
    public var description: String {
        return """
        ----
        XcodeProjectPlugin.XcodeTarget
        \(displayName)
        
        Product
        
        \(String(describing: product))
        
        InputFiles:
        
        \(inputFiles.map { "\($0.type) \($0.path.lastComponent)" }.joined(separator: "\n"))
        
        Dependencies:
        
        \(dependencies)
        ----
        """
    }
}
#endif


