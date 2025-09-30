// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "Spamusement",
  platforms: [
    .macOS(.v12),
  ],
  dependencies: [
    .package(url: "https://github.com/loopwerk/Saga", from: "2.3.0"),
    .package(url: "https://github.com/loopwerk/SagaParsleyMarkdownReader", from: "1.0.0"),
    .package(url: "https://github.com/loopwerk/SagaSwimRenderer", from: "1.0.0"),
  ],
  targets: [
    .executableTarget(
      name: "Spamusement",
      dependencies: [
        "Saga",
        "SagaParsleyMarkdownReader",
        "SagaSwimRenderer",
      ]
    ),
  ]
)
