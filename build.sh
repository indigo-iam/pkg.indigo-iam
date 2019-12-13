#!/bin/bash
set -ex

PLATFORMS=${PLATFORMS:-"centos7 ubuntu1604"}

rm -rf artifacts
mkdir -p artifacts

export PKG_BUILD_COPY_ARTIFACTS=y
export PKG_BUILD_COPY_ARTIFACTS_DIR=$(pwd)/artifacts

export DOCKER_ARGS=${DOCKER_ARGS:-"--rm"}

source ./setup-volumes.sh

for p in ${PLATFORMS}; do
  if [[ "${p}" =~ ^centos ]]; then
    dir=rpm
  else
    dir=deb
  fi
  echo "Platform dir: ${p} -> ${dir}"
  pushd ${dir}
  PLATFORM=${p} pkg-build.sh
  popd
done
