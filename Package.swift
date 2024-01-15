// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-gpio",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GPIO",
            targets: ["GPIO"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-system", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GPIO",
            dependencies: [
                .product(name: "SystemPackage", package: "swift-system"),
                "CGPIO"
            ]
        ),
        .target(name: "CGPIO"),

        .testTarget(
            name: "GPIOTests",
            dependencies: ["GPIO"]),
    ]
)
