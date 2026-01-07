// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Canopy",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Canopy",
            targets: ["Canopy"]
        ),
    ],
    targets: [
        .target(
            name: "Canopy",
            path: "Canopy/Sources"
        ),
    ]
)
