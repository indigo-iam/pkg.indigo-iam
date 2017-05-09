pipeline {
  agent { label 'docker' }

  options {
    timeout(time: 1, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  
  parameters {
    choice(name: 'INCLUDE_BUILD_NUMBER', choices: '0\n1', description: 'Flag to exclude/include build number.')
    string(name: 'PKG_BUILD_NUMBER', defaultValue: '', description: 'This is used to pass a custom build number that will be included in the package version.')
    choice(name: 'PLATFORM', choices: 'centos7\nubuntu1604', description: 'Build platform.')
    booleanParam(name: 'USE_DOCKER_REGISTRY', defaultValue: true, description: 'Use private registry.')
  }

  stages{
    stage('package') {
      environment {
        DATA_CONTAINER_NAME = "stage-area-pkg.indigo-iam-${env.BUILD_NUMBER}"
        PKG_TAG = "${env.BRANCH_NAME}"
        MVN_REPO_CONTAINER_NAME = "mvn_repo-${env.BUILD_NUMBER}"
        INCLUDE_BUILD_NUMBER = "${params.INCLUDE_BUILD_NUMBER}"
        PKG_BUILD_NUMBER = "${params.PKG_BUILD_NUMBER}"
        PLATFORM = "${params.PLATFORM}"
        USE_DOCKER_REGISTRY = "${params.USE_DOCKER_REGISTRY}"
      }
      
      steps {
        git(url: 'https://github.com/marcocaberletti/pkg.indigo-iam.git', branch: env.BRANCH_NAME)
        sh 'docker create -v /stage-area --name ${DATA_CONTAINER_NAME} italiangrid/pkg.base:${PLATFORM}'
        sh 'docker create -v /m2-repository --name ${MVN_REPO_CONTAINER_NAME} italiangrid/pkg.base:${PLATFORM}'
        sh '''
          pushd rpm 
          ls -al
          sh build.sh
          popd
        '''
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
  }
}
