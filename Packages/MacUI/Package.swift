// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MacUI",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(name: "MacUI", targets: [
            "BidiScrollView",
            "InspectorTabView",
            "Shortcut",
        ]),
        
        .library(name: "Shortcut", targets: ["Shortcut"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", from: Version(0, 55, 0)),
    ],
    targets: [
        .target(name: "BidiScrollView"),
        .target(name: "InspectorTabView"),
        
        .target(name: "Shortcut", resources: [.process("Resources")]),
        .testTarget(name: "ShortcutTests", dependencies: ["Shortcut"]),
    ],
    swiftLanguageVersions: [.v6]
)


for target in package.targets {
    target.plugins = [
        .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
    ]
}