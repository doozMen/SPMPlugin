
import Foundation
import XcodeIssueReporting

@main
struct PluginMain {
  static func main() throws {
    XcodeIssue.report(XcodeIssue.warning("PluginMain is running", at: .sourceCodeFile(#file, line: #line)))
    
//    let input = URL(fileURLWithPath: "/fakePathToForceError")
    let input = URL(fileURLWithPath: ProcessInfo().arguments[1])
    let output = URL(fileURLWithPath: ProcessInfo().arguments[2])
    do {
      print("""
      🔌 plug is running
      - input: \(input)
      - output: \(output)
      """
      )

      let inputContent = String(data: try Data(contentsOf: input), encoding: .utf8)!
      let content = """
      /*
      Hello from plug into file, your file content was:
      \(inputContent)
      */
      """.data(using: .utf8)!

      try content.write(to: output)

      print("🔌 should have output at path: \(output.absoluteString)")

      exit(EXIT_SUCCESS)
    } catch {
      XcodeIssue.report(.error("\(error)", at: .sourceCodeFile(#file, line: #line)))
      // Don not throw the error as then xcode does not report it well
      exit(EXIT_FAILURE)
    }
    
  }
}
