#!/bin/bash

set -x

PkgName="qbittorrent-cli"
PkgDesc="qBittorrent remote command line client."
PkgVersion="${BUILD_BUILDNUMBER%.*}"
PkgIteration="${BUILD_BUILDNUMBER##*.}"
PkgLicense="MIT"
PkgVendor="Pavel Fedarovich"
PkgMaintainer="Pavel Fedarovich"
PkgHomepage="https://github.com/fedarovich/qbittorrent-cli"

###############################################################################
# Create packages for x64                                                     #
###############################################################################

set +x
echo '--------------------------------------------------------------------------'
echo '|                    Creating packages for x64                           |'
echo '--------------------------------------------------------------------------'
set -x

#prepare file system for .netcore3.1
PkgRoot="$BUILD_BINARIESDIRECTORY/build/x64"
mkdir -p "$PkgRoot/usr/bin"
mkdir -p "$PkgRoot/usr/lib/qbittorrent-cli"
tar -xvf "$BUILD_BINARIESDIRECTORY/tgz/cli/qbt-linux-x64-$BUILD_BUILDNUMBER.tar.gz" -C "$PkgRoot/usr/lib/qbittorrent-cli"
chmod +x "$PkgRoot/usr/lib/qbittorrent-cli/qbt"
ln -sfr "$PkgRoot/usr/lib/qbittorrent-cli/qbt" "$PkgRoot/usr/bin/qbt"

#build packages
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/xenial" && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a amd64 --description "$PkgDesc" -p "$_" -d libssl1.0.0 -d libicu55
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/bionic" && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a amd64 --description "$PkgDesc" -p "$_" -d libssl1.1 -d libicu60
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/focal"  && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a amd64 --description "$PkgDesc" -p "$_" -d libssl1.1 -d "libicu66 | libicu67"
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/groovy"  && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a amd64 --description "$PkgDesc" -p "$_" -d libssl1.1 -d libicu67
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/debian/any-version" && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a amd64 --description "$PkgDesc" -p "$_" -d libssl1.1 -d "libicu57 | libicu60 | libicu63 | libicu66 | libicu67 | libicu68"

mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/fedora/32"  && fpm -s dir -t rpm -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a x86_64 --description "$PkgDesc" -p "$_" -d openssl-libs -d libicu

mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/opensuse/15" && fpm -s dir -t rpm -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a x86_64 --description "$PkgDesc" -p "$_" -d libssl45 -d libicu
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/opensuse/tw" && fpm -s dir -t rpm -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a x86_64 --description "$PkgDesc" -p "$_" -d libssl50 -d libicu

#prepare file system for .net6
PkgRoot="$BUILD_BINARIESDIRECTORY/build/x64-net6"
mkdir -p "$PkgRoot/usr/bin"
mkdir -p "$PkgRoot/usr/lib/qbittorrent-cli"
tar -xvf "$BUILD_BINARIESDIRECTORY/tgz/cli/qbt-linux-x64-net6-$BUILD_BUILDNUMBER.tar.gz" -C "$PkgRoot/usr/lib/qbittorrent-cli"
chmod +x "$PkgRoot/usr/lib/qbittorrent-cli/qbt"
ln -sfr "$PkgRoot/usr/lib/qbittorrent-cli/qbt" "$PkgRoot/usr/bin/qbt"

#build packages
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/jammy"  && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a amd64 --description "$PkgDesc" -p "$_" -d libssl3 -d "libicu70 | libicu71"

###############################################################################
# Create packages for ARM                                                     #
###############################################################################

set +x
echo '--------------------------------------------------------------------------'
echo '|                    Creating packages for ARM                           |'
echo '--------------------------------------------------------------------------'
set -x

#prepare file system for .netcore3.1
PkgRoot="$BUILD_BINARIESDIRECTORY/build/arm"
mkdir -p "$PkgRoot/usr/bin"
mkdir -p "$PkgRoot/usr/lib/qbittorrent-cli"
tar -xvf "$BUILD_BINARIESDIRECTORY/tgz/cli/qbt-linux-arm-$BUILD_BUILDNUMBER.tar.gz" -C "$PkgRoot/usr/lib/qbittorrent-cli"
chmod +x "$PkgRoot/usr/lib/qbittorrent-cli/qbt"
ln -sfr "$PkgRoot/usr/lib/qbittorrent-cli/qbt" "$PkgRoot/usr/bin/qbt"

#build packages
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/xenial" && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a armhf --description "$PkgDesc" -p "$_" -d libssl1.0.0 -d libicu55
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/bionic" && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a armhf --description "$PkgDesc" -p "$_" -d libssl1.1 -d libicu60
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/focal"  && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a armhf --description "$PkgDesc" -p "$_" -d libssl1.1 -d "libicu66 | libicu67"
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/groovy"  && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a armhf --description "$PkgDesc" -p "$_" -d libssl1.1 -d libicu67
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/debian/any-version" && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a armhf --description "$PkgDesc" -p "$_" -d libssl1.1 -d "libicu57 | libicu60 | libicu63 | libicu66 | libicu67 | libicu68"

mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/fedora/32"  && fpm -s dir -t rpm -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a armv7hl --description "$PkgDesc" -p "$_" -d openssl-libs -d libicu

mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/opensuse/15" && fpm -s dir -t rpm -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a armv7hl --description "$PkgDesc" -p "$_" -d libssl45 -d libicu
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/opensuse/tw" && fpm -s dir -t rpm -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a armv7hl --description "$PkgDesc" -p "$_" -d libssl50 -d libicu

#prepare file system for .net6
PkgRoot="$BUILD_BINARIESDIRECTORY/build/arm-net6"
mkdir -p "$PkgRoot/usr/bin"
mkdir -p "$PkgRoot/usr/lib/qbittorrent-cli"
tar -xvf "$BUILD_BINARIESDIRECTORY/tgz/cli/qbt-linux-arm-net6-$BUILD_BUILDNUMBER.tar.gz" -C "$PkgRoot/usr/lib/qbittorrent-cli"
chmod +x "$PkgRoot/usr/lib/qbittorrent-cli/qbt"
ln -sfr "$PkgRoot/usr/lib/qbittorrent-cli/qbt" "$PkgRoot/usr/bin/qbt"

#build packages
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/jammy"  && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a armhf --description "$PkgDesc" -p "$_" -d libssl3 -d "libicu70 | libicu71"

###############################################################################
# Create packages for ARM 64                                                  #
###############################################################################

set +x
echo '--------------------------------------------------------------------------'
echo '|                    Creating packages for ARM64                         |'
echo '--------------------------------------------------------------------------'
set -x

#prepare file system for .netcore3.1
PkgRoot="$BUILD_BINARIESDIRECTORY/build/arm64"
mkdir -p "$PkgRoot/usr/bin"
mkdir -p "$PkgRoot/usr/lib/qbittorrent-cli"
tar -xvf "$BUILD_BINARIESDIRECTORY/tgz/cli/qbt-linux-arm64-$BUILD_BUILDNUMBER.tar.gz" -C "$PkgRoot/usr/lib/qbittorrent-cli"
chmod +x "$PkgRoot/usr/lib/qbittorrent-cli/qbt"
ln -sfr "$PkgRoot/usr/lib/qbittorrent-cli/qbt" "$PkgRoot/usr/bin/qbt"

#build packages
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/xenial" && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a arm64 --description "$PkgDesc" -p "$_" -d libssl1.0.0 -d libicu55
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/bionic" && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a arm64 --description "$PkgDesc" -p "$_" -d libssl1.1 -d libicu60
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/focal"  && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a arm64 --description "$PkgDesc" -p "$_" -d libssl1.1 -d "libicu66 | libicu67"
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/groovy"  && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a arm64 --description "$PkgDesc" -p "$_" -d libssl1.1 -d libicu67
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/debian/any-version" && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a arm64 --description "$PkgDesc" -p "$_" -d libssl1.1 -d "libicu57 | libicu60 | libicu63 | libicu66 | libicu67 | libicu68"

mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/fedora/32"  && fpm -s dir -t rpm -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a aarch64 --description "$PkgDesc" -p "$_" -d openssl-libs -d libicu

mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/opensuse/15" && fpm -s dir -t rpm -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a aarch64 --description "$PkgDesc" -p "$_" -d libssl45 -d libicu
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/opensuse/tw" && fpm -s dir -t rpm -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a aarch64 --description "$PkgDesc" -p "$_" -d libssl50 -d libicu

#prepare file system for .net6
PkgRoot="$BUILD_BINARIESDIRECTORY/build/arm64-net6"
mkdir -p "$PkgRoot/usr/bin"
mkdir -p "$PkgRoot/usr/lib/qbittorrent-cli"
tar -xvf "$BUILD_BINARIESDIRECTORY/tgz/cli/qbt-linux-arm64-net6-$BUILD_BUILDNUMBER.tar.gz" -C "$PkgRoot/usr/lib/qbittorrent-cli"
chmod +x "$PkgRoot/usr/lib/qbittorrent-cli/qbt"
ln -sfr "$PkgRoot/usr/lib/qbittorrent-cli/qbt" "$PkgRoot/usr/bin/qbt"

#build packages
mkdir -p "$BUILD_BINARIESDIRECTORY/pkg/ubuntu/jammy"  && fpm -s dir -t deb -f -C "$PkgRoot" --name $PkgName --version $PkgVersion --iteration $PkgIteration --license "$PkgLicense" --vendor "$PkgVendor" --maintainer "$PkgMaintainer" --url "$PkgHomepage" -a arm64 --description "$PkgDesc" -p "$_" -d libssl3 -d "libicu70 | libicu71"

###############################################################################
# Clean up                                                     #
###############################################################################
pushd "$BUILD_BINARIESDIRECTORY"
rm -rf tgz/* build/*
popd

set +x
