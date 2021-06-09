// swift-tools-version:5.4.0
// Dummy file for sourcekit-lsp linting in an iOS project
//  https://medium.com/swlh/ios-development-on-vscode-27be37293fe1

import PackageDescription
let packageName = "Swive"
let package = Package(
  name: "Swive",
  defaultLocalization: "en",
  platforms: [.iOS("14.5")],
  products: [
    .library(name: packageName, targets: [packageName])
  ],
  targets: [
    .target(
      name: packageName,
      path: packageName,
      exclude: ["Info.plist"]
    ),
  ]
)