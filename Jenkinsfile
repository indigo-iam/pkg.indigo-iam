#!/usr/bin/env groovy

pipeline {
  agent {
    label 'docker'
  }

  options {
    timeout(time: 1, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  
  stages{
    stage('package') {
      environment {
        PKG_TAG = "${env.BRANCH_NAME}"
        PKG_CI_MODE = "y"
        DOCKER_REGISTRY_HOST = "${env.DOCKER_REGISTRY_HOST}"
        NEXUS_HOST = "https://repo.cloud.cnaf.infn.it"
        TARGET_REPO = "indigo-iam-ci-builds"
      }
      
      steps {
	      cleanWs notFailBuild: true
	      checkout scm
	      sh './build.sh'
              archiveArtifacts 'artifacts/**'
      }
    }

    stage('publish') {
      environment {
        PKG_TAG = "${env.BRANCH_NAME}"
        PKG_CI_MODE = "y"
        DOCKER_REGISTRY_HOST = "${env.DOCKER_REGISTRY_HOST}"
        RPM_PLATFORMS = "centos7 centos8"
      }
      
      steps {
          withCredentials([
            usernamePassword(credentialsId: 'jenkins-nexus', passwordVariable: 'nxPassword', usernameVariable: 'nxUsername')
          ]) {
            sh "NX_USERNAME=\"${nxUsername}\" NX_PASSWORD=\"${nxPassword}\" ./upload-packages.sh"
          }
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
