// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SPMPlugin",
    products: [
        .plugin(name: "Plug", targets: ["Plug"]),
        .library(name: "PlugedTarget", targets: ["PlugedTarget"])
    ],
    dependencies: [
      .package(url: "https://github.com/jhonatn/XcodeIssueReporting.git", from: "1.4.1")
    ],
    targets: [
        .plugin(
            name: "Plug",
            capability: .buildTool(),
            dependencies: [
              .target(name: "PluginMain")
            ]
        ),
        .executableTarget(
          name: "PluginMain",
          dependencies: [.product(name: "XcodeIssueReporting", package: "XcodeIssueReporting")]
        ),
        .target(name: "PlugedTarget", plugins: ["Plug"]),

    ]
)
