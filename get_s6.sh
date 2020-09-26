#!/bin/sh

set -eu

readonly s6_dir=/s6

get_s6_overlay_platform () {
  case "$1" in
    linux/arm/v6)
      echo arm
      ;;
    linux/arm/v7)
      echo armhf
      ;;
    linux/arm64|linux/aarch64)
      echo aarch64
      ;;
    linux/amd64)
      echo amd64
      ;;
    linux/386)
      echo x86
      ;;
    *)
      echo "unsupported target platform: '$1'"
      exit 1
      ;;
  esac
}

readonly s6_overlay_platform=$(get_s6_overlay_platform "$TARGETPLATFORM")
readonly s6_overlay_url="https://github.com/just-containers/s6-overlay/releases/download/v$S6_OVERLAY_VERSION/s6-overlay-$s6_overlay_platform.tar.gz"

mkdir -p $s6_dir
curl -L "$s6_overlay_url" | tar xz -C $s6_dir
