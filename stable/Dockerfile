ARG VERSION="1.76.0"

FROM alpine:latest

ARG TARGETPLATFORM
ARG VERSION
ENV TARGETPLATFORM="${TARGETPLATFORM}"
ENV RUST_VERSION="${VERSION}"

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

ENV PATH="/home/builder/.cargo/bin:/usr/bin:/bin"
COPY install.sh /home/builder/install.sh
RUN /home/builder/install.sh

WORKDIR /build

COPY build.sh /home/builder/build.sh
ENTRYPOINT ["/home/builder/build.sh"]

LABEL org.opencontainers.image.title="rust-static-builder" \
    org.opencontainers.image.description="Docker image to build statically-linked Linux executables for Rust projects" \
    org.opencontainers.image.version="${VERSION}"

