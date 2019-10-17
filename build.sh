#!/bin/bash
set -ex

RPM_PLATFORMS=${RPM_PLATFORMS:-"centos7 centos8"}
DEB_PLATFORMS=${DEB_PLATFORMS:-"ubuntu1604"}

if [ -n "${PKG_CI_MODE}" ]; then

  M2_VOLUME=${M2_VOLUME:-m2-repo-pkg.indigo-iam}

  docker volume create ${M2_VOLUME}

  rm -rf artifacts
  mkdir -p artifacts/packages artifacts/stage-area 
  chmod 777 artifacts/packages artifacts/stage-area

  volumes_conf="-v $(pwd)/artifacts/packages:/packages"
  volumes_conf="${volumes_conf} -v $(pwd)/artifacts/stage-area:/stage-area"
  volumes_conf="${volumes_conf} -v ${M2_VOLUME}:/m2-repository"

  export PKG_VOLUMES_CONF=${volumes_conf}

else

  PACKAGES_VOLUME_NAME=${PACKAGES_VOLUME_NAME:-packages-volume-pkg.indigo-iam}
  STAGE_AREA_VOLUME_NAME=${STAGE_AREA_VOLUME_NAME:-stage-area-volume-pkg.indigo-iam}
  MVN_REPO_VOLUME_NAME=${MVN_REPO_VOLUME_NAME:-mvn-repo-volume-pkg.indigo-iam}

  export PACKAGES_VOLUME=$(docker volume create ${PACKAGES_VOLUME_NAME})
  export STAGE_AREA_VOLUME=$(docker volume create ${STAGE_AREA_VOLUME_NAME})
  export MVN_REPO_VOLUME=$(docker volume create ${MVN_REPO_VOLUME_NAME})
fi


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

