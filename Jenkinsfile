def commit = "UNKNOWN"
def gitHubRegistry = "ghcr.io"
def gitHubRepo = "icgc-argo/spring-boot-admin"

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
    env:
    - name: DOCKER_HOST
      value: tcp://localhost:2375
    - name: HOME
      value: /home/jenkins/agent
  - name: java
    image: openjdk:11-jdk-slim
    command:
    - cat
    tty: true
    env:
    - name: DOCKER_HOST
      value: tcp://localhost:2375
  - name: dind-daemon
    image: docker:18.06-dind
    securityContext:
      privileged: true
      runAsUser: 0
    volumeMounts:
    - name: docker-graph-storage
      mountPath: /var/lib/docker
  securityContext:
    runAsUser: 1000
  volumes:
  - name: docker-graph-storage
    emptyDir: {}
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
                    withCredentials([usernamePassword(credentialsId:'argoContainers', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh "docker login ${gitHubRegistry} -u $USERNAME -p $PASSWORD"
                    }
                    script {
                        commit = sh(returnStdout: true, script: 'git describe --always').trim()
                    }

                    // DNS error if --network is default
                    sh "docker build --network=host . -t ${gitHubRegistry}/${gitHubRepo}:${commit}"

                    sh "docker push ${gitHubRegistry}/${gitHubRepo}:${commit}"
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
