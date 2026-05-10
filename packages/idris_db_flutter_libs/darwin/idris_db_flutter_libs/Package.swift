// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "idris_db_flutter_libs",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "isar-plus-flutter-libs",
            targets: ["idris_db_flutter_libs"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "IsarPlusCore",
            url: "https://github.com/ahmtydn/idris_db/releases/download/0.0.0-placeholder/IsarPlusCore.xcframework.zip",
            checksum: "0000000000000000000000000000000000000000000000000000000000000000"
        ),
        .target(
            name: "CIsarCore",
            dependencies: ["IsarPlusCore"],
            path: "Core"
        ),
        .target(
            name: "idris_db_flutter_libs",
            dependencies: ["CIsarCore"],
            path: "Plugin"
        ),
    ]
)
