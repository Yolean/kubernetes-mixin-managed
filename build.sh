#!/usr/bin/env bash
[ -z "$DEBUG" ] || set -x
set -eo pipefail

# For https://github.com/Yolean/kubernetes-mixin-managed/

BUILDER=kubernetes-mixin-builder:local
BUILDUSER="$(id -u):$(id -g)"
CACHEDIR="$(pwd)/tmp/go-mod-cache"

#cat <<EOF | docker buildx build --output=type=docker --tag $BUILDER -
cat <<EOF | docker build --tag $BUILDER -
FROM golang:1.19.4-bullseye
# this is arm64, for x86 switch to https://hub.docker.com/layers/grafana/jsonnet-build/4fd8fef/images/sha256-bb7efa8ff0ccc7a865d7c74fb09378d0d10133011dc7a85db9af59148800192b?context=explore
COPY --from=grafana/jsonnet-build:3989b8d@sha256:16b842c300a84fd541fbdd3a47a2ee8bc93b5be363ebf1605746e7063318f747 \
  /usr/bin/jsonnet /usr/local/bin/jsonnet
RUN go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@v0.5.1
RUN go install github.com/brancz/gojsontoyaml@v0.1.0

RUN echo 'nonroot:x:$BUILDUSER:nonroot:/home/nonroot:/usr/sbin/nologin' >> /etc/passwd && \
  mkdir -p /home/nonroot && touch /home/nonroot/.bash_history && chown -R $BUILDUSER /home/nonroot
RUN chown -R nonroot /go
USER nonroot:nogroup
EOF

docker run --rm --name kubernetes-mixin-builder \
  -u $BUILDUSER \
  -v $(pwd):/home/nonroot/kubernetes-mixin -w /home/nonroot/kubernetes-mixin \
  -v $CACHEDIR:/go/pkg/mod/cache \
  -e DEBUG=true \
  --entrypoint=./build-kustomize-base.sh  \
  $BUILDER
