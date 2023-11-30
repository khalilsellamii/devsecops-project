pipeline {
    agent any

    environment {
        DOCKER_HUB_PASSWORD = credentials('Dockerhub_pass')
        BUILD_TAG = "${BUILD_NUMBER}"
        // These variables are for terraform to connect to Azure account
        ARM_SUBSCRIPTION_ID = credentials('ARM_SUBSCRIPTION_ID')
        ARM_CLIENT_ID = credentials('ARM_CLIENT_ID')
        ARM_CLIENT_SECRET = credentials('ARM_CLIENT_SECRET') 
        ARM_TENANT_ID = credentials('ARM_TENANT_ID')

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
                script {
                    try {
                         sh 'cd src/ && go test' 
                    } catch (Exception e) {
                        echo "Error connecting to the database at this url, but continuing the pipeline..."
                    }
                }               
            }
        }

        stage('Build Docker Image') {
            steps {
                // Build your Docker image. Make sure to specify your Dockerfile and any other build options.
                sh 'docker build -t khalilsellamii/projet-devops:v0.test .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                // Log in to Docker Hub using your credentials
                sh 'docker login -u khalilsellamii -p $DOCKER_HUB_PASSWORD'

                // Push the built image to Docker Hub
                sh 'docker push khalilsellamii/projet-devops:v0.test'
            }
        }

        stage('Provision AKS cluster with TF') {
            steps {

                sh '''
                   
                   cd terraform/

                   terraform fmt && terraform init

                   terraform plan && terraform apply --auto-approve 

                   terraform output kube_config > kubeconfig && cat kubeconfig 

                   cd ../
                '''
            }
        }  

        stage('Deploy on AKS') {
            steps {

                sh '''
                   
                    cd kubernetes/

                    kubectl apply -f db-configmap.yaml
                    kubectl apply -f db-pass-secret.yaml
                    kubectl apply -f mysql-stfulset.yaml
                    sleep 10
                    kubectl apply -f mysql-svc.yaml
                    kubectl apply -f my-golang-app-deployment.yaml
                    sleep 10
                    kubectl apply -f golang-svc.yaml

                    sleep 15

                    kubectl get all,pv,pvc,storageClass,secret,cm

                '''
            }
        }              

    }

    }
