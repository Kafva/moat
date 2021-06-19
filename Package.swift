// swift-tools-version:5.4.0
// Dummy file for sourcekit-lsp linting in an iOS project
//  https://medium.com/swlh/ios-development-on-vscode-27be37293fe1

// For linting to work with external packages we need to add them into this file as well, the LSP does not
// know about anything outside this file. It may be necessary to compile the project using the `swift`
// executable if dependencies are not resolved
//  https://forums.swift.org/t/sourcekitd-no-such-module-error/18321/14

//  swift package update && \
//  swift build \
//          -Xswiftc -sdk \
//          -Xswiftc /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk \
//          -Xswiftc -target \
//          -Xswiftc x86_64-aple-ios14.5-simulator

// The flags to `swift build` are the same ones needed for the `sourcekit-lsp.serverArguments` key settings.json in VScode

// Note that it should not matter what method is used to fetch the dependency in question for the actual project, i.e. it should work to use both CocoaPods and the built in SPM in Xcode from `File > Swift Packages > Add Package Dependency...`

import PackageDescription
let packageName = "Swive"
let package = Package(
  name: "Swive",
  defaultLocalization: "en",
  platforms: [.iOS("14.5") ],
  products: [
    .library(name: packageName, targets: [packageName])
  ],
  dependencies: [
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "3.0.0"),
    .package(url: "https://github.com/yahoojapan/SwiftyXMLParser.git", from: "5.3.0")
  ],
  targets: [
    .target(
      name: packageName,
      dependencies: ["KeychainAccess", "SwiftyXMLParser"],
      path: packageName,
      exclude: ["Info.plist"]
    ),
  ]
)
