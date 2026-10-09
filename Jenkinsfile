// Author: Poojitha Nasappa
// SWE645 Assignment 2 - CI/CD pipeline: builds the Docker image, pushes it to Docker Hub, and redeploys it on the AKS Kubernetes cluster.
pipeline {
  agent any
  environment {
    PATH  = "/opt/homebrew/bin:/usr/local/bin:/Applications/Docker.app/Contents/Resources/bin:${env.PATH}"
    IMAGE = "poojitha0716/swe645-hw2"
    TAG   = "build-${env.BUILD_NUMBER}"
  }
  triggers {
    pollSCM('* * * * *')
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build & Push Image') {
      steps {
        sh 'docker buildx build --platform linux/amd64,linux/arm64 -t $IMAGE:$TAG -t $IMAGE:latest --push .'
      }
    }
    stage('Deploy to Kubernetes') {
      steps {
        sh 'kubectl set image deployment/swe645-deployment swe645=$IMAGE:$TAG'
        sh 'kubectl rollout status deployment/swe645-deployment --timeout=180s'
        sh 'kubectl get pods -o wide'
      }
    }
  }
}
