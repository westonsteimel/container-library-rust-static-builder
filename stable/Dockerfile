ARG TOOLCHAIN="stable"

FROM alpine:latest

ARG TOOLCHAIN

RUN apk update && apk add --no-cache \
    ca-certificates \
    build-base \
    git \
    curl \
    musl-utils \ 
    musl \
    musl-dev \
    openssl-dev \
    openssl-libs-static \
    zlib-dev \
    zlib-static \
    bzip2-dev \
    bzip2-static \
    sqlite-dev \
    sqlite-static \
    xz-dev \
    upx

RUN addgroup builder \
    && adduser -G builder -s /bin/sh -D builder \
    && mkdir /build \
    && chown builder /build

USER builder

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain "${TOOLCHAIN}" && \
    /home/builder/.cargo/bin/rustup target add x86_64-unknown-linux-musl

ENV PATH=/home/builder/.cargo/bin:/usr/bin:/bin

WORKDIR /build

COPY build.sh /home/builder/build.sh
ENTRYPOINT ["/home/builder/build.sh"]

LABEL org.opencontainers.image.title="rust-static-builder" \
    org.opencontainers.image.description="Docker image to build statically linked Linux executables from Rust projects" \
    org.opencontainers.image.url="https://github.com/westonsteimel/docker-rust-static-builder" \
    org.opencontainers.image.source="https://github.com/westonsteimel/docker-rust-static-builder" \
    org.opencontainers.image.version="${TOOLCHAIN}" \
    version="${TOOLCHAIN}"
