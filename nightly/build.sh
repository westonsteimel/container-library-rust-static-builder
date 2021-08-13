#!/bin/sh
set -e -u

case $TARGETPLATFORM in
    "linux/amd64")
        RUST_TARGET="x86_64-unknown-linux-musl"
        break
        ;;
    "linux/arm64")
        RUST_TARGET="aarch64-unknown-linux-musl"
        break
        ;;
    "*")
        echo "${TARGETPLATFORM} is not currently supported"
        exit 1
        ;;
esac

echo "Rust target: ${RUST_TARGET}"

cargo build \
	--release \
	--bins \
	--target "${RUST_TARGET}"

if [ -z ${NOSTRIP+x} ]; then
	strip -s `find target/${RUST_TARGET}/release/ -type f -maxdepth 1 -executable`
else
	echo "Not stripping"
fi

if [ -z ${NOCOMPRESS+x} ] && [$TARGETPLATFORM = "linux/amd64"]; then
     upx --lzma --best `find target/${RUST_TARGET}/release/ -type f -maxdepth 1 -executable`
else
    echo "Not compressing"
fi

mkdir -p /build/artifacts
cp -r target/${RUST_TARGET}/release/* /build/artifacts/
