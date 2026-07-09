pipeline {
    agent {
        docker { 
            image 'python:3.9-slim' 
        }
    }
    environment {
        PYTHONUSERBASE = "${env.WORKSPACE}/.local"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Install Dependencies') {
            steps {
                sh 'pip install --user -r requirements.txt'
            }
        }
        stage('Run Tests') {
            steps {
                sh 'python -m unittest discover tests'
            }
        }
    }
}
