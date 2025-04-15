// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Stripper",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "stripper", targets: ["Stripper"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/ChimeHQ/SwiftTreeSitter", from: "0.9.0"),
        .package(url: "https://github.com/alex-pinkus/tree-sitter-swift", branch: "with-generated-files"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-c", branch: "master"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-cpp", branch: "master"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-javascript", branch: "master"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-typescript", branch: "master"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-python", branch: "master"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-ruby", branch: "master"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-go", branch: "master"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-rust", branch: "master"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.0")
    ],
    targets: [
        .executableTarget(
            name: "Stripper",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftTreeSitter", package: "SwiftTreeSitter"),
                .product(name: "SwiftTreeSitterLayer", package: "SwiftTreeSitter"),
                .product(name: "TreeSitterSwift", package: "tree-sitter-swift"),
                .product(name: "TreeSitterC", package: "tree-sitter-c"),
                .product(name: "TreeSitterCPP", package: "tree-sitter-cpp"),
                .product(name: "TreeSitterJavaScript", package: "tree-sitter-javascript"),
                .product(name: "TreeSitterTypeScript", package: "tree-sitter-typescript"),
                .product(name: "TreeSitterPython", package: "tree-sitter-python"),
                .product(name: "TreeSitterRuby", package: "tree-sitter-ruby"),
                .product(name: "TreeSitterGo", package: "tree-sitter-go"),
                .product(name: "TreeSitterRust", package: "tree-sitter-rust"),
                .product(name: "Rainbow", package: "Rainbow")
            ]
        ),
        .testTarget(
            name: "StripperTests",
            dependencies: ["Stripper"],
            path: "Tests/StripperTests"
        )
    ]
)
