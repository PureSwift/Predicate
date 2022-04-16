// swift-tools-version:5.1
import PackageDescription

let libraryType: PackageDescription.Product.Library.LibraryType = .static

let package = Package(
    name: "Predicate",
    products: [
        .library(
            name: "Predicate",
            type: libraryType,
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
