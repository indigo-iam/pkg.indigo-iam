#!/usr/bin/env groovy

pipeline {
  agent {
    label 'docker'
  }

  options {
    timeout(time: 1, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }

  parameters {
    booleanParam(name: 'SKIP_BUILD', defaultValue: false, description: 'Skip package build')
  }
  
  environment {
    PKG_TAG = "${env.BRANCH_NAME}"
    DOCKER_REGISTRY_HOST = "${env.DOCKER_REGISTRY_HOST}"
    RPM_PLATFORMS = "centos7 centos8"
    DEB_PLATFORMS = "ubuntu1604 ubuntu1804"
    CI_REPO = "indigo-iam-rpm-ci"
    NIGHTLY_REPO = "indigo-iam-rpm-nightly"
    BETA_REPO = "indigo-iam-rpm-beta"
    STABLE_REPO = "indigo-iam-rpm-stable"
    PKG_NEXUS_HOST = "https://repo.cloud.cnaf.infn.it"
    PKG_NEXUS_CRED = credentials('jenkins-nexus')
    DOCKER_ARGS = "--rm -v /opt/cnafsd/helper-scripts/scripts/:/usr/local/bin "
  }

  stages{
    stage('package') {
      steps {
	      cleanWs notFailBuild: true
	      checkout scm
	      sh './build.sh'
      }
    }

    stage('publish-ci') {
      environment {
        PKG_PUBLISH_PACKAGES = "y"
        PKG_NEXUS_REPONAME = "${env.CI_REPO}/${env.BUILD_TAG}"
        PKG_TARGET = "make publish-rpm"
      }
      steps {
        sh 'PKG_NEXUS_USERNAME=${PKG_NEXUS_CRED_USR} PKG_NEXUS_PASSWORD=${PKG_NEXUS_CRED_PSW} ./build.sh'
      }
    }

    stage('publish-nightly') {

      when {
        branch 'nightly'
      }

      environment {
        PKG_PUBLISH_PACKAGES = "y"
        PKG_NEXUS_REPONAME = "${env.NIGHTLY_REPO}"
        PKG_TARGET = "make publish-rpm"
      }
      steps {
        sh 'PKG_NEXUS_USERNAME=${PKG_NEXUS_CRED_USR} PKG_NEXUS_PASSWORD=${PKG_NEXUS_CRED_PSW} ./build.sh'
      }
    }

    stage('publish-beta') {
      when {
        branch 'beta'
      }

      environment {
        PKG_PUBLISH_PACKAGES = "y"
        PKG_NEXUS_REPONAME = "${env.BETA_REPO}"
        PKG_TARGET = "make publish-rpm"
      }
      steps {
        sh 'PKG_NEXUS_USERNAME=${PKG_NEXUS_CRED_USR} PKG_NEXUS_PASSWORD=${PKG_NEXUS_CRED_PSW} ./build.sh'
      }
    }

    stage('publish-stable') {
      when {
        branch 'stable'
      }

      environment {
        PKG_PUBLISH_PACKAGES = "y"
        PKG_NEXUS_REPONAME = "${env.STABLE_REPO}"
        PKG_TARGET = "make publish-rpm"
      }

      steps {
        sh 'PKG_NEXUS_USERNAME=${PKG_NEXUS_CRED_USR} PKG_NEXUS_PASSWORD=${PKG_NEXUS_CRED_PSW} ./build.sh'
      }
    }
  }

  post {
    failure {
      slackSend color: 'danger', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Failure (<${env.BUILD_URL}|Open>)"
    }
    
    changed {
      script{
        if('SUCCESS'.equals(currentBuild.currentResult)) {
          slackSend color: 'good', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Back to normal (<${env.BUILD_URL}|Open>)"
        }
      }
    }
  }
}
