#!/bin/sh
set -e
case $1 in
  backup)
    if test "$(ls /var/jenkins_home)"; then
      pwd
      echo "Directory /var/jenkins_home is not empty. Backing it up to /tmp folder"
      datestr=$(date '+%y%m%d')
      tar -cvzpf "jenkinsdata-${JENKINS_VERSION}-$datestr.tar.gz" \
        --exclude='.[^/]*' \
        --exclude "./jobs/*/builds/**" \
        --exclude "./workspace/**" \
        --exclude "./users/**" \
        --exclude "./*.log" \
        --exclude "./logs/**" \
        --exclude "./war/**" \
        --exclude "./export/**" \
        --exclude "./tools/**" \
        --exclude "./*.bak" \
        --exclude "./scm-sync-configuration/checkoutConfiguration/jobs/**" \
        --exclude "./scm-sync-configuration/checkoutConfiguration/fingerprints/**" \
        --exclude "./scm-sync-configuration/checkoutConfiguration/users/**" \
        --exclude "./nodes/**" \
        --exclude "./users/**" \
        --exclude "**/cache*/**" \
        --numeric-owner \
        -c \
        -C /var/jenkins_home/ .

      echo "Directory /var/jenkins_home backed up to /tmp"
    fi
    ;;
    backupjobs)
    if test "$(ls /var/jenkins_home/jobs)"; then
      echo "Directory /var/jenkins_home/jobs is not empty. Backing it up to /tmp folder"
      datestr=$(date '+%y%m%d')
      tar -cvzpf "jobs-${JENKINS_VERSION}-$datestr.tar.gz" \
        --exclude "./*/builds/**" \
        --exclude "./*/jobs/**" \
        --exclude "./*/htmlreports/**" \
        --exclude "./*/branches/**" \
        --exclude "./*/indexing/**" \
        --numeric-owner \
        -c \
        -C /var/jenkins_home/jobs/ .

      echo "Directory /var/jenkins_home/jobs backed up to /tmp"
    fi
    ;;
    backupplugins)
    if test "$(ls /var/jenkins_home/plugins)"; then
      echo "Directory /var/jenkins_home/plugins is not empty. Backing it up to /tmp folder"
      datestr=$(date '+%y%m%d')
      tar -cvzpf "plugins-${JENKINS_VERSION}-$datestr.tar.gz" \
        --exclude "./*.bak" \
        --numeric-owner \
        -c \
        -C /var/jenkins_home/plugins/ .

      echo "Directory /var/jenkins_home/plugins backed up to /tmp"
    fi
    ;;
    backupconfigs)
    if test "$(ls /var/jenkins_home)"; then
      echo "Directory /var/jenkins_home is not empty. Backing it up to /tmp folder"
      datestr=$(date '+%y%m%d')
      tar -cvzpf "configs-${JENKINS_VERSION}-$datestr.tar.gz" \
        --exclude='.[^/]*' \
        --exclude "./jobs/**" \
        --exclude "./plugins/**" \
        --exclude "./workspace/**" \
        --exclude "./export/**" \
        --exclude "./nodes/**" \
        --exclude "./tools/**" \
        --exclude "./users/**" \
        --exclude "./*.log" \
        --exclude "./logs/**" \
        --exclude "./war/**" \
        --exclude "./*.bak" \
        --exclude "./scm-sync-configuration/checkoutConfiguration/jobs/**" \
        --exclude "./scm-sync-configuration/checkoutConfiguration/fingerprints/**" \
        --exclude "./scm-sync-configuration/checkoutConfiguration/users/**" \
        --exclude "**/cache*/**" \
        --numeric-owner \
        -c \
        -C /var/jenkins_home/ .

      echo "Directory /var/jenkins_home backed up to /tmp"
    fi
    ;;
  install)
    echo "Directory /var/jenkins_home/ is empty. Loading content from /jenkins.tar.gz..."
    aws s3 cp s3://tools-data-toolstsyspropenterprise-us-east-1-tsys/jenkins/jenkinsdata-${JENKINSDATA_TAR_VERSION}.tar.gz /jenkinsdata.tar.gz 
    chown jenkins:jenkins /jenkinsdata.tar.gz
    cd /var/jenkins_home
    tar -zvxf /jenkinsdata.tar.gz
    echo "Directory /var/jenkins_home/ content loaded."
    ;;
  jobs)
    echo "Directory /var/jenkins_home/jobs  Loading content from /jobs tar from repos..."
    aws s3 cp s3://tools-data-toolstsyspropenterprise-us-east-1-tsys/jenkins/jobs-${JOBS_TAR_VERSION}.tar.gz /jobs.tar.gz
    chown jenkins:jenkins /jobs.tar.gz
    cd /var/jenkins_home/jobs
    tar -zvxf /jobs.tar.gz
    echo "Directory /var/jenkins_home/jobs loaded." 
    ;;
  plugins)
    echo "Directory /var/jenkins_home/plugins  Loading content from /plugins tar from repos..."
    wget -O /plugins.tar.gz http://repos.tpp.tsysecom.com/jenkins/plugins-${PLUGINS_TAR_VERSION}.tar.gz
    aws s3 cp s3://tools-data-toolstsyspropenterprise-us-east-1-tsys/jenkins/plugins-${PLUGINS_TAR_VERSION}.tar.gz /plugins.tar.gz
    chown jenkins:jenkins /plugins.tar.gz
    cd /var/jenkins_home/plugins
    tar -zvxf /plugins.tar.gz
    echo "Directory /var/jenkins_home/plugins loaded." 
    ;;
  configs)
    echo "Directory /var/jenkins_home/  Loading content from /configs tar from repos..."
    aws s3 cp s3://tools-data-toolstsyspropenterprise-us-east-1-tsys/jenkins/configs-${CONFIGS_TAR_VERSION}.tar.gz /configs.tar.gz
    chown jenkins:jenkins /configs.tar.gz
    cd /var/jenkins_home
    tar -zvxf /configs.tar.gz
    echo "Directory /var/jenkins_home/ configs loaded." 
    ;;
  list)
    echo "Directory /var/jenkins_home/  contents..."
    ls -la /var/jenkins_home
    ;;
  *)
    echo 'Specify either install/jobs/plugins/list/backup/backupjobs/backupplugins/backupconfigs/'
    exit 1
    ;;
esac
