pipeline{
    parameters {
        string defaultValue: 'http://gitea00.mmc.local:3000', description: 'Git SCM URI', name: 'ScmUri', trim: true
        string defaultValue: 'mmc.local', description: 'Git repo owner\'s name', name: 'ownerName', trim: true
        string defaultValue: '', description: 'Repository name', name: 'RepoName', trim: true
        string defaultValue: 'JenkinsSvc-GitGeneral', description: 'SCM credentials ID', name: 'credsID', trim: true
        string defaultValue: 'PSManifestGenerator', description: 'Name of the PS Module for generating manifests', name: 'PSManifestGenerator', trim: true
        string defaultValue: '', description: 'Set new GUID if needed', name: 'newGuid', trim: true
        booleanParam defaultValue: false, description: 'Increment major version', name: 'IncrementMajor'
        booleanParam defaultValue: false, description: 'Increment minor version', name: 'IncrementMinor'
        string defaultValue: "${BUILD_NUMBER}", description: 'Set build number', name: 'numberOfBuild', trim: true
    }
    agent any
    stages{
        stage("Build the module PSManifestGenerator itself"){
            when {
                environment name: 'RepoName', value: ''
            }
            steps{
                echo "====++++executing Build the module PSManifestGenerator itself++++===="
            }
            post{
                always{
                    echo "====++++always++++===="
                }
                success{
                    echo "====++++Build the module PSManifestGenerator itself executed successfully++++===="
                }
                failure{
                    echo "====++++Build the module PSManifestGenerator itself execution failed++++===="
                }
        
            }
        }
        stage("Build manifest for other PS module"){
            steps{
                echo "====++++executing Build manifest for other PS module++++===="
            }
            post{
                always{
                    echo "====++++always++++===="
                }
                success{
                    echo "====++++Build manifest for other PS module executed successfully++++===="
                }
                failure{
                    echo "====++++Build manifest for other PS module execution failed++++===="
                }
        
            }
        }
        /* stage("Checkout the module PSManifestGenerator"){
            steps{
                echo "====++++executing Checkout the module PSManifestGenerator++++===="
            }
            post{
                always{
                    echo "====++++always++++===="
                }
                success{
                    echo "====++++Checkout the module PSManifestGenerator executed successfully++++===="
                }
                failure{
                    echo "====++++Checkout the module PSManifestGenerator execution failed++++===="
                }
        
            }
        } */
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