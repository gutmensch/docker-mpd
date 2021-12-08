DOCKER_IMAGE = ''

node {
    
    environment { 
        DOCKER_ARGS = '--no-cache --network=services_default'
        DOCKER_REGISTRY = 'registry.n-os.org:5000'
        DOCKER_REPO = env.JOB_BASE_NAME
        DOCKER_COMMIT_TAG = env.GIT_COMMIT.take(7)
    }

    stage('checkout') {
        checkout scm
    }
 
    stage('image build') {
        DOCKER_IMAGE = docker.build("${env.DOCKER_REGISTRY}/${env.DOCKER_REPO}:${env.BUILD_ID}", "${env.DOCKER_ARGS} .")
    }

    stage('run tests') {
        DOCKER_IMAGE.inside("${env.DOCKER_ARGS} --entrypoint=") {
            sh 'echo foobar'
            sh 'ls -l'
        }
    }

    stage('push image') {
        DOCKER_IMAGE.push()
        DOCKER_IMAGE.push('latest')
    }

    stage('schedule cleanup') {
        build job: '../Cleanup/dangling-container-cleanup', wait: false
    }
}
