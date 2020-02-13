#!/bin/bash -xe
#
# jenkins backup scripts
#
# Usage: ./jenkins-backup.sh /path/to/jenkins_home /path/to/destination/archive.tar.gz
touch /var/jenkins_home/.ssh/id_rsa
chmod 755 /var/jenkins_home/.ssh/id_rsa
cat ${jenkinsprivatekey} >> /var/jenkins_home/.ssh/id_rsa
chmod 500 /var/jenkins_home/.ssh/id_rsa
mkdir -p /var/jenkins_home/backups/
touch /var/jenkins_home/backups/latest.tar
_dow="$(date +'%A')"
JENKINS_HOME="/var/jenkins_home"
#DEST_FILE="/var/jenkins_home/backups/backup_`date +"%Y%m%d%H%M%S"`.tar.gz"
DEST_FILE="/var/jenkins_home/backups/backup_${_dow}.tar"
CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
TMP_DIR="${CUR_DIR}/tmp"
ARC_NAME="jenkins_home"
ARC_DIR="${TMP_DIR}/${ARC_NAME}"
TMP_TAR_NAME="${TMP_DIR}/archive.tar.gz"



function usage() {
  echo "usage: $(basename $0) /path/to/jenkins_home archive.tar.gz"
}


function backup_jobs() {
  local run_in_path="$1"
  local rel_depth=${run_in_path#${JENKINS_HOME}/jobs/}

  if [ -d "${run_in_path}" ]; then  
    cd "${run_in_path}"

    find . -name '*.xml' -print | grep -v builds/ | cpio -d -p ${ARC_DIR}/jobs

  fi
}

function cleanup() {
  rm -rf "${ARC_DIR}"
}


function main() {
  if [ -z "${JENKINS_HOME}" -o -z "${DEST_FILE}" ] ; then
    usage >&2
    exit 1
  fi

  rm -rf "${ARC_DIR}" "{$TMP_TAR_NAME}"
  for plugin in plugins jobs users secrets nodes scriptler; do
    mkdir -p "${ARC_DIR}/${plugin}"
  done

  cp "${JENKINS_HOME}/"*.xml "${ARC_DIR}"

  cp "${JENKINS_HOME}/plugins/"*.[hj]pi "${ARC_DIR}/plugins"
  hpi_pinned_count=$(find ${JENKINS_HOME}/plugins/ -name *.hpi.pinned | wc -l)
  jpi_pinned_count=$(find ${JENKINS_HOME}/plugins/ -name *.jpi.pinned | wc -l)
  if [ ${hpi_pinned_count} -ne 0 -o ${jpi_pinned_count} -ne 0 ]; then
    cp "${JENKINS_HOME}/plugins/"*.[hj]pi.pinned "${ARC_DIR}/plugins"
  fi

  if [ "$(ls -A ${JENKINS_HOME}/users/)" ]; then
    cp -R "${JENKINS_HOME}/users/"* "${ARC_DIR}/users"
  fi

  if [ "$(ls -A ${JENKINS_HOME}/secrets/)" ] ; then
    cp -R "${JENKINS_HOME}/secrets/"* "${ARC_DIR}/secrets"
  fi
  
  if [ "$(ls -A ${JENKINS_HOME}/scriptler/)" ] ; then
    cp -R "${JENKINS_HOME}/scriptler/"* "${ARC_DIR}/scriptler"
  fi
 
  if [ "$(ls -A ${JENKINS_HOME}/nodes/)" ] ; then
    cp -R "${JENKINS_HOME}/nodes/"* "${ARC_DIR}/nodes"
  fi

  if [ "$(ls -A ${JENKINS_HOME}/jobs/)" ] ; then
    backup_jobs ${JENKINS_HOME}/jobs/
  fi
  mkdir -p /var/jenkins_home/backups/
  cd "${TMP_DIR}"
  tar -czvf "${TMP_TAR_NAME}" "${ARC_NAME}/"*
  cd -
  mv -f "${TMP_TAR_NAME}" "${DEST_FILE}"
  cd /var/jenkins_home/workspace/Backup
  git init
  git clone ssh://git@git.tsys.aws/ct/tools-backups.git
  cd /var/jenkins_home/workspace/Backup/tools-backups
  git fetch --all 
  git checkout jenkins-backups
  mkdir -p /var/jenkins_home/workspace/Backup/tools-backups/`echo ${JENKINS_URL} | cut -c 32-`
  cp /var/jenkins_home/config.xml /var/jenkins_home/workspace/Backup/tools-backups/`echo ${JENKINS_URL} | cut -c 32-`
  git add .
  git config user.email "jenkins@tsys.com"
  git config user.name "Auto Deploy"
  git diff-index --quiet HEAD || git commit -m "CDT-10" `echo ${JENKINS_URL} | cut -c 32-`
  git pull origin jenkins-backups
  git push origin HEAD:jenkins-backups
  rm -f /var/jenkins_home/.ssh/id_rsa

  cleanup

  exit 0
}


main

