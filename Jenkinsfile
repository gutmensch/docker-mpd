DOCKER_IMAGE = ''
DOCKER_ARGS = '--no-cache --network=services_default'
DOCKER_REGISTRY = 'registry.n-os.org:5000'
DOCKER_REPO = "${JOB_BASE_NAME}"
SHORT_COMMIT = ''

node {
    stage('checkout') {
        checkout scm
        //SHORT_COMMIT = "${GIT_COMMIT.take(7)}"
    }
 
    stage('image build') {
        DOCKER_IMAGE = docker.build("${DOCKER_REGISTRY}/${DOCKER_REPO}:${BUILD_ID}", "${DOCKER_ARGS} .")
    }

    stage('run tests') {
        DOCKER_IMAGE.inside("${DOCKER_ARGS} --entrypoint=") {
            sh 'echo foobar'
            sh 'ls -l'
        }
    }

    stage('push image') {
        DOCKER_IMAGE.push()
        //DOCKER_IMAGE.push(SHORT_COMMIT)
    }

    stage('schedule cleanup') {
        build job: '../Cleanup/dangling-container-cleanup', wait: false
    }
}
