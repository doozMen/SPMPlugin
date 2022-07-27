// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SPMPlugin",
    products: [
        .plugin(name: "Plug", targets: ["Plug"]),
        .library(name: "PlugedTarget", targets: ["PlugedTarget"])
    ],
    dependencies: [],
    targets: [
        .plugin(
            name: "Plug",
            capability: .buildTool(),
            dependencies: ["PluginMain"]
        ),
        .executableTarget(name: "PluginMain"),
        
        .target(name: "PlugedTarget", plugins: ["Plug"]),

    ]
)
