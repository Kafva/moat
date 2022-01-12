// swift-tools-version:5.4.0
// ---> Dummy file for sourcekit-lsp linting <---
// (do not include into Xcode)
// SPM does not seem to be super well integrated into Xcode: https://stackoverflow.com/a/39796012/9033629
// so we will stick with Pods for now. E.g. This command does not read Packages.swift: 
//  xcodebuild -resolvePackageDependencies

import PackageDescription
let packageName = "moat"
let package = Package(
  name: "moat",
  defaultLocalization: "en",
  platforms: [.iOS("14.0") ],
  products: [
    .library(name: packageName, targets: [packageName])
  ],
  dependencies: [
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "3.0.0"),
  ],
  targets: [
    .target(
      name: packageName,
      dependencies: ["KeychainAccess"],
      path: packageName,
      exclude: ["Info.plist"]
    ),
  ]
)
