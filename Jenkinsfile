DOCKER_IMAGE = ''
DOCKER_ARGS = '--network=services_default'
DOCKER_REGISTRY = 'registry.n-os.org:5000'
DOCKER_REPO = "${JOB_BASE_NAME}"

node {
    stage('checkout') {
        checkout scm
    }
 
    stage('image build') {
        DOCKER_IMAGE = docker.build("${DOCKER_REGISTRY}/${DOCKER_REPO}:${BUILD_ID}", "--no-cache ${DOCKER_ARGS} .")
    }

    stage('run tests') {
        DOCKER_IMAGE.inside("${DOCKER_ARGS} --entrypoint=") {
            sh 'bats /usr/build/test/*.bats'
        }
    }

    stage('push image') {
        def shortHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        DOCKER_IMAGE.push()
        DOCKER_IMAGE.push(shortHash)
    }

    stage('schedule cleanup') {
        build job: '../Cleanup/dangling-container-cleanup', wait: false
    }
}
