// Declarative CI/CD pipeline for DevOps Lab 1.
// Checkout -> Verify Tools -> Build -> Unit Test -> Package -> Deploy -> Smoke Test
pipeline {
    agent any

    options {
        timestamps()
        timeout(time: 15, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
    }

    // A local Jenkins cannot receive GitHub webhooks, so poll the repo every ~2 minutes.
    triggers {
        pollSCM('H/2 * * * *')
    }

    environment {
        APP_VERSION = "1.0.${BUILD_NUMBER}"
        ARTIFACT    = "dist/sample-app-${APP_VERSION}.tar.gz"
        DEPLOY_DIR  = "${JENKINS_HOME}/deployments/sample-app"
        PORT        = '8000'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git log -1 --pretty=format:"Commit %h by %an: %s"'
            }
        }

        stage('Verify Tools') {
            steps {
                sh '''
                    git --version
                    python3 --version
                    curl --version | head -n 1
                '''
            }
        }

        stage('Build') {
            steps {
                sh '''
                    rm -rf build dist reports
                    mkdir -p build dist reports
                    python3 -m py_compile app/app.py tests/test_app.py
                    echo "Syntax check passed for all Python sources"
                '''
            }
        }

        stage('Unit Test') {
            steps {
                sh '''
                    if python3 -m unittest discover -s tests -v > reports/test-report.txt 2>&1; then
                        cat reports/test-report.txt
                    else
                        cat reports/test-report.txt
                        exit 1
                    fi
                '''
            }
        }

        stage('Package') {
            steps {
                sh '''
                    cp -r app build/
                    echo "${APP_VERSION}" > build/VERSION
                    tar -czf "${ARTIFACT}" -C build .
                    ls -lh dist/
                '''
                archiveArtifacts artifacts: 'dist/*.tar.gz', fingerprint: true
            }
        }

        stage('Deploy') {
            environment {
                // Stops Jenkins from killing the background app when the build ends.
                JENKINS_NODE_COOKIE = 'dontKillMe'
            }
            steps {
                sh 'bash scripts/deploy.sh "${ARTIFACT}" "${APP_VERSION}"'
            }
        }

        stage('Smoke Test') {
            steps {
                sh 'bash scripts/smoke_test.sh "${APP_VERSION}"'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'reports/*.txt', allowEmptyArchive: true
        }
        success {
            echo "Build ${APP_VERSION} deployed: http://localhost:${PORT}/health"
        }
        failure {
            echo "Pipeline failed - check the stage logs above."
        }
    }
}
