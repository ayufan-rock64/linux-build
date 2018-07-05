/**
properties([
  parameters([
    string(defaultValue: '1.0', description: 'Current version number', name: 'VERSION'),
    text(defaultValue: '', description: 'A list of changes', name: 'CHANGES'),
    choice(choices: 'all\njessie-minimal-rock64\njessie-openmediavault-rock64\nstretch-minimal-rock64\nxenial-i3-rock64\nxenial-mate-rock64\nxenial-minimal-rock64\nlinux-virtual', description: 'What makefile image to target', name: 'MAKE_TARGET')
    booleanParam(defaultValue: true, description: 'Whether to upload to Github for release or not', name: 'GITHUB_UPLOAD'),
    booleanParam(defaultValue: false, description: 'If build should be marked as pre-release', name: 'GITHUB_PRERELEASE'),
    string(defaultValue: 'rock64 rockpro64', description: 'Board targets', name: 'BOARD_TARGETs'),
    string(defaultValue: 'ayufan-rock64', description: 'GitHub username or organization', name: 'GITHUB_USER'),
    string(defaultValue: 'linux-build', description: 'GitHub repository', name: 'GITHUB_REPO'),
  ])
])
*/

node('docker && linux-build') {
  timestamps {
    wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
      stage('Environment') {
        checkout scm

        def environment = docker.image('ayufan/rock64-dockerfiles:x86_64')

        environment.inside("--privileged -u 0:0") {
          withEnv([
            "USE_CCACHE=true",
            "RELEASE_NAME=$VERSION",
            "RELEASE=$BUILD_NUMBER",
            "BOARD_TARGETs=$BOARD_TARGETs"
          ]) {
              stage('Prepare') {
                sh '''#!/bin/bash
                  set -xe
                  export CCACHE_DIR=$WORKSPACE/ccache
                  ccache -M 0 -F 0
                  git clean -ffdx -e ccache
                '''
              }

              stage('Images') {
                sh '''#!/bin/bash
                  set -xe
                  export CCACHE_DIR=$WORKSPACE/ccache
                  for i in $BOARD_TARGETs; do
                    make -j$(nproc) BOARD_TARGET=$i $MAKE_TARGET
                  done
                '''
              }
          }

          withEnv([
            "VERSION=$VERSION",
            "CHANGES=$CHANGES",
            "GITHUB_PRERELEASE=$GITHUB_PRERELEASE",
            "GITHUB_USER=$GITHUB_USER",
            "GITHUB_REPO=$GITHUB_REPO"
          ]) {
            stage('Release') {
              if (params.GITHUB_UPLOAD) {
                sh '''#!/bin/bash
                  set -xe
                  shopt -s nullglob

                  github-release release \
                      --tag "${VERSION}" \
                      --name "$VERSION: $BUILD_TAG" \
                      --description "${CHANGES}\n\n${BUILD_URL}" \
                      --draft

                  github-release upload \
                      --tag "${VERSION}" \
                      --name "manifest.xml" \
                      --file "manifest.xml"

                  for file in *.xz; do
                    github-release upload \
                        --tag "${VERSION}" \
                        --name "$(basename "$file")" \
                        --file "$file" &
                  done

                  wait

                  if [[ "$GITHUB_PRERELEASE" == "true" ]]; then
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
              } else {
                 echo 'Flagged as an no upload release job'
              }
            }
          }
        }
      }
    }
  }
}
