ARG TOOLCHAIN="stable"
ARG TARGET
ARG SOURCE
ARG REVISION
ARG CREATED
ARG VERSION="${TOOLCHAIN}"

FROM alpine:latest

ARG TARGET
ARG TOOLCHAIN
ARG SOURCE
ARG REVISION
ARG CREATED
ARG VERSION

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
    && if [$TARGETPLATFORM = "linux/amd64"]; then apk add --no-cache upx; fi

RUN addgroup builder \
    && adduser -G builder -s /bin/sh -D builder \
    && mkdir /build \
    && chown builder /build

USER builder

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain "${TOOLCHAIN}" && \
    /home/builder/.cargo/bin/rustup target add "${TARGET}"

ENV PATH=/home/builder/.cargo/bin:/usr/bin:/bin
ENV TARGET "${TARGET}"
ENV TARGETPLATFORM "${TARGETPLATFORM}"

WORKDIR /build

COPY build.sh /home/builder/build.sh
ENTRYPOINT ["/home/builder/build.sh"]

LABEL org.opencontainers.image.title="rust-static-builder" \
    org.opencontainers.image.description="Docker image to build statically linked Linux executables from Rust projects" \
    org.opencontainers.image.source="${SOURCE}" \
    org.opencontainers.image.revision="${REVISION}" \
    org.opencontainers.image.created="${CREATED}" \
    org.opencontainers.image.version="${VERSION}"
