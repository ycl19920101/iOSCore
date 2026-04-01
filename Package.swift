// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "iOSCore",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "iOSCore",
            targets: ["iOSCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "2.0.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.0"),
    ],
    targets: [
        .target(
            name: "iOSCore",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
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
