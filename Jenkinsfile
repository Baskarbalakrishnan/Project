// Jenkinsfile
pipeline {
  agent any

  environment {
    IMAGE_TAG = "${env.BUILD_NUMBER}"   // unique tag per build
    IMAGE_NAME = "baskarb/aws-devops-app"
}

stage('Build Docker Image') {
    steps {
        sh 'docker build --no-cache -t $IMAGE_NAME:$IMAGE_TAG .'
    }
}

stage('Push to DockerHub') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
            sh 'echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin'
            sh 'docker push $IMAGE_NAME:$IMAGE_TAG'
        }
    }
}

stage('Terraform Init & Apply') {
    steps {
        dir('infra') {
            withCredentials([
                string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
            ]) {
                sh 'terraform init'
                sh 'terraform apply -auto-approve -var="aws_region=$AWS_REGION" -var="docker_image=$IMAGE_NAME:$IMAGE_TAG" -var="key_name=$KEY_NAME"'
            }
        }
    }
}

  parameters {
    string(name: 'KEY_NAME', defaultValue: 'Severs Key Pair BN', description: 'EC2 key pair name')
  }
}

