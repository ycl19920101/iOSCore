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
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
    ],
    targets: [
        .target(
            name: "iOSCore",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire")
            ],
            path: "iOSCore/iOSCore"
        ),
        .testTarget(
            name: "iOSCoreTests",
            dependencies: ["iOSCore"],
            path: "iOSCore/iOSCoreTests"
        ),
    ]
)
