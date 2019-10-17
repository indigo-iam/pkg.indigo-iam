#!/bin/bash
set -ex

## Upload RPMs

job_name=$(echo ${BUILD_TAG} | sed -e 's/^jenkins-//')

for platform in ${RPM_PLATFORMS}; do
  nexus-assets-flat-upload -u ${NX_USERNAME} \
    -p ${NX_PASSWORD} \
    -H ${NEXUS_HOST} \
    -r ${TARGET_REPO}/${job_name}/${platform} \
    -d artifacts/packages/${platform}/RPMS
done
