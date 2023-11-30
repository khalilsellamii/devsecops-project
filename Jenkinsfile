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
       
        

        stage('Deploy on AKS') {
            steps {

                sh '''
                   
                    cd kubernetes/
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


                    helm repo add jetstack https://charts.jetstack.io
                    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
                    helm repo update
                    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.crds.yaml
                    helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.13.1

                    kubectl apply -f cert-manager-tls/issuer.yaml
                    kubectl apply -f cert-manager-tls/certificate.yaml

                    kubectl apply -f cert-manager-tls/ingress.yaml
                '''
            }
        }


        stage('Monitoring Prometheus & Grafana') {
            steps {

                    sh '''

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
