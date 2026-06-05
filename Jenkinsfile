pipeline {
    agent any
    
    environment {
        DOCKER_HUB_USER = "kamleshdv"
        IMAGE_NAME = "ecommerce-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        
        // 1. GITHUB SE CODE LANA
        stage('Checkout from GitHub') {
            steps {
                echo '📦 Pulling code from GitHub...'
                git url: 'https://github.com/kamleshdv/e-commerce-application.git', branch: 'main'
                echo '✅ Code pulled successfully'
            }
        }
        
        // 2. SONARQUBE ANALYSIS
        stage('SonarQube Code Analysis') {
            steps {
                echo '🔍 Running SonarQube analysis...'
                withSonarQubeEnv('sonarqube-server') {
                    sh 'sonar-scanner'
                }
                echo '✅ SonarQube analysis completed'
            }
        }
        
        // 3. QUALITY GATE CHECK
        stage('Quality Gate Check') {
            steps {
                echo '⏳ Waiting for quality gate results...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
                echo '✅ Quality Gate PASSED'
            }
        }
        
        // 4. DOCKER IMAGE BUILD
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                """
                echo '✅ Docker image built'
            }
        }
        
        // 5. TRIVY SECURITY SCAN
        stage('Trivy Security Scan') {
            steps {
                echo '🔒 Scanning image for vulnerabilities...'
                sh """
                    trivy image --severity HIGH,CRITICAL --exit-code 1 ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                """
                echo '✅ Trivy scan PASSED'
            }
        }
        
        // 6. PUSH TO DOCKER HUB (✅ FIXED - latest tag ka error nahi aayega)
        stage('Push to Docker Hub') {
            steps {
                echo '☁️ Pushing image to Docker Hub...'
                withCredentials([usernamePassword(
                    credentialsId: 'DOCKER_HUB_PASS',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
                        
                        # Push with build number tag
                        docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                        
                        # Tag as 'latest' and push
                        docker tag ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest
                        docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest
                        
                        echo "✅ Pushed: ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                        echo "✅ Pushed: ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                    """
                }
                echo '✅ Image pushed to Docker Hub!'
            }
        }
        
    }
    
    post {
        success {
            echo """
                ┌─────────────────────────────────────────────────────────┐
                │              🎉 PIPELINE SUCCESSFUL 🎉                  │
                ├─────────────────────────────────────────────────────────┤
                │  Image: ${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}   │
                │  SonarQube: ✅ Quality Gate Passed                      │
                │  Trivy: ✅ No Critical Vulnerabilities                  │
                └─────────────────────────────────────────────────────────┘
            """
        }
        failure {
            echo """
                ┌─────────────────────────────────────────────────────────┐
                │              ❌ PIPELINE FAILED ❌                      │
                ├─────────────────────────────────────────────────────────┤
                │  Check logs for:                                       │
                │  - SonarQube quality gate failed?                      │
                │  - Trivy found vulnerabilities?                        │
                │  - Docker build error?                                 │
                └─────────────────────────────────────────────────────────┘
            """
        }
    }
}
