/**
properties([
  parameters([
    string(defaultValue: '1.0', description: 'Current version number', name: 'VERSION'),
    text(defaultValue: '', description: 'A list of changes', name: 'CHANGES'),
    booleanParam(defaultValue: false, description: 'If build should be marked as pre-release', name: 'PRERELEASE'),
    string(defaultValue: 'ayufan-rock64', description: 'GitHub username or organization', name: 'GITHUB_USER'),
    string(defaultValue: 'linux-build', description: 'GitHub repository', name: 'GITHUB_REPO'),
  ])
])
*/

node('docker && linux-build') {
  timestamps {
    wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
      stage "Environment"
      checkout scm

      def environment = docker.build('build-environment:build-rock64-image', 'environment')

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

            stage 'Sources'
            sh '''#!/bin/bash
              set -xe

              export HOME=$WORKSPACE
              export USER=jenkins

              repo init -u https://github.com/ayufan-rock64/manifests -b default --depth=1

              repo sync -j 20 -c --force-sync
            '''

            stage 'U-boot'
            sh '''#!/bin/bash
              set +xe
              export CCACHE_DIR=$WORKSPACE/ccache
              make u-boot
            '''

            stage 'Kernel'
            sh '''#!/bin/bash
              set +xe
              export CCACHE_DIR=$WORKSPACE/ccache
              make kernel
            '''

            stage 'Images'
            sh '''#!/bin/bash
              set +xe
              export CCACHE_DIR=$WORKSPACE/ccache
              make
            '''
        }
  
        withEnv([
          "VERSION=$VERSION",
          "CHANGES=$CHANGES",
          "PRERELEASE=$PRERELEASE",
          "GITHUB_USER=$GITHUB_USER",
          "GITHUB_REPO=$GITHUB_REPO"
        ]) {
          stage 'Freeze'
          sh '''#!/bin/bash
            # use -ve, otherwise we could leak GITHUB_TOKEN...
            set -ve
            shopt -s nullglob

            export HOME=$WORKSPACE
            export USER=jenkins

            repo manifest -r -o manifest.xml
          '''

          stage 'Release'
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
  }
}
