#!/bin/sh
die(){ printf "$1\n" >&2 ; exit 1; }
usage="usage: $(basename $0) <host>"
helpStr="Build and deploy the server to a machine running aarch64 Arch Linux"

while getopts ":h" opt
do
	case $opt in
		h) die "$usage\n-----------\n$helpStr" ;;
		*) die "$usage" ;;
	esac
done

shift $(($OPTIND - 1))

[ -z "$1" ] && die "$usage"
[ $(uname) != Linux ] && die "Run on Linux"

remote=$1

#----------------------------#

# Install and setup toolchain for aarch64 cross compiling
rustup target add aarch64-unknown-linux-gnu

# Install the corresponding C compiler
# apt install gcc-aarch64-linux-gnu -y
pacman -Qi aarch64-linux-gnu-gcc &> /dev/null || 
	pacman -S aarch64-linux-gnu-gcc

if ! [ -f  "/usr/aarch64-linux-gnu/lib/libsqlite3.so.0.8.6" ]; then
	# C libraries for the architechture are found under  /usr/aarch64-linux-gnu/lib/
	# We need the sqlite3 library, the easiest way of fixing this is to download it from
	#	http://mirror.archlinuxarm.org/aarch64/core/sqlite-3.36.0-1-aarch64.pkg.tar.xz
	# and manually copy over the finished executable
	wget http://mirror.archlinuxarm.org/aarch64/core/sqlite-3.36.0-1-aarch64.pkg.tar.xz -O /tmp/sqlite3.pkg.tar.xz && 
	xz -d /tmp/sqlite3.pkg.tar.xz &&
	tar xf /tmp/sqlite3.pkg.tar -C /tmp 

	sudo cp /tmp/usr/lib/libsqlite3.so.0.8.6 /usr/aarch64-linux-gnu/lib
	sudo ln -s /usr/aarch64-linux-gnu/lib/libsqlite3.so.0.8.6 /usr/aarch64-linux-gnu/lib/libsqlite3.so
	sudo ln -s /usr/aarch64-linux-gnu/lib/libsqlite3.so.0.8.6 /usr/aarch64-linux-gnu/lib/libsqlite3.so.0
fi


sed "s@SET WORK DIR@${PWD%%/scripts}@; s/CHANGE THIS/$(pass moat)/" ./conf/moat.service > /tmp/moat_$remote.service

[ -d ssl ] && $(ssh $remote '[ -d ~/Repos/moat ]') && 
	rsync -r ssl 	$remote:~/Repos/moat/ ||
	echo "Server .crt and .key still need to be added on the server"

# The glibc version on the target must match the machine compiling the project
glibc_local=$(ldd --version | head -n1)
glibc_remote=$(ssh $remote ldd --version | head -n1)

if [ "$glibc_remote" != "$glibc_local" ]; then
	echo "--------------------------------------" >&2
	printf "Version mismatch for glibc!\nremote:\t$glibc_remote\nlocal:\t$glibc_local\n" >&2
	printf "Compile directly on the target machine.\n" >&2
	echo "--------------------------------------" >&2
else
	# Only create a cross compiled binary if the glibc versions matched
	RUSTFLAGS="-C linker=/usr/bin/aarch64-linux-gnu-gcc" \
		cargo build --release --target=aarch64-unknown-linux-gnu &&

	sed -i "s@/home/jonas/Repos/moat/target/release/moat_server@/home/jonas/bin/moat_server@;" \
		/tmp/moat_$remote.service
	rsync ./target/aarch64-unknown-linux-gnu/release/moat_server $remote:~/bin/moat_server
fi

rsync /tmp/moat_$remote.service $remote:/tmp/moat.service
rsync ./conf/server.conf 	$remote:~/.newsboat/moat.conf

ssh $remote 'sudo mv /tmp/moat.service /etc/systemd/system'
