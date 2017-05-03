pipeline {
  agent { label 'docker' }

  options {
    timeout(time: 1, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  
  parameters {
    string(name: 'COMPONENTS', defaultValue: 'iam-login-service')
    choice(name: 'PLATFORM', choices: 'centos7')
    string(name: 'PKG_BUILD_NUMBER', defaultValue: '', description: 'This is used to pass a custom build number that will be included in the package version.')
  }

  stages{
    stage('package') {
      environment {
        DATA_CONTAINER_NAME = 'stage-area-pkg.argus-${BUILD_NUMBER}'
        PKG_TAG = "${env.BRANCH_NAME}"
        MVN_REPO_CONTAINER_NAME = 'mvn_repo-${BUILD_NUMBER}'
        PLATFORM = "${params.PLATFORM}"
        COMPONENTS = "${params.COMPONENTS}"
        PKG_BUILD_NUMBER = "${params.PKG_BUILD_NUMBER}"
        STAGE_ALL = '1'
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
}
