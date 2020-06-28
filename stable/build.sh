#!/bin/sh
set -e -u

cargo build \
	--release \
	--bins \
	--target x86_64-unknown-linux-musl

if [ -z ${NOSTRIP+x} ]; then
	strip -s `find target/x86_64-unknown-linux-musl/release/ -type f -maxdepth 1 -executable`
else
	echo "Not stripping"
fi

if [ -z ${NOCOMPRESS+x} ]; then
     upx --lzma --best `find target/x86_64-unknown-linux-musl/release/ -type f -maxdepth 1 -executable`
else
    echo "Not compressing"
fi


