# Swive



## Development

### Import new images
Instead of using the drag-and-drop functionality to import images through Xcode one can use the provided `getAsset.bash` script which takes an image as input and produces a `<image name>.imageset` resource under `Assets.xcassets`.

### Linting
To lint the project in VScode run:
```bash
brew install swiftlint
code --install-extension vknabel.vscode-swiftlint
```
and add the following options to `setttings.json`
```json
"swiftlint.enable": true,
"swiftlint.path": "/usr/local/bin/swiftlint",
"swiftlint.autoLintWorkspace": true,
"swiftlint.forceExcludePaths": [
    "tmp",
    "build",
    ".build",
    "Pods"
]
```

### Using `sourcekit-lsp` for linting in VScode
With [sourcekit-lsp](https://github.com/apple/sourcekit-lsp/) the autocomplete language features of Xcode are become accessible to arbitrary text editors. To integrate it with VScode download the sourcekit-lsp repository and build a `.vsix` manually

```bash
git clone https://github.com/apple/sourcekit-lsp.git
cd sourcekit-lsp/Editors/vscode/
npm run createDevPackage
code --install-extension out/sourcekit-lsp-vscode-dev.vsix
```

The extension relies on the `Package.swift` file in the project but the actual build process does not use it, i.e. the `Package.swift` file is a stub with the sole purpose of enabling sourcekit-lsp! Certain options in `settings.json` for VScode were found to be necessary:

```json
"swift.languageServerPath": "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
"sourcekit-lsp.serverPath": "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
"sourcekit-lsp.serverArguments": [
	"-Xswiftc",
	"-sdk",
	"-Xswiftc",
	"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk",
	"-Xswiftc",
	"-target",
	"-Xswiftc",
	"x86_64-apple-ios14.5-simulator"
]
```

If packages imported through Cocoapods are not resolved it may be necessary to manually build the project using the `Package.swift` file with:

```bash
swift package reset && \
swift package update && \
swift build \
        -Xswiftc -sdk \
        -Xswiftc /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk \
        -Xswiftc -target \
        -Xswiftc x86_64-aple-ios14.5-simulator
```
