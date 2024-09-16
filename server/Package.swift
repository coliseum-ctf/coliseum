// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Coliseum",
  platforms: [
    .macOS(.v12),
  ],
  products: [
    .library(
      name: "Coliseum-Auth",
      targets: ["Auth"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.105.0"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.11.0"),
    .package(url: "https://github.com/vapor/jwt.git", from: "4.2.0"),
    .package(url: "https://github.com/vapor/redis.git", from: "4.11.0"),
    .package(url: "https://github.com/apple/swift-crypto", from: "3.0.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "Auth",
      dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .product(name: "JWT", package: "jwt"),
        .product(name: "Redis", package: "redis"),
        .product(name: "Crypto", package: "swift-crypto"),
      ]
    ),
    .testTarget(
      name: "AuthTests",
      dependencies: [
        .target(name: "Auth"),
      ]),
    .executableTarget(
      name: "App",
      dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .product(name: "Fluent", package: "fluent"),
        .product(name: "Logging", package: "swift-log"),
        .target(name: "Auth"),
      ]
    ),
    .testTarget(
      name: "AppTests",
      dependencies: [
        .target(name: "App"),
      ])
  ]
)
