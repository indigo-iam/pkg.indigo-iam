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
      }
      
      steps {
	      cleanWs notFailBuild: true
	      checkout scm
	      sh 'build.sh'
              archiveArtifacts 'artifacts/**'
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
