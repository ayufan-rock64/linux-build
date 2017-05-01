pipeline {
  // parameters {
  //   string (
  //     defaultValue: '1.0',
  //     description: 'Current version number',
  //     name : 'VERSION')
  //   text (
  //     defaultValue: '',
  //     description: 'A list of changes',
  //     name : 'CHANGES')
  //   booleanParam (
  //     defaultValue: false,
  //     description: 'If build should be marked as pre-release',
  //     name : 'PRERELEASE')
  //   string (
  //     defaultValue: '1.0',
  //     description: 'GitHub username or organization',
  //     name : 'GITHUB_USER')
  //   string (
  //     defaultValue: '1.0',
  //     description: 'GitHub repository',
  //     name : 'GITHUB_REPO')
  // }

  agent {
    dockerfile { 
      dir 'build-environment' 
      label 'docker && linux-build'
      args  '--privileged -u 0:0'
    } 
  }
  environment { 
      USE_CCACHE = 'true'
      RELEASE_NAME = "$RELEASE_NAME"
      RELEASE = "$BUILD_NUMBER"
      CCACHE_DIR = "$WORKSPACE/ccache"
      PRERELEASE = "$PRERELEASE"
      GITHUB_USER = "$GITHUB_USER"
      GITHUB_REPO = "$GITHUB_REPO"
  }
  options {
    timestamps()
  }

  stages {
    stage('Prepare') {
      steps {
        sh 'ccache -M 0 -F 0'
        sh 'git clean -ffdx -e ccache'
      }
    }

    stage('Build') {
      steps {
        sh 'make'
      }
    }

    stage('Release') {
      steps {
        sh '''#!/bin/bash
          set -xe
          shopt -s nullglob

          github-release release \
              --tag "${VERSION}" \
              --name "$VERSION: $BUILD_TAG" \
              --description "${CHANGES}\n\n${BUILD_URL}" \
              --draft

          for file in *.xz *.deb; do
            github-release upload \
                --tag "${VERSION}" \
                --name "$(basename "$file")" \
                --file "$file" &
          done

          wait

          if [[ "$PRERELEASE" == "true" ]]; then
            github-release edit \
              --tag "${VERSION}" \
              --name "$VERSION: $BUILD_TAG" \
              --description "${CHANGES}\n\n${BUILD_URL}" \
              --pre-release
          else
            github-release edit \
              --tag "${VERSION}" \
              --name "$VERSION: $BUILD_TAG" \
              --description "${CHANGES}\n\n${BUILD_URL}"
          fi
        '''
      }
    }
  }

  post { 
    always { 
      sh 'git clean -ffdx -e ccache'
    }
  }
}
