pipeline {

    
    
    
    agent { label 'master' }
    parameters {

    choice(name: 'TFC_PART_NUMBER_TO_BUILD',choices: 'tfc_j9500mtwx50tc_01a\nnextpart#',description: 'Which TFC Part to build')
    booleanParam(defaultValue: false, description: 'Clone All Repositories', name: 'CLONE')
    booleanParam(defaultValue: true, description: 'Build U-Boot', name: 'U_BOOT')
    booleanParam(defaultValue: true, description: 'Build Kernel', name: 'Kernel')
    choice(name: 'MAKE_TARGET' ,choices: 'buster-mate-arm64\nlinux-virtual', description: 'What makefile image to target')
    choice(name: 'BOARD_TARGET' ,choices: 'rockpro64\nrockpro', description: 'What board to build')   
    string(defaultValue: '1.0', description: 'Current version number', name: 'VERSION')
    text(defaultValue: '', description: 'A list of changes', name: 'CHANGES')
    string(defaultValue: 'rockpro64', description: 'Board target', name: 'BOARD_TARGETs')
    string(defaultValue: 'ThreeFiveDisplays-RockPro64', description: 'GitHub username or organization', name: 'GITHUB_USER')
    string(defaultValue: 'linux-build', description: 'GitHub repository', name: 'GITHUB_REPO')
    }
    stages {
        stage('display') {
            steps {
                echo "Setting Parameters"
            }
        }
}
}

node('docker && linux-build') {
  timestamps {
    wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
      stage('Environment') {
        checkout scm
          def environment = docker.build('rockpro64/linux-build:focal')
          
        environment.inside("--privileged -u 0:0") {
          withEnv([
            "USE_CCACHE=true",
            "RELEASE_NAME=$VERSION",
            "RELEASE=$BUILD_NUMBER",
          ]) {
              stage('Prepare') {
                sh '''#!/bin/bash
                  set -xe
                  export CCACHE_DIR=$WORKSPACE/ccache
                  ccache -M 0 -F 0
                 repo init -u https://github.com/ThreeFiveDisplays-RockPro64/linux-manifests -b rockpro64 -m default.xml
                 
                 repo sync -j1 --fail-fast --force-sync
                 #repo sync -j 20 -c --force-sync
                '''
              }

              stage('Images') {
                sh '''#!/bin/bash
                  export USER=jenkins
                  set -xe
                  export CCACHE_DIR=$WORKSPACE/ccache
                  export ARCH=arm64
                  export CROSS_COMPILE=aarch64-linux-gnu-
                  export ARCH=arm64
                  
                  if ($Kernel) then
                    #cd kernel  
                    cd linux-build
    
                    make -j$(nproc) $MAKE_TARGET
                    #make focal mate arm64 rockpro64
                    #make rk3399_linux_defconfig
                    #make all
                    #make dtbs  
                    #make dtbs_install 
                    #make modules
                    #make INSTALL_MOD_PATH=output modules_install
                    cd ..
                  fi
                  if ($U_BOOT) then
                    cd u-boot 
                    make rockpro-rk3399_defconfig                
                    make
                    cd..
                    cp u-boot/u-boot-dtb.bin uboot_builder/rk3399
                    cd uboot_builder/rk3399/
                     ./make-uboot.sh
                     cd ..
                   fi
                '''
              }
          }
        }
      }
    }
  }
}
