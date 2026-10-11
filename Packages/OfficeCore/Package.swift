// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OfficeCore",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [.library(name: "OfficeCore", targets: ["OfficeCore"])],
    dependencies: [.package(url: "https://github.com/Slaymish/HamishNativeLibrary.git", .upToNextMinor(from: "0.2.0"))],
    targets: [
        .target(name: "OfficeCore", dependencies: [.product(name: "NativeCore", package: "HamishNativeLibrary")]),
        .testTarget(name: "OfficeCoreTests", dependencies: ["OfficeCore"]),
    ]
)
