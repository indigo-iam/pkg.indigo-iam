#!/bin/bash
set -ex

## Upload RPMs

for p in ${RPM_PLATFORMS}; do
  nexus-assets-flat-upload -u ${NX_USERNAME} \
    -p ${NX_PASSWORD} \
    -H ${NEXUS_HOST} \
    -r ${TARGET_REPO}/${BUILD_TAG}/${p} \
    -d artifacts/packages/${p}/RPMS
done
