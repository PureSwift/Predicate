// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Predicate",
    products: [
        .library(
            name: "Predicate",
            targets: [
                "Predicate"
            ]
        )
    ],
    targets: [
        .target(
            name: "Predicate",
            path: "./Sources"
        ),
        .testTarget(
            name: "PredicateTests",
            dependencies: [
                "Predicate"
            ]
        )
    ]
)
