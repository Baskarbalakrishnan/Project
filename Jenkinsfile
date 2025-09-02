// Jenkinsfile
pipeline {
  agent any

  environment {
    IMAGE_NAME = "baskarb"
    AWS_REGION = "ap-south-1"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME .'
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
          sh 'echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin'
          sh 'docker push $IMAGE_NAME'
        }
      }
    }

    stage('Terraform Init & Apply') {
      steps {
        dir('infra') {
          withCredentials([string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                           string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
            sh 'terraform init'
            sh 'terraform apply -auto-approve -var="aws_region=$AWS_REGION" -var="docker_image=$IMAGE_NAME" -var="key_name=$KEY_NAME"'
          }
        }
      }
      environment {
        // Populate KEY_NAME via Jenkins parameter or environment variable
        KEY_NAME = "${params.KEY_NAME ?: 'Server Key Pair BN'}"
      }
    }
  }

  parameters {
    string(name: 'KEY_NAME', defaultValue: 'Server Key Pair BN', description: 'EC2 key pair name')
  }
}
