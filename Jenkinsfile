pipeline {
    agent {
        docker { 
            image 'python:3.9-slim' 
        }
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }
        stage('Run Tests') {
            steps {
                sh 'python -m unittest discover tests'
            }
        }
    }
}
