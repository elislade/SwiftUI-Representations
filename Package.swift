// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIRepresentations",
    platforms: [.iOS(.v14), .macOS(.v11), .tvOS(.v12), .watchOS(.v4)],
    products: [
        .library(
            name: "ExampleRepresentations",
            targets: ["ExampleRepresentations"]
        ),
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
            name: "PDFKitRepresentations",
            targets: ["PDFKitRepresentations"]
        ),
        .library(
            name: "AVKitRepresentations",
            targets: ["AVKitRepresentations"]
        ),
        .library(
            name: "SceneKitRepresentations",
            targets: ["SceneKitRepresentations"]
        ),
        .library(
            name: "MapKitRepresentations",
            targets: ["MapKitRepresentations"]
        ),
        .library(
            name: "WebKitRepresentations",
            targets: ["WebKitRepresentations"]
        ),
        .library(
            name: "HostedCollectionRepresentation",
            targets: ["HostedCollectionRepresentation"]
        )
    ],
    targets: [
        .target(
            name: "ExampleRepresentations",
            dependencies: [
                "RepresentationUtils", "QuickLookRepresentations", "PhotosRepresentations",
                "MessagesRepresentations", "SafariRepresentations", "PencilKitRepresentations",
                "PDFKitRepresentations", "AVKitRepresentations", "SceneKitRepresentations",
                "MapKitRepresentations", "WebKitRepresentations", "UIKitRepresentations",
                "HostedCollectionRepresentation"
            ]
        ),
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
            name: "PDFKitRepresentations",
            dependencies: ["RepresentationUtils"]
        ),
        .target(name: "AVKitRepresentations"),
        .target(
            name: "SceneKitRepresentations",
            dependencies: ["RepresentationUtils"]
        ),
        .target(
            name: "MapKitRepresentations",
            dependencies: ["RepresentationUtils"]
        ),
        .target(
            name: "WebKitRepresentations",
            dependencies: ["RepresentationUtils"]
        ),
        .target(
            name: "HostedCollectionRepresentation",
            dependencies: ["RepresentationUtils"]
        )
    ]
)
