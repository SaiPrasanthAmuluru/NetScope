// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NetScope",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "NetScope", targets: ["NetScope"]),
        .library(name: "NetScopeCore", targets: ["NetScopeCore"]),
        .library(name: "NetScopeURLSession", targets: ["NetScopeURLSession"]),
        .library(name: "NetScopeUI", targets: ["NetScopeUI"])
    ],
    targets: [
        .target(name: "NetScopeCore", dependencies: []),
        .target(name: "NetScopeURLSession", dependencies: ["NetScopeCore"]),
        .target(name: "NetScopeUI", dependencies: ["NetScopeCore"]),
        .target(
            name: "NetScope",
            dependencies: ["NetScopeCore", "NetScopeURLSession", "NetScopeUI"]
        )
    ]
)
