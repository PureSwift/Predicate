// swift-tools-version:5.0
import PackageDescription

#if os(Linux)
let libraryType: PackageDescription.Product.Library.LibraryType = .dynamic
#else
let libraryType: PackageDescription.Product.Library.LibraryType = .static
#endif

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
