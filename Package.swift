// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Keyboardy",
    platforms: [
        .iOS(.v8),
    ],
    products: [
        .library(
            name: "Keyboardy",
            targets: ["Keyboardy"]),
    ],
    targets: [
        .target(
            name: "Keyboardy",
            path: "Pod"),
    ]
)
