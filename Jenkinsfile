DOCKER_IMAGE = ''
DOCKER_ARGS = '--network=services_default'
DOCKER_REGISTRY = 'registry.n-os.org:5000'
DOCKER_REPO = "${JOB_BASE_NAME}"

properties([
    parameters([
        string(defaultValue: '3.11', name: 'ALPINE_VERSION', description: "Alpine version upstream docker image"),
        string(defaultValue: '0.20.23', name: 'MPD_VERSION', description: "MPD version to build"),
        string(defaultValue: 'v1.22.1.0', name: 'S6_OVERLAY_VERSION', description: "S6 overlay version in runner image"),
        string(defaultValue: '0.1~r495-1', name: 'MPC_VERSION', description: "Musepack library version to build"),
        string(defaultValue: '0.3.6', name: 'AUDIOFILE_VERSION', description: "Audiofile library version to build"),
        string(defaultValue: '0.4.0', name: 'TWOLAME_VERSION', description: "Twolame library version to build"),
        string(defaultValue: '0.2.1', name: 'OPUSENC_VERSION', description: "Opusenc library version to build"),
        string(defaultValue: '1.3.1', name: 'OPUS_VERSION', description: "Opus library version to build"),
        string(defaultValue: '1.4.3', name: 'CHROMAPRINT_VERSION', description: "Chromaprint library version to build"),
        string(defaultValue: '0.4.3', name: 'WILDMIDI_VERSION', description: "Wildmidi library version to build")
    ])
])

node {
    try {
        pipeline()
    }
    catch(e) {
        throw e
    }
    finally {
        cleanup()
    }
}

def pipeline() {
    stage('checkout') {
        checkout scm
    }

    stage('image build') {
        DOCKER_IMAGE = docker.build(
            "${DOCKER_REGISTRY}/${DOCKER_REPO}:${MPD_VERSION}",
            "--build-arg ALPINE_VERSION=${ALPINE_VERSION} " +
            "--build-arg MPD_VERSION=${MPD_VERSION} " +
            "--build-arg S6_OVERLAY_VERSION=${S6_OVERLAY_VERSION} " +
            "--build-arg MPC_VERSION=${MPC_VERSION} " +
            "--build-arg AUDIOFILE_VERSION=${AUDIOFILE_VERSION} " +
            "--build-arg TWOLAME_VERSION=${TWOLAME_VERSION} " +
            "--build-arg OPUSENC_VERSION=${OPUSENC_VERSION} " +
            "--build-arg OPUS_VERSION=${OPUS_VERSION} " +
            "--build-arg CHROMAPRINT_VERSION=${CHROMAPRINT_VERSION} " +
            "--build-arg WILDMIDI_VERSION=${WILDMIDI_VERSION} " +
            "--no-cache ${DOCKER_ARGS} ."
        )
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
}

def cleanup() {
    stage('schedule cleanup') {
        build job: '../Maintenance/dangling-container-cleanup', wait: false
    }
}
