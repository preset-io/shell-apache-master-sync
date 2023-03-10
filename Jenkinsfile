#!/usr/bin/env groovy
properties([
        /* Only keep the 20 most recent builds. */
        [$class  : 'BuildDiscarderProperty',
         strategy: [$class: 'LogRotator', numToKeepStr: '20']],
        pipelineTriggers([
            cron('H H * * *'), // Run sync daily
        ])
])

podTemplate(
    activeDeadlineSeconds: 1200,
    imagePullSecrets: ['preset-pull'],
    containers: [
        containerTemplate(
            alwaysPullImage: true,
            name: 'ci',
            image: 'preset/ci:latest',
            ttyEnabled: true,
            command: 'cat',
            resourceRequestCpu: '1000m',
            resourceLimitCpu: '2000m',
            resourceRequestMemory: '4000Mi',
            resourceLimitMemory: '6000Mi',
        )
    ],
    volumes: [
        hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
    ]
) {
    node(POD_LABEL) {
        stage('Clone Source') {
            checkout scm
        }

        container('ci') {
            withCredentials(bindings: [sshUserPrivateKey(
                    credentialsId: 'gh-preset-machine-ssh-pk',
                    keyFileVariable: 'SSH_KEY_GITHUB')]) {
                
                stage('Configure Git') {
                    sh "bash ./configure_git.sh"
                    sh 'git config --global user.email "machine@preset.io"'
                    sh 'git config --global user.name "Preset Machine"'
                }

                stage('Clone superset-shell') {
                    sh "git clone git@github.com:preset-io/superset-shell.git superset-shell"
                }

                stage('Init superset submodule') {
                    dir('superset-shell') {
                        sh "git submodule init && git submodule update"
                    }
                }

                stage('Update file permissions') {
                    sh "chmod 777 -R ./superset-shell"
                }

                stage('Point submodule at latest master') {
                    dir('superset-shell/superset') {
                        sh "git stash"
                        sh "git checkout master"
                    }
                }

                stage('Commit and push to shell-apache-master-sync') {
                    dir('superset-shell') {
                        sh "git status"
                        sh "git checkout -b shell-apache-master-sync"
                        sh 'git add superset'
                        sh 'git commit -m "Point superset at latest master"'
                        sh 'git push -f origin shell-apache-master-sync'
                    }
                }
            }
        }
    }
}