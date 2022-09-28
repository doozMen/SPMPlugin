import PackagePlugin
import Foundation

@main
struct Plug: BuildToolPlugin {
  enum Error: Swift.Error {
    case missingInput
  }
  
  func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [Command] {
    guard let target = target as? SourceModuleTarget else {
      return []
    }
    let tool = try context.tool(named: "PluginMain")
    let sourceFiles = target.sourceFiles
    let pluginWorkDirectory = context.pluginWorkDirectory
    
    let output = pluginWorkDirectory.appending(["Output.swift"])
    let input = sourceFiles.first { $0.path.lastComponent == "Input.swift" }!
    
    return [
      .buildCommand(
        displayName: "🔌 SPM plug ran from definition in Package.swift",
        executable: tool.path,
        arguments: [input.path, output.string],
        inputFiles: [input.path],
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
    let output = context.pluginWorkDirectory.appending("Output.swift")
    let input = target.inputFiles.first { $0.path.lastComponent == "Input.swift" }!
    
    return [
      .buildCommand(
        displayName: "🔌 xcode plug ran from build phase",
        executable: try context.tool(named: "PluginMain").path,
        arguments: [input.path, output.string],
        inputFiles: [input.path],
        outputFiles: [output]
      )
    ]
    
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


