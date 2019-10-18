#!/bin/bash
set -ex

PACKAGES_VOLUME_NAME=${PACKAGES_VOLUME_NAME:-packages-volume-pkg.indigo-iam}
STAGE_AREA_VOLUME_NAME=${STAGE_AREA_VOLUME_NAME:-stage-area-volume-pkg.indigo-iam}
MVN_REPO_VOLUME_NAME=${MVN_REPO_VOLUME_NAME:-mvn-repo-volume-pkg.indigo-iam}

export PACKAGES_VOLUME=$(docker volume create ${PACKAGES_VOLUME_NAME})
export STAGE_AREA_VOLUME=$(docker volume create ${STAGE_AREA_VOLUME_NAME})
export MVN_REPO_VOLUME=$(docker volume create ${MVN_REPO_VOLUME_NAME})
