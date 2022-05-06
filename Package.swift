// swift-tools-version:5.1
import PackageDescription
import class Foundation.ProcessInfo

// force building as dynamic library
let dynamicLibrary = ProcessInfo.processInfo.environment["SWIFT_BUILD_DYNAMIC_LIBRARY"] != nil
let libraryType: PackageDescription.Product.Library.LibraryType? = dynamicLibrary ? .dynamic : nil

var package = Package(
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

// SwiftPM command plugins are only supported by Swift version 5.6 and later.
#if swift(>=5.6)
let buildDocs = ProcessInfo.processInfo.environment["BUILDING_FOR_DOCUMENTATION_GENERATION"] != nil
if buildDocs {
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ]
}
#endif
