#!/bin/sh
set -e -u

docker build --pull \
    --tag get-stable-version \
    --build-arg TARGETPLATFORM="linux/amd64" \
    --build-arg VERSION="stable" \
    "stable"

version=`docker run --rm --entrypoint "rustc" get-stable-version --version | pcregrep -o1 -e "^rustc (.*) \(.*$"`

echo "latest stable version: ${version}"

sed -ri \
    -e 's/^(ARG VERSION=).*/\1'"\"${version}\""'/' \
    "stable/Dockerfile"

git add stable/Dockerfile
git diff-index --quiet HEAD || git commit --message "updated stable to version ${version}"

docker image rm get-stable-version
