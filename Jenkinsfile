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
                script {

                    sh '''
                       
                       cd terraform/
    
                       terraform fmt && terraform init
    
                       terraform plan && terraform apply --auto-approve 
    
                       terraform output kube_config > kubeconfig && cat kubeconfig 
    
                       cd ../
                    '''
                    def kubeconfig = sh(script: 'terraform output -raw kube_config', returnStdout: true).trim()
                    env.KUBECONFIG = kubeconfig

                }
            }
        }

        stage('Deploy on AKS') {
            steps {

                sh '''
                   
                    cd kubernetes/
                    export KUBECONFIG=$KUBECONFIG
                    sleep 5
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

        stage('Helm & Cert-manager & Nginx-Ingress') {
            steps {

                sh '''

                    export KUBECONFIG=$KUBECONFIG

                    helm repo add jetstack https://charts.jetstack.io
                    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
                    helm repo update
                    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.crds.yaml
                    helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.13.1
                //    helm install app-ingress ingress-nginx/ingress-nginx --namespace ingress --create-namespace --set controller.replicaCount=2 --set controller.nodeSelector.'kubernetes\.io/os'=linux --set defaultBackend.nodeSelector.'kubernetes\.io/os'=linux

                // apply the crd offered by cert-manager: issuer which will be selfsigned + x509 ssl/tls certificate

                    kubectl apply -f cert-manager-tls/issuer.yaml
                    kubectl apply -f cert-manager-tls/certificate.yaml

                // Now, apply the actual ingress ressource that will expose our golang app service through the nginx-ingress controller
                    kubectl apply -f cert-manager-tls/ingress.yaml
                '''
            }
        }


        stage('Monitoring Prometheus & Grafana') {
            steps {

                    sh '''

                        export KUBECONFIG=$KUBECONFIG
                        kubectl create ns monitoring 
                        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
                        helm repo update
                        helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring
                        kubectl get all,secret,configMap --namespace monitoring           

                    '''


                
            }
        }                    

    }

    }
