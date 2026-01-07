// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Canopy",
    version: "0.1.0",
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
            path: "Sources",
            exclude: ["AppDelegate.swift", "SceneDelegate.swift", "ViewController.swift"]
        ),
    ]
)
