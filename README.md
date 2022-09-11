<h1>
	<img src="./moat/Assets.xcassets/AppIcon.appiconset/57.png">&nbsp;&nbsp;moat
</h1>

* [Client setup](#client-setup)
* [Server setup](#server-setup)
	* [HTTPS](#https)
* [Development](#development)
	* [Import new images](#import-new-images)
	* [Linting](#linting)
* [Notes](#notes)

The application consists of an iOS client which interacts with an installation 
of [newsboat](https://github.com/newsboat/newsboat) through an 
intermediary server program, providing a view similar to the default 
newsboat CLI on iOS. By sharing the information in `~/.newsboat/cache.db` 
between the iOS client and newsboat itself, the *read* status for items is kept 
synchronized. 

## Client setup
Install all dependencies
```bash
brew install cocoapods
pod install
```
and open `moat.xcworkspace` with Xcode. Connect your device and install with 
<kbd>CMD</kbd> <kbd>R</kbd>.

## Server setup
The server is configured through the `Rocket.toml` file and an application 
specific configuration file (example in `./conf/server.conf`). All endpoints on 
the server require a secret key (passed in the HTTP header `x-creds`) which 
needs to be set in the environment on startup
```bash
MOAT_KEY="secret value" cargo run --release
```
Issuing `cargo run --release` will implicitly build the project.

### HTTPS
It is integral for the application to use HTTPS since the contents of 
the `x-creds` field need to be kept confidential. To setup HTTPS the server 
needs two files to be present at the root of the project: 

* `./ssl/server.crt`
* `./ssl/server.key` 

The certificate needs to be signed by an entity that the iOS client trusts.

Assuming that you do not have domain name and a corresponding certificate signed 
by a known CA, a private DNS server (e.g. [pihole](https://pi-hole.net/)) and CA 
can also be used. To install your own CA as a trusted root authority on iOS: 

1. Serve up the `.crt` from a machine and download it through Safari on the iOS device
2. This should give a prompt to install a profile for your CA
3. To trust the certificate as a root authority go to *Settings > General > About > Certificate Trust Settings*, and toggle *Enable Full Trust for Root Certificates* for the certificate as described [here](https://apple.stackexchange.com/a/371757/290763).

## Development

### Import new images
Instead of using the drag-and-drop functionality to import images through Xcode 
one can use the provided `getAsset.bash` script which takes an image as input 
and produces a `<image name>.imageset` resource under `Assets.xcassets`.

### Linting
* VScode: Use the `sswg.swift-lang` extension
* Neovim: refer to [this](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sourcekit) configuration

## Notes
Maintaining a synchronized state when using `newsboat` on another machine than 
the `moat` server requires a wrapper function similar to the one below 
```bash
function newsmoat() {
	MOAT_SERVER="..."

	# Update the local cache with the cache from the moat server in
	# case articles were read through the iOS client
	scp -q $MOAT_SERVER:~/.newsboat/cache.db ~/.newsboat/cache.db 

	newsboat -r

	# Copy the cache and changes to other files back to the server on exit 
	scp -q ~/.newsboat/cache.db 	$MOAT_SERVER:~/.newsboat/cache.db
	scp -q ~/.newsboat/urls 	$MOAT_SERVER:~/.newsboat/urls
	scp -q ~/.newsboat/muted_list   $MOAT_SERVER:~/.newsboat/muted_list
}
```
This solution does **not** work if one were to use several 'newsboat clients' in 
parallel. Newsboat was not modelled as a [client/server application](https://github.com/newsboat/newsboat/issues/471) 
and pursuing a more robust synchronization framework was therefore not deemed preferable.

The project was mainly modelled with YouTube feeds in mind and therefore 
supports fetching YouTube thumbnails and YouTube channel icons. 

A template for a systemd `.service` file is provided which can be copied to 
`/etc/systemd/system` to interact with moat as systemd service.
```bash
sudo systemctl status moat
```
