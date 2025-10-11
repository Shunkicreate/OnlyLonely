// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Package",
    defaultLocalization: "en",
    platforms: [
      .iOS(.v18)
    ],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/insidegui/MultipeerKit.git", from: "0.4.0")
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: ["MultipeerKit"],
            swiftSettings: [
              .swiftLanguageMode(.v5),
            ]
        ),
    ]
)
