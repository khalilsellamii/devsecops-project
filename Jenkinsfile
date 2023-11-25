pipeline {
    agent any

    environment {
        DOCKER_HUB_PASSWORD = credentials('Dockerhub_pass')
        BUILD_TAG = "${BUILD_NUMBER}"

    }

    stages {
        stage('Checkout') {
            steps {
                // Check out your source code from your version control system, e.g., Git.
                sh 'rm -rf devsecops-project'
                sh 'git clone https://github.com/khalilsellamii/devsecops-project'
            }
        }

        stage('golang_unit_testing') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE BUT NOT FATAL'){
                    sh 'go install github.com/securego/gosec/v2/cmd/gosec@latest'
                    sh '/root/go/bin/gosec ./...'
                }
            }
        }

        stage('mysql-db-connection') {
            steps {
                sh 'cd src/ && go test'
            }
        }

        stage('sonarqube_scanning'){
            steps {
                sh 'echo this is for sonarqube sast scan!!'
            }
        }

    }
}