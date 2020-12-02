#!/bin/sh
set -e -u

cargo build \
	--release \
	--bins \
	--target "${TARGET}"

if [ -z ${NOSTRIP+x} ]; then
	strip -s `find target/${TARGET}/release/ -type f -maxdepth 1 -executable`
else
	echo "Not stripping"
fi

if [ -z ${NOCOMPRESS+x} ] && [$TARGETPLATFORM = "linux/amd64"]; then
     upx --lzma --best `find target/${TARGET}/release/ -type f -maxdepth 1 -executable`
else
    echo "Not compressing"
fi


