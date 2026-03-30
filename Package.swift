// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WiFiAnalyzerPro",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "WiFiAnalyzerPro", targets: ["WiFiAnalyzerPro"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WiFiAnalyzerPro",
            dependencies: [],
            path: "Sources"
        )
    ]
)
