
import Foundation

let input =  URL(fileURLWithPath: ProcessInfo().arguments[1])
let output = URL(fileURLWithPath: ProcessInfo().arguments[2])

let filemanager = FileManager.default
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
