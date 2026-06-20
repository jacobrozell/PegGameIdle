// swift-tools-version: 5.9
import PackageDescription

// Pure domain logic lives in a SwiftPM package so it can be unit-tested on CI
// (including Linux) with no simulator. The iOS app target (see project.yml)
// depends on this package.
let package = Package(
    name: "PegGameDomain",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(name: "PegGameDomain", targets: ["PegGameDomain"]),
    ],
    targets: [
        .target(name: "PegGameDomain"),
        .testTarget(
            name: "PegGameDomainTests",
            dependencies: ["PegGameDomain"]
        ),
    ]
)
