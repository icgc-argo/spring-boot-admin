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


    environment {
        gitHubRegistry = 'ghcr.io'
        gitHubRepo = 'icgc-argo/spring-boot-admin'
        gitHubImageName = "${gitHubRegistry}/${gitHubRepo}"
        PUBLISH_IMAGE = false

        commit = sh(
            returnStdout: true,
            script: 'git describe --always'
        ).trim()
    }

    parameters {
        booleanParam(
            name: 'PUBLISH_IMAGE',
            defaultValue: "${env.PUBLISH_IMAGE}",
            description: 'Publishes an image with {git commit} tag'
        )
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('Run tests') {
            // TODO: integration test
            steps {
                container('java') {
                    sh "./mvnw verify"
                }
            }
        }

        stage('Builds image') {
            steps {
                container('docker') {
                    sh "docker build --network=host -f Dockerfile . -t ${gitHubImageName}:${commit}"
                }
            }
        }

        stage('Publish images') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'main'
                    expression { return params.PUBLISH_IMAGE }
                }
            }
            steps {
                container('docker') {
                    withCredentials([usernamePassword(
                        credentialsId:'argoContainers',
                        passwordVariable: 'PASSWORD',
                        usernameVariable: 'USERNAME'
                    )]) {
                        sh "docker login ${gitHubRegistry} -u $USERNAME -p $PASSWORD"
                        sh "docker tag ${gitHubImageName}:${commit} ${gitHubImageName}:${commit}"
                        sh "docker push ${gitHubImageName}:${commit}"
                    }
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
        unsuccessful {
            // i used node   container since it has curl already
            container('node') {
                script {
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'develop') {
                        withCredentials([string(credentialsId: 'JenkinsFailuresSlackChannelURL', variable: 'JenkinsFailuresSlackChannelURL')]) {
                            sh "curl -X POST -H 'Content-type: application/json' --data '{\"text\":\"Build Failed: ${env.JOB_NAME} [${env.BUILD_NUMBER}] (${env.BUILD_URL}) \"}' ${JenkinsFailuresSlackChannelURL}"
                        }
                    }
                }
            }
        }
        fixed {
            container('node') {
                script {
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'develop') {
                        withCredentials([string(credentialsId: 'JenkinsFailuresSlackChannelURL', variable: 'JenkinsSucessesSlackChannelURL')]) {
                            sh "curl -X POST -H 'Content-type: application/json' --data '{\"text\":\"Build Fixed: ${env.JOB_NAME} [${env.BUILD_NUMBER}] (${env.BUILD_URL}) \"}' ${JenkinsSuccessesSlackChannelURL}"
                        }
                    }
                }
            }
        }
        always {
            junit "**/TEST-*.xml"
        }
    }
}
