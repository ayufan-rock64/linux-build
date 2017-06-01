/**
properties([
  parameters([
    string(defaultValue: '1.0', description: 'Current version number', name: 'VERSION'),
    text(defaultValue: '', description: 'A list of changes', name: 'CHANGES'),
    booleanParam(defaultValue: false, description: 'If build should be marked as pre-release', name: 'PRERELEASE'),
    string(defaultValue: 'ayufan-pine64', description: 'GitHub username or organization', name: 'GITHUB_USER'),
    string(defaultValue: 'build-pine64-image', description: 'GitHub repository', name: 'GITHUB_REPO'),
    booleanParam(defaultValue: true, description: 'Whether to upload to Github for release or not', name: 'GITHUB_UPLOAD'),
    string(devaultValue: 'all', description: 'What makefile build type to target', name: 'MAKE_TARGET'),
  ])
])
*/

node('docker && linux-build') {
  timestamps {
    wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
      stage "Environment"
      checkout scm

      def environment = docker.build('build-environment:build-pine64-image', 'build-environment')

      environment.inside("--privileged -u 0:0") {
        withEnv([
          "USE_CCACHE=true",
          "RELEASE_NAME=$VERSION",
          "RELEASE=$BUILD_NUMBER"
        ]) {
            stage 'Prepare'
            sh '''#!/bin/bash
              set +xe
              export CCACHE_DIR=$WORKSPACE/ccache
              ccache -M 0 -F 0
              git clean -ffdx -e ccache
            '''

            stage 'Build'
            sh '''#!/bin/bash
              set +xe
              export CCACHE_DIR=$WORKSPACE/ccache
              make -j4 $MAKE_TARGET
            '''
        }
  
        withEnv([
          "VERSION=$VERSION",
          "CHANGES=$CHANGES",
          "PRERELEASE=$PRERELEASE",
          "GITHUB_USER=$GITHUB_USER",
          "GITHUB_REPO=$GITHUB_REPO"
        ]) {
          stage 'Release'
          if (GITHUB_UPLOAD == true) { 
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
          else
          {
             echo 'Flagged as no upload release job'
          }
        }
      }
    }
  }
}
