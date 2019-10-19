#!/usr/bin/env groovy

def platform2Dir = [
  "centos7" : 'rpm',
  "centos8" : 'rpm',
  "ubuntu1604" : 'deb',
  "ubuntu1804" : 'deb'
]

def publishPackages(platform, platform2Dir) {
  return {
    unstash "source"

    def platformDir = platform2Dir[platform]

    if (!platformDir) {
      error("Unknown platform: ${platform}")
    }

    dir(platformDir) {
      sh "PLATFORM=${platform} pkg-build.sh"
    }
  }
}

def buildPackages(platform, platform2Dir) {
  return {
    unstash "source"

    def platformDir = platform2Dir[platform]

    if (!platformDir) {
      error("Unknown platform: ${platform}")
    }

    dir(platformDir) {
      // sh "PLATFORM=${platform} pkg-build.sh"
      sh "echo Building platform: ${platform}"
    }
  }
}


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
    PLATFORMS = "centos7 centos8 ubuntu1604"
    CI_REPO = "indigo-iam-rpm-ci"
    NIGHTLY_REPO = "indigo-iam-rpm-nightly"
    BETA_REPO = "indigo-iam-rpm-beta"
    STABLE_REPO = "indigo-iam-rpm-stable"
    PKG_NEXUS_HOST = "https://repo.cloud.cnaf.infn.it"
    PKG_NEXUS_CRED = credentials('jenkins-nexus')
    DOCKER_ARGS = "--rm -v /opt/cnafsd/helper-scripts/scripts/:/usr/local/bin "
  }

  stages{
    stage('checkout') {
      steps {
        cleanWs notFailBuild: true
        checkout scm
        stash name: "source", includes: "**"
      }
    }

    stage('package') {
      steps {
        script {
          def buildStages = PLATFORMS.split(' ').collectEntries {
            [ "${it} build packages" : buildPackages(it, platform2Dir) ]
          }
          echo "${buildStages}"
          parallel buildStages
        }
      }
    }

    stage('publish-ci') {
      environment {
        PKG_PUBLISH_PACKAGES = "y"
        PKG_NEXUS_REPONAME = "${env.CI_REPO}/${env.BUILD_TAG}"
        PKG_TARGET = "make publish-rpm"
      }
      steps {
        script {
          def buildStages = PLATFORMS.split(' ').collectEntries {
            [ "${it} publish packages (CI)" : publishPackages(it, platform2Dir) ]
          }
          parallel buildStages
        }
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
        echo "tbd"
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
        echo "tbd"
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
        echo "tbd"
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
