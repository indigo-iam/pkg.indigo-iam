#!/usr/bin/env groovy
@Library('sd')_
def kubeLabel = getKubeLabel()

pipeline {
  agent {
      kubernetes {
          label "${kubeLabel}"
          cloud 'Kube mwdevel'
          defaultContainer 'runner'
          inheritFrom 'ci-template'
      }
  }

  options {
    timeout(time: 1, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  
  parameters {
    choice(name: 'INCLUDE_BUILD_NUMBER', choices: '0\n1', description: 'Flag to exclude/include build number.')
    string(name: 'PKG_BUILD_NUMBER', defaultValue: '', description: 'This is used to pass a custom build number that will be included in the package version.')
    choice(name: 'PLATFORM', choices: 'centos7\nubuntu1604', description: 'Build platform.')
  }

  stages{
    stage('package') {
      environment {
        DATA_CONTAINER_NAME = "stage-area-pkg.indigo-iam-${env.JOB_BASE_NAME}-${env.BUILD_NUMBER}"
        PKG_TAG = "${env.BRANCH_NAME}"
        MVN_REPO_CONTAINER_NAME = "mvn_repo-pkg.indigo-iam-${env.JOB_BASE_NAME}-${env.BUILD_NUMBER}"
        INCLUDE_BUILD_NUMBER = "${params.INCLUDE_BUILD_NUMBER}"
        PKG_BUILD_NUMBER = "${params.PKG_BUILD_NUMBER}"
        PLATFORM = "${params.PLATFORM}"
        DOCKER_REGISTRY_HOST = "${env.DOCKER_REGISTRY_HOST}"
      }
      
      steps {
	      cleanWs notFailBuild: true
	      checkout scm
	      sh 'docker create -v /stage-area --name ${DATA_CONTAINER_NAME} ${DOCKER_REGISTRY_HOST}/italiangrid/pkg.base:${PLATFORM}'
	      sh 'docker create -v /m2-repository --name ${MVN_REPO_CONTAINER_NAME} ${DOCKER_REGISTRY_HOST}/italiangrid/pkg.base:${PLATFORM}'
	      script {
	        def rundir = 'rpm'
	        if("ubuntu1604" == "${params.PLATFORM}") {
	          rundir = 'deb'
	        }
	        dir("${rundir}"){
	          sh "ls -al"
	          sh "sh build.sh"
	        }
	      }
	      sh 'docker cp ${DATA_CONTAINER_NAME}:/stage-area repo'
	      sh 'docker rm -f ${DATA_CONTAINER_NAME} ${MVN_REPO_CONTAINER_NAME}'
	      archiveArtifacts 'repo/**'
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
