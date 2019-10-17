#!/bin/bash
set -ex

## Upload RPMs

job_name=$(echo ${BUILD_TAG} | sed -e 's/^jenkins-//')

for platform in ${RPM_PLATFORMS}; do
  dir_to_upload="artifacts/packages/${platform}/RPMS"
  if [ ! -d "${dir_to_upload}" ]; then
    echo "Directory to upload not found!"
    ls -lR
    exit 1
  else
    nexus-assets-flat-upload -u ${NX_USERNAME} \
      -p ${NX_PASSWORD} \
      -H ${NEXUS_HOST} \
      -r ${TARGET_REPO}/${job_name}/${platform} \
      -d ${dir_to_upload}
  fi
done
