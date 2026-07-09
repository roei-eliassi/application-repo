pipeline {
    agent {
        docker { 
            image 'python:3.9-slim' 
            // אנחנו צריכים שה-Agent יריץ פקודות דוקר, 
            // לכן אנחנו מעבירים לו את ה-Socket של המארח
            args '-v /var/run/docker.sock:/var/run/docker.sock' 
        }
    }
    
    environment {
        AWS_REGION = "il-central-1" // שנה ל-Region שלך
        ECR_REGISTRY = "123456789012.dkr.ecr.il-central-1.amazonaws.com" // שנה ל-ID שלך
        IMAGE_NAME = "my-calculator-app"
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
                    // כאן אנחנו משתמשים ב-Docker שנמצא על השרת המארח דרך ה-Socket
                    sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
                    
                    // בגלל שאין לנו AWS CLI בתוך ה-Agent של הפייתון, 
                    // נבצע את הלוגין דרך פקודת sh ישירה מול השרת המארח
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                    
                    sh "docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
                    sh "docker push ${ECR_REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
                }
            }
        }
    }
}

