import java.text.SimpleDateFormat

DOCKER_IMAGE    = ''
DOCKER_ARGS     = '--network=services_default'
DOCKER_REGISTRY = 'registry.n-os.org:5000'
DOCKER_REPO     = "${JOB_BASE_NAME}"

properties([
    parameters([
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Do you want to run the build with tests?')
    ])
])

node {
    try {
        pipeline()
    }
    catch(e) {
        setBuildStatus(e.toString().take(140), 'FAILURE')
        throw e
    }
    finally {
        cleanup()
    }
}


/*
  standard functions
  these functions below implement the standard docker image pipeline
  pipeline:
    tasks related to build
  cleanup:
    start docker cleanup job
*/
def pipeline() {

    stage('checkout git') {
        checkout scm
        setBuildStatus('In progress...', 'PENDING')
    }

    stage('build image') {
        def tag = getDockerTag()
        DOCKER_IMAGE = docker.build(
            "${DOCKER_REGISTRY}/${DOCKER_REPO}:${tag}",
            "--no-cache ${DOCKER_ARGS} ."
        )
    }

    stage('run tests') {
        testScript = new File('./test/run_tests.sh')
        if (testScript.exists() && !params.SKIP_TESTS) {
            DOCKER_IMAGE.inside("${DOCKER_ARGS} --entrypoint=") {
                sh '/usr/build/test/run_tests.sh'
            }
        }
    }

    stage('push image') {
        if (BRANCH_NAME == 'master') {
            DOCKER_IMAGE.push()
        }
        setBuildStatus('Success', 'SUCCESS')
    }
}

void cleanup() {
    stage('schedule cleanup') {
        build job: '../maintenance/starter', wait: false
    }
}

static String getDockerTag() {
    def shortHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    def date = new Date()
    def sdf = new SimpleDateFormat("yyyyMMddHHmmss")
    // semver in TAG_ID file or reference to ARG in Dockerfile
    def tagFile = new File('./TAG_ID')
    if (!tagFile.exists()) {
        return "${sdf.format(date)}.${shortHash}.b${BUILD_ID}"
    }
    def tagId = sh(script: 'cat ./TAG_ID', returnStdout: true).trim()
    if (tagId ==~ /^[A-Z_]+$/) {
        return sh(script: "awk -F= '/ARG ${tagId}=/{print \$2}' Dockerfile", returnStdout: true).trim()
    }
    else {
        return tagId
    }
}

void setBuildStatus(message, state) {
  def repoUrl = sh(script: 'git config --get remote.origin.url', returnStdout: true).trim()
  echo repoUrl
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: repoUrl],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}
