# moat
The project consists of an iOS client which interacts with an installation of [newsboat](https://github.com/newsboat/newsboat) through an intermediary server application, providing a view similar to the default newsboat CLI on iOS. By sharing the information in `~/.newsboat/cache.db` between the iOS client and newsboat itself, the 'read' status for items is kept synchronized. Maintaining a synchronized state when using `newsboat` on another machine than the `moat` server requires a wrapper function similar to the one below 
```bash
function newsmoat() {
	MOAT_SERVER="..."
	port="..."

	# Update the local cache with the cache from the moat server in
	# case articles were read through the iOS client
	scp -q $MOAT_SERVER:~/.newsboat/cache.db ~/.newsboat/cache.db 

	newsboat -r

	# Copy the cache back to the server on exit to commit any new changes
	scp -q ~/.newsboat/cache.db $MOAT_SERVER:~/.newsboat/cache.db	
}
```
This solution does **not** work if one were to use several 'newsboat clients' in parallel. Newsboat was not modelled as a [client/server application](https://github.com/newsboat/newsboat/issues/471) and pursuing a more robust synchronization framework was therefore not deemed preferable.

The project was mainly modelled with YouTube feeds in mind and therefore supports fetching YouTube thumbnails and YouTube channel icons. 

## Client setup
Install all dependencies
```bash
pod install
```
and open the `moat.xcworkspace` file with Xcode. Connect your device and install with `CMD+R`.


## Server setup
The server is configured through the `Rocket.toml` file and an application specific configuration file (example in `./conf/server.conf`). All endpoints on the server require a secret key (passed in the HTTP header `x-creds`) which is set in the environment on startup
```bash
MOAT_KEY="secret value" cargo run
```
Issuing `cargo run` will implicitly build the project.

### HTTPS
It is integral for the application to use HTTPS since the contents of the `x-creds` field need to be kept confidential. To setup HTTPS the server needs two files to be present at the root of the project: `./ssl/moat_server.crt` and `./ssl/moat_server.key`. The certificate needs to be signed by an entity that the iOS client trusts. 

Assuming that you do not have domain name and a corresponding certificate signed by a known CA, a private DNS server (e.g. [pihole](https://pi-hole.net/)) which the iOS device can use to resolve the domain name of the moat server can be used. 

One can then create a self-signed root certificate for the server and install the CA's certificate on the client by serving up the `.crt` file and opening it in Safari on the iOS device. To trust the certificate as a root authority go to *Settings > General > About > Certificate Trust Settings*, and toggle *Enable Full Trust for Root Certificates* on for the certificate as described [here](https://apple.stackexchange.com/a/371757/290763).

### Run as a service
A template for a systemd `.service` file is provided which can be copied to `~/.config/systemd/user` to interact with moat as any other service.

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
With [sourcekit-lsp](https://github.com/apple/sourcekit-lsp/) the autocomplete language features of Xcode become accessible to arbitrary text editors. VScode integration is available in the main sourcekit-lsp repository and a `.vsix` can be built and installed using the following commands

```bash
git clone https://github.com/apple/sourcekit-lsp.git
cd sourcekit-lsp/Editors/vscode/
npm run createDevPackage
code --install-extension out/sourcekit-lsp-vscode-dev.vsix
```

Next, add the following options to `settings.json`
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

The extension relies on the `Package.swift` file in the project but the actual build process does not use it, i.e. the `Package.swift` file is a stub with the sole purpose of enabling sourcekit-lsp!  


If packages imported through Cocoapods are not resolved it may be necessary to manually build the project using the `Package.swift` file with:

```bash
swift package reset && \
swift package update && \
swift build \
        -Xswiftc -sdk \
        -Xswiftc /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk \
        -Xswiftc -target \
        -Xswiftc x86_64-apple-ios14.5-simulator
```


