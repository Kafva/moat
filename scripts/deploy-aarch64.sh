#!/bin/bash
exitErr(){ echo -e "$1" >&2 ; exit 1; }
usage="usage: $(basename $0) <host>"
helpStr="Build and deploy the server to a machine running aarch64 Arch Linux"

while getopts ":h" opt
do
	case $opt in
		h) exitErr "$usage\n-----------\n$helpStr" ;;
		*) exitErr "$usage" ;;
	esac
done

shift $(($OPTIND - 1))

[ -z "$1" ] && exitErr "$usage"

remote=$1

#----------------------------#

# Install and setup toolchain for aarch64 cross compiling
rustup target add aarch64-unknown-linux-gnu

# Install the corresponding C compiler
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


# Set the linker for the target to the the cross compiler and build the project
RUSTFLAGS="-C linker=/usr/bin/aarch64-linux-gnu-gcc-11.1.0" cargo build --release --target=aarch64-unknown-linux-gnu

# Copy over the binary and configuration files
sed "s@/home/jonas/.cargo/bin/cargo run --release --@/home/jonas/bin/moat_server@; s/CHANGE THIS/$(pass moat)/" ./moat.service > /tmp/moat_$remote.service

rsync ./target/aarch64-unknown-linux-gnu/release/moat_server $remote:~/bin/moat_server
rsync ./conf/server.conf 				     $remote:~/.newsboat/moat.conf
rsync /tmp/moat_$remote.service 		             $remote:~/.config/systemd/user/moat.service

# On deployment target
ssh $remote yay -Qi aarch64-glibc || echo 'The AUR build of glibc is required on the target: `yay -S aarch64-glibc`'
