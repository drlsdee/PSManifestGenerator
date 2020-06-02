pipeline{
    parameters {
        string defaultValue: 'http://gitea00.mmc.local:3000', description: 'Git SCM URI', name: 'scmUri', trim: true
        string defaultValue: 'mmc.local', description: 'Git repo owner\'s name', name: 'ownerName', trim: true
        string defaultValue: '', description: 'Repository name', name: 'repoName', trim: true
        string defaultValue: 'JenkinsSvc-GitGeneral', description: 'SCM credentials ID', name: 'credsID', trim: true
        string defaultValue: '', description: 'Set new GUID if needed', name: 'newGuid', trim: true
        booleanParam defaultValue: false, description: 'Increment major version', name: 'incrementMajor'
        booleanParam defaultValue: false, description: 'Increment minor version', name: 'incrementMinor'
        string defaultValue: "${BUILD_NUMBER}", description: 'Set build number', name: 'numberOfBuild', trim: true
    }
    agent any
    stages{
        stage("Build the module PSManifestGenerator itself"){
            when {
                environment name: 'repoName', value: ''
            }
            steps{
                echo "====++++executing Build the module PSManifestGenerator itself++++===="
                //powershell label: 'Get-ChildItem', returnStatus: true, script: "Get-ChildItem -Path ${WORKSPACE}"
                powershell label: 'BuildManifest-Self', returnStatus: true, script: "PSManifestGenerator.run.ps1 -Path ${WORKSPACE} -Major:${incrementMajor} -Minor:${incrementMinor} -Build ${numberOfBuild}"
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
        stage("Checkout PS Module"){
            when {
                not {
                    environment name: 'repoName', value: ''
                }
            }
            steps{
                echo "====++++executing Checkout PS Module ${repoName}++++===="
                checkout(
                    [
                        $class: 'GitSCM',
                        branches: [
                            [
                                name: '*/master'
                            ]
                        ],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [
                            [
                                $class: 'CleanBeforeCheckout',
                                deleteUntrackedNestedRepositories: true
                            ],
                            [
                                $class: 'CleanCheckout',
                                deleteUntrackedNestedRepositories: true
                            ],
                            [
                                $class: 'PathRestriction',
                                excludedRegions: '*.psd1',
                                includedRegions: ''
                            ],
                            [
                                $class: 'RelativeTargetDirectory',
                                relativeTargetDir: "${repoName}"
                            ]
                        ],
                        submoduleCfg: [],
                        userRemoteConfigs: [
                            [
                                credentialsId: 'JenkinsSvc-GitGeneral',
                                url: "${scmUri}/${ownerName}/${repoName}.git"
                            ]
                        ]
                    ]
                )
            }
            post{
                always{
                    echo "====++++always++++===="
                }
                success{
                    echo "====++++Checkout PS Module ${repoName} executed successfully++++===="
                }
                failure{
                    echo "====++++Checkout PS Module ${repoName} execution failed++++===="
                }
        
            }
        }
        stage("Build manifest for PS module"){
            when {
                not {
                    environment name: 'repoName', value: ''
                }
            }
            steps{
                echo "====++++executing Build manifest for PS module ${repoName}++++===="
            }
            post{
                always{
                    echo "====++++always++++===="
                }
                success{
                    echo "====++++Build manifest for PS module ${repoName} executed successfully++++===="
                }
                failure{
                    echo "====++++Build manifest for PS module ${repoName} execution failed++++===="
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