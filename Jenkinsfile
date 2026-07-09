pipeline {
    agent {
        docker { 
            image 'python:3.9-slim' 
            args '-v /var/run/docker.sock:/var/run/docker.sock' 
        }
    }
    
    environment {
        AWS_REGION = "il-central-1" 
        ECR_REGISTRY = "992382545251.dkr.ecr.il-central-1.amazonaws.com" 
        IMAGE_NAME = "roeicicd"
        PYTHONUSERBASE = "${env.WORKSPACE}/.local"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install & Test') {
            steps {
                sh 'pip install --user -r requirements.txt'
                sh 'python -m unittest discover tests'
            }
        }

        stage('Build & Push to ECR') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                    sh "docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
                    sh "docker push ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
                }
            }
        }
    }
}
