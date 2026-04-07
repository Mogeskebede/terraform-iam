pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        SECRET_ID  = 'terraform/aws/jenkins'
    }

    stages {

        stage('Checkout') {
            steps {
                echo "STAGE: Checkout Repository"

                git branch: 'main', url: 'https://github.com/Mogeskebede/terraform-iam.git'

                echo "Repository checkout completed successfully"
            }
        }

        stage('Get AWS Credentials & Fetch Secrets') {
            steps {
                echo "STAGE: Fetch AWS Credentials from Jenkins & Retrieve Secret"

                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AKIAUBKFCSQ5BHPEYILU']]) {
                    script {
                        echo "AWS credentials injected from Jenkins"

                        echo "Calling AWS Secrets Manager to retrieve secret: ${SECRET_ID}"

                        def secret = bat(
                            script: """
                            aws secretsmanager get-secret-value ^
                            --secret-id %SECRET_ID% ^
                            --region %AWS_REGION% ^
                            --query SecretString ^
                            --output text
                            """,
                            returnStdout: true
                        ).trim()

                        echo "Secret retrieved successfully from AWS Secrets Manager"

                        def creds = readJSON text: secret

                        echo "Parsing secret JSON"

                        env.AWS_ACCESS_KEY_ID     = creds.AWS_ACCESS_KEY_ID
                        env.AWS_SECRET_ACCESS_KEY = creds.AWS_SECRET_ACCESS_KEY
                        env.AWS_DEFAULT_REGION    = creds.AWS_DEFAULT_REGION ?: env.AWS_REGION

                        echo "AWS credentials and region set as environment variables"
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                echo "STAGE: Terraform Init"

                bat 'terraform init'

                echo "Terraform initialization completed"
            }
        }

        stage('Terraform Format Check') {
            steps {
                echo "STAGE: Terraform Format Check"

                bat 'terraform fmt -check -recursive'

                echo "Terraform formatting check completed"
            }
        }

        stage('Terraform Validate') {
            steps {
                echo "STAGE: Terraform Validate"

                bat 'terraform validate'

                echo "Terraform validation completed successfully"
            }
        }

        stage('Terraform Plan') {
            steps {
                echo "STAGE: Terraform Plan"

                bat 'terraform plan -out=tfplan'

                echo "Terraform plan generated successfully"
            }
        }

        stage('Terraform Apply') {
            steps {
                echo "STAGE: Terraform Apply"

                bat 'terraform apply -auto-approve tfplan'

                echo "Terraform apply completed successfully"
            }
        }
    }

    post {
        success {
            echo "PIPELINE RESULT: SUCCESS"
            echo "All stages completed successfully"
        }

        failure {
            echo "PIPELINE RESULT: FAILURE"
            echo "One or more stages failed. Review logs above."
        }

        always {
            echo "Pipeline execution finished"
        }
    }
}