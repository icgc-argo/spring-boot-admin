def commit = "UNKNOWN"

pipeline {
    agent {
        kubernetes {
            label 'spring-boot-admin-executor'
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: helm
    image: alpine/helm:2.12.3
    command:
    - cat
    tty: true
  - name: docker
    image: docker:18-git
    tty: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-sock
  - name: java
    image: openjdk:11-jdk-slim
    command:
    - cat
    tty: true
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
      type: File
"""
        }
    }
    stages {
        stage('Test') {
            // TODO: integration test
            steps {
                container('java') {
                    sh "./mvnw verify"
                }
            }
        }
        stage('Build') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId:'8d0aaceb-2a19-4f92-ae37-5b61e4c0feb8', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh 'docker login -u $USERNAME -p $PASSWORD'
                    }
                    script {
                        commit = sh(returnStdout: true, script: 'git describe --always').trim()
                    }

                    // DNS error if --network is default
                    sh "docker build --network=host . -t icgcargo/spring-boot-admin:${commit}"

                    sh "docker push icgcargo/spring-boot-admin:${commit}"
                }
            }
        }
        // stage('Deploy') {
        //     steps {
        //         container('helm') {
        //             withCredentials([file(credentialsId:'4ed1e45c-b552-466b-8f86-729402993e3b', variable: 'KUBECONFIG')]) {
        //                 sh 'helm init --client-only'
        //                 sh 'helm ls --kubeconfig $KUBECONFIG'
        //                 sh 'helm repo add overture https://overture-stack.github.io/charts/'
		// 				// help upgrade <release name> <chart name>  <other flags....>
		// 				sh "helm upgrade spring-boot-admin-qa overture/spring-boot-admin --reuse-values --set image.tag=${commit}"
        //             }
        //         }
        //     }
        // }
    }
    post {
        always {
            junit "**/TEST-*.xml"
        }
    }
}
