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
    *)
        echo "${TARGETPLATFORM} is not currently supported"
        exit 1
        ;;
esac

echo "Rust target: ${RUST_TARGET}"

curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain "${RUST_VERSION}" && \
    /home/builder/.cargo/bin/rustup target add "${RUST_TARGET}"

