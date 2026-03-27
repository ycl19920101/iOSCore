// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "iOSCore",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "iOSCore",
            targets: ["iOSCore"]
        ),
    ],
    dependencies: [
        // 外部依赖，例如：
        // .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.0"),
    ],
    targets: [
        .target(
            name: "iOSCore",
            dependencies: [],
            path: "iOSCore/iOSCore"
        ),
        .testTarget(
            name: "iOSCoreTests",
            dependencies: ["iOSCore"],
            path: "iOSCore/iOSCoreTests"
        ),
    ]
)
