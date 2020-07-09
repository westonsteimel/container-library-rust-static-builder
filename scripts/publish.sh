#!/bin/bash
set -e

export DOCKER_CLI_EXPERIMENTAL="enabled"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-docker.io}"
DOCKER_BUILD_CONTEXT="${DOCKER_BUILD_CONTEXT:-.}"
DOCKER_FILE="${DOCKER_FILE:-${DOCKER_BUILD_CONTEXT}/Dockerfile}"

if [[ -z "$DOCKER_TAGS" ]]; then
    echo "Set the DOCKER_TAGS environment variable."
    exit 1
fi

if [[ -z "$DOCKER_REPOSITORY" ]]; then
    echo "Set the DOCKER_REPOSITORY environment variable."
    exit 1
fi

if [[ -z "$DOCKER_USERNAME" ]]; then
    echo "Set the DOCKER_USERNAME environment variable."
    exit 1
fi

if [[ -z "$DOCKER_PASSWORD" ]]; then
    echo "Set the DOCKER_PASSWORD environment variable."
    exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
    echo "Set the GITHUB_REPOSITORY environment variable."
    exit 1
fi

if [[ -z "$GITHUB_SHA" ]]; then
    echo "Set the GITHUB_SHA environment variable."
    exit 1
fi

if [[ -z "$DOCKER_IMAGE_VERSION" ]]; then
    echo "Set the DOCKER_IMAGE_VERSION environment variable."
    exit 1
fi

BASE_NAME="${DOCKER_REGISTRY}/${DOCKER_USERNAME}/${DOCKER_REPOSITORY}"
SOURCE_LABEL="org.opencontainers.image.source=https://github.com/${GITHUB_REPOSITORY}"
REVISION_LABEL="org.opencontainers.image.revision=${GITHUB_SHA}"
CREATED_LABEL="org.opencontainers.image.created=`date --utc --rfc-3339=seconds`"
VERSION_LABEL="org.opencontainers.image.version=${DOCKER_IMAGE_VERSION}"

echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin "${DOCKER_REGISTRY}"

IFS=',' read -ra TAGS <<< "$DOCKER_TAGS"
for tag in "${TAGS[@]}"; do
    docker image build --platform "linux/amd64" \
        --build-arg TARGET="x86_64-unknown-linux-musl" \
        --tag "${BASE_NAME}:${tag}-linux-x86_64" \
        --label "${SOURCE_LABEL}" \
        --label "${REVISION_LABEL}" \
        --label "${CREATED_LABEL}" \
        --label "${VERSION_LABEL}" \
        --file "${DOCKER_FILE}" \
        "${DOCKER_BUILD_CONTEXT}"

    docker image build --platform "linux/arm64/v8" \
        --build-arg TARGET="aarch64-unknown-linux-musl" \
        --tag "${BASE_NAME}:${tag}-linux-aarch64" \
        --label "${SOURCE_LABEL}" \
        --label "${REVISION_LABEL}" \
        --label "${CREATED_LABEL}" \
        --label "${VERSION_LABEL}" \
        --file "${DOCKER_FILE}" \
        "${DOCKER_BUILD_CONTEXT}"

    docker image build --platform "linux/arm/v7" \
        --build-arg TARGET="armv7-unknown-linux-musleabihf" \
        --tag "${BASE_NAME}:${tag}-linux-armv7" \
        --label "${SOURCE_LABEL}" \
        --label "${REVISION_LABEL}" \
        --label "${CREATED_LABEL}" \
        --label "${VERSION_LABEL}" \
        --file "${DOCKER_FILE}" \
        "${DOCKER_BUILD_CONTEXT}"

    docker image build --platform "linux/arm/v6" \
        --build-arg TARGET="arm-unknown-linux-musleabihf" \
        --tag "${BASE_NAME}:${tag}-linux-armv6" \
        --label "${SOURCE_LABEL}" \
        --label "${REVISION_LABEL}" \
        --label "${CREATED_LABEL}" \
        --label "${VERSION_LABEL}" \
        --file "${DOCKER_FILE}" \
        "${DOCKER_BUILD_CONTEXT}"

    # Currently, we have to push the images before we can create a manifest for them 
    docker push "${BASE_NAME}"

    docker manifest create "${BASE_NAME}:${tag}" \
        "${BASE_NAME}:${tag}-linux-x86_64" \
        "${BASE_NAME}:${tag}-linux-aarch64" \
        "${BASE_NAME}:${tag}-linux-armv7" \
        "${BASE_NAME}:${tag}-linux-armv6"

    docker manifest push "${BASE_NAME}:${tag}"

done

docker logout
