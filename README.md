<h1>
  <img src="./moat/Assets.xcassets/AppIcon.appiconset/57.png">&nbsp;&nbsp;moat
</h1>

An iOS client for [newsboat](https://github.com/newsboat/newsboat).

## Setup
Install all dependencies
```bash
brew install cocoapods
pod install
```
and open `moat.xcworkspace` with Xcode. Connect your device and install with
<kbd>CMD</kbd> <kbd>R</kbd>.

Build and run the server
```bash
cargo run -- --help
```

### Newsboat `urls` file
The feeds that are shown in the app are determined by `~/.newsboat/urls` on
the server, an example entry is shown below.
```conf
# <rss url>                      <display url>                   <tag> <name>
https://news.ycombinator.com/rss "https://news.ycombinator.com/" "🔖"  "~Hacker News"
```
Feed names need to start with either `~` or `!`, read/unread status flags
are not processed for feeds that use a `!` name (these are considered "muted").
The tag field is unused by moat.

### Cross compile for aarch64
The server can be built for `aarch64-unknown-linux-musl` (Alpine) using
[Dockerfile.aarch64](/Dockerfile.aarch64).
```bash
docker build -f Dockerfile.aarch64 --rm  --tag=moat . &&
docker run --name=moat_builder -v `pwd`:/build -it moat
# => ./target/aarch64-unknown-linux-musl/release/moat_server
```

## Usage together with newsboat
Maintaining a synchronized state when using `newsboat` on another machine than
the moat server requires a wrapper function similar to the one below
```bash
newsmoat() {
  MOAT_SERVER="..."

  # Update the local cache with the cache from the moat server in
  # case articles were read through the iOS client
  rsync -q $MOAT_SERVER:~/.newsboat/cache.db ~/.newsboat/cache.db

  newsboat -r

  # Copy the cache and changes to other files back to the server on exit
  rsync -q ~/.newsboat/cache.db   $MOAT_SERVER:~/.newsboat/cache.db
  rsync -q ~/.newsboat/urls       $MOAT_SERVER:~/.newsboat/urls
}
```
This solution does **not** work if one were to use several 'newsboat clients'
in parallel. Newsboat was not modelled as a [client/server
application](https://github.com/newsboat/newsboat/issues/471) and pursuing a
more robust synchronization framework was therefore not deemed preferable.

## Additional notes
* The project was mainly modelled with YouTube feeds in mind and therefore
  supports fetching YouTube thumbnails and YouTube channel icons.

* Templates for Systemd (`/etc/systemd/system`) and OpenRC (`/etc/init.d`)
  services are available under [conf](/conf).

* The server process needs to be restarted for changes to the muted feeds to
  take-effect.

* Feeds that are removed from `urls` may need to be explicitly deleted from
  `cache.db` to not appear in the feed list,
  [moat_util.sh](/scripts/moat_util.sh) shows how this can be accomplished.

