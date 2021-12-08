/*
pipeline {
    agent {
        docker { image 'node:14-alpine' }
    }
    stages {
        stage('Test') {
            steps {
                sh 'node --version'
            }
        }
    }
}
*/

node {
    checkout scm

    def dockerArgs = '--network=services_default'

    def testImage = docker.build("registry.n-os.org:5000/mpd:${env.BUILD_ID}", "${dockerArgs} .")

    testImage.inside("${dockerArgs} --entrypoint=") {
        sh 'echo foobar'
        sh 'ls -l'
    }
    
    testImage.push()
    testImage.push('latest')
}
