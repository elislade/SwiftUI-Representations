// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIRepresentations",
    platforms: [.iOS(.v13), .macOS(.v11), .tvOS(.v12), .watchOS(.v4)],
    products: [
        .library(
            name: "RepresentationUtils",
            targets: ["RepresentationUtils"]
        ),
        .library(
            name: "UIKitRepresentations",
            targets: ["UIKitRepresentations"]
        ),
        .library(
            name: "PencilKitRepresentations",
            targets: ["PencilKitRepresentations"]
        ),
        .library(
            name: "QuickLookRepresentations",
            targets: ["QuickLookRepresentations"]
        ),
        .library(
            name: "MessagesRepresentations",
            targets: ["MessagesRepresentations"]
        ),
        .library(
            name: "SafariRepresentations",
            targets: ["SafariRepresentations"]
        ),
        .library(
            name: "PhotosRepresentations",
            targets: ["PhotosRepresentations"]
        ),
        .library(
            name: "PDFRepresentations",
            targets: ["PDFRepresentations"]
        ),
        .library(
            name: "AVKitRepresentations",
            targets: ["AVKitRepresentations"]
        ),
    ],
    targets: [
        .target(name: "RepresentationUtils"),
        .target(name: "QuickLookRepresentations"),
        .target(name: "PhotosRepresentations"),
        .target(name: "MessagesRepresentations"),
        .target(name: "SafariRepresentations"),
        .target(
            name: "UIKitRepresentations",
            dependencies: ["RepresentationUtils"]
        ),
        .target(name: "PencilKitRepresentations"),
        .target(
            name: "PDFRepresentations",
            dependencies: ["RepresentationUtils"]
        ),
        .target(name: "AVKitRepresentations"),
    ]
)
