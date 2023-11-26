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
                script{
                    try {
                        sh '/root/go/bin/gosec ./...'
                    }  catch (Exception e) {
                        echo "Gosec test failed, but continuing the pipeline..."
                    }
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

        stage('Build Docker Image') {
            steps {
                // Build your Docker image. Make sure to specify your Dockerfile and any other build options.
                sh 'docker build -t khalilsellamii/projet-devops:$BUILD_TAG .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                // Log in to Docker Hub using your credentials
                sh 'docker login -u khalilsellamii -p $DOCKER_HUB_PASSWORD'

                // Push the built image to Docker Hub
                sh 'docker push khalilsellamii/projet-devops:$BUILD_TAG'
            }
        }

    }

    }
