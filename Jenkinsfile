pipeline{
    agent any
/*     agent{
        label "node"
    } */
    stages{
        stage("A"){
            steps{
                echo "========executing A========"
                powershell label: 'GetModule', returnStdout: true, script: "Get-Module -Name ${WORKSPACE} -ListAvailable"
            }
            post{
                always{
                    echo "========always========"
                }
                success{
                    echo "========A executed successfully========"
                }
                failure{
                    echo "========A execution failed========"
                }
            }
        }
    }
    post{
        always{
            echo "========always========"
        }
        success{
            echo "========pipeline executed successfully ========"
        }
        failure{
            echo "========pipeline execution failed========"
        }
    }
}