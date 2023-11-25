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
                sh 'rm -rf Jekins_pipeline'
                sh 'git clone https://github.com/khalilsellamii/Jekins_pipeline'
            }
        }

        stage('Testing') {
            steps {
                sh 'python3 src/test.py'
            }
        }

        