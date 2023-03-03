<h1>
  <img src="./moat/Assets.xcassets/AppIcon.appiconset/57.png">&nbsp;&nbsp;moat
</h1>

An iOS client for [newsboat](https://github.com/newsboat/newsboat).

## Setup
Install all dependencies for the client
```bash
brew install cocoapods
pod install
```
and open `moat.xcworkspace` with Xcode. Connect your device and install with
<kbd>CMD</kbd> <kbd>R</kbd>.

Refer to:
```bash
cargo run -- --help
```
for information on how to run the server.

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
    [ -z "$MOAT_SERVER" ] && return -1
    # XXX the rsync user needs rwx access to /srv/moat/.newsboat
    local rflags=(-q --perms --chmod 666)

    # Update the local db with the db from the remote server in
    # case articles were read through the iOS client.
    rsync ${rflags[@]} $MOAT_SERVER:/srv/moat/.newsboat/cache.db  ~/.newsboat

    # Update the urls on the server
    rsync ${rflags[@]} $(readlink ~/.newsboat/urls)  $MOAT_SERVER:/srv/moat/.newsboat/urls

    newsboat -r 2> /dev/null

    # Copy back the potentially changed cache on exit
    rsync ${rflags[@]}  ~/.newsboat/cache.db         $MOAT_SERVER:/srv/moat/.newsboat
}
```
This solution does **not** work if one were to use several 'newsboat clients'
in parallel. Newsboat was not modelled as a [client/server
application](https://github.com/newsboat/newsboat/issues/471) and pursuing a
more robust synchronization framework was therefore not deemed preferable.

## Additional notes
* Tested to work with Newsboat 2.30.1

* The project was mainly modelled with YouTube feeds in mind and therefore
  supports fetching YouTube thumbnails and YouTube channel icons.

* A template to run moat as an OpenRC service is available under [conf](/conf).

* The server process needs to be restarted for changes to the muted feeds to
  take-effect.

* Feeds that are removed from `urls` may need to be explicitly deleted from
  `cache.db` to not appear in the feed list,
  [moat_util.sh](/scripts/moat_util.sh) shows how this can be accomplished.

