#!/usr/bin/env groovy

pipeline {
  agent {
    label 'docker'
  }

  options {
    timeout(time: 1, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  
  environment {
    PKG_TAG = "${env.BRANCH_NAME}"
    DOCKER_REGISTRY_HOST = "${env.DOCKER_REGISTRY_HOST}"
    RPM_PLATFORMS = "centos7"
    DEB_PLATFORMS = ""
    CI_REPO = "indigo-iam-rpm-ci"
    BETA_REPO = "indigo-iam-rpm-beta"
    STABLE_REPO = "indigo-iam-rpm-stable"
    PKG_NEXUS_HOST = "https://repo.cloud.cnaf.infn.it"
    PKG_NEXUS_CRED = credentials('jenkins-nexus')
    PKG_NEXUS_USERNAME = ${env.PKG_NEXUS_CRED_USR}
    PKG_NEXUS_PASSWORD = ${env.PKG_NEXUS_CRED_PSW}
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
        sh './build.sh'
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
