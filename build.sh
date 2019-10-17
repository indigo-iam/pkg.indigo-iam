#!/bin/bash
set -ex

RPM_PLATFORMS=${RPM_PLATFORMS:-"centos7"}
DEB_PLATFORMS=${DEB_PLATFORMS:-""}

export DOCKER_ARGS=${DOCKER_ARGS:-"--rm"}

PACKAGES_VOLUME_NAME=${PACKAGES_VOLUME_NAME:-packages-volume-pkg.indigo-iam}
STAGE_AREA_VOLUME_NAME=${STAGE_AREA_VOLUME_NAME:-stage-area-volume-pkg.indigo-iam}
MVN_REPO_VOLUME_NAME=${MVN_REPO_VOLUME_NAME:-mvn-repo-volume-pkg.indigo-iam}

export PACKAGES_VOLUME=$(docker volume create ${PACKAGES_VOLUME_NAME})
export STAGE_AREA_VOLUME=$(docker volume create ${STAGE_AREA_VOLUME_NAME})
export MVN_REPO_VOLUME=$(docker volume create ${MVN_REPO_VOLUME_NAME})

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
