#!/bin/bash
set -ex

RPM_PLATFORMS=${RPM_PLATFORMS:-"centos7"}
DEB_PLATFORMS=${DEB_PLATFORMS:-""}

export DOCKER_ARGS=${DOCKER_ARGS:-"--rm"}

./setup-volumes.sh

for p in ${RPM_PLATFORMS}; do
  pushd rpm
  PLATFORM=${p} pkg-build.sh
  popd
done

for p in ${DEB_PLATFORMS}; do
  pushd deb
  PLATFORM=${p} pkg-build.sh
  popd
done
