#⚡QuickReferenceCard-ProjectBedrock

##🚀DeploymentCommands(Copy&Paste)

###1.InitializeGit&PushtoGitHub
```powershell
cdC:\Users\olivc\OneDrive\Documents\altschool-barakat-cohort\third-semester\capstone-project\bedrock-infra
gitinit
gitadd.
gitcommit-m"Initialcommit:CompleteProjectBedrockinfrastructure"
gitremoteaddoriginhttps://github.com/ififrank2013/bedrock-infra.git
gitpush-uoriginmain
```

###2.SetupBackend
```powershell
cdscripts
.\setup-backend.ps1
```

###3.DeployInfrastructure
```powershell
cd..\terraform
terraforminit
terraformplan
terraformapply-auto-approve
```

###4.Configurekubectl
```powershell
awseksupdate-kubeconfig--nameproject-bedrock-cluster--regionus-east-1
kubectlgetnodes
```

###5.DeployApplication
```powershell
cd..\scripts
.\deploy-app.ps1
```

###6.GetApplicationURL
```powershell
kubectlgetingress-nretail-app
```

###7.TestLambda
```powershell
"Test"|Out-Filetest.jpg
awss3cptest.jpgs3://bedrock-assets-alt-soe-025-0275/
awslogstail/aws/lambda/bedrock-asset-processor--since1m
```

###8.GetDeveloperCredentials
```powershell
cd..\terraform
terraformoutputdeveloper_access_key_id
terraformoutputdeveloper_secret_access_key
```

###9.GenerateGradingJSON
```powershell
terraformoutput-json|Out-File..\grading.json-EncodingUTF8
gitadd..\grading.json
gitcommit-m"Addgrading.json"
gitpush
```

---

##🔍VerificationCommands

###CheckAllPodsRunning
```powershell
kubectlgetpods-nretail-app
```

###CheckServices
```powershell
kubectlgetsvc-nretail-app
```

###CheckIngress/ALB
```powershell
kubectlgetingress-nretail-app
```

###CheckEKSCluster
```powershell
awseksdescribe-cluster--nameproject-bedrock-cluster--regionus-east-1--query'cluster.status'
```

###CheckRDSInstances
```powershell
awsrdsdescribe-db-instances--query'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]'
```

###CheckS3Bucket
```powershell
awss3lss3://bedrock-assets-alt-soe-025-0275
```

###CheckLambdaFunction
```powershell
awslambdaget-function--function-namebedrock-asset-processor
```

---

##📊KeyInformation

###ResourceNames(MUSTNOTCHANGE)
-**Cluster**:`project-bedrock-cluster`
-**VPC**:`project-bedrock-vpc`
-**Namespace**:`retail-app`
-**IAMUser**:`bedrock-dev-view`
-**S3Bucket**:`bedrock-assets-alt-soe-025-0275`
-**Lambda**:`bedrock-asset-processor`

###Region
-**AWSRegion**:`us-east-1`(MUSTBEus-east-1)

###Tags(AllResources)
```
Project:barakat-2025-capstone
ManagedBy:Terraform
Environment:production
StudentID:ALT-SOE-025-0275
```

---

##🎯RequiredOutputs

From`terraformoutput`:
-cluster_endpoint
-cluster_name
-region
-vpc_id
-assets_bucket_name

---

##🔑GitHubSecrets(AddThese)

1.Goto:https://github.com/ififrank2013/bedrock-infra/settings/secrets/actions
2.Add:
-`AWS_ACCESS_KEY_ID`=YourAWSaccesskey
-`AWS_SECRET_ACCESS_KEY`=YourAWSsecretkey

---

##📝FileLocations

|File|Location|
|------|----------|
|MainREADME|`/README.md`|
|DeploymentSteps|`/DEPLOYMENT_STEPS.md`|
|ProjectSummary|`/PROJECT_SUMMARY.md`|
|DetailedGuide|`/docs/DEPLOYMENT_GUIDE.md`|
|SubmissionTemplate|`/docs/SUBMISSION_TEMPLATE.md`|
|TerraformCode|`/terraform/`|
|KubernetesManifests|`/k8s/`|
|LambdaCode|`/lambda/`|
|Scripts|`/scripts/`|
|CI/CDPipeline|`/.github/workflows/`|

---

##⏱️TimeEstimates

|Task|Duration|
|------|----------|
|GitSetup|5min|
|BackendSetup|5min|
|TerraformApply|15-20min|
|AppDeployment|5-10min|
|Testing|10min|
|Documentation|15min|
|**TOTAL**|**~70min**|

---

##🧹Cleanup(AfterGrading)

```powershell
#Deleteapplication
helmuninstallretail-app-nretail-app
kubectldeletenamespaceretail-app

#WaitforLoadBalancers
Start-Sleep-Seconds60

#Destroyinfrastructure
cdterraform
terraformdestroy-auto-approve

#Deletebackend(optional)
awss3rms3://bedrock-terraform-state-alt-soe-025-0275--recursive
awss3rbs3://bedrock-terraform-state-alt-soe-025-0275
awsdynamodbdelete-table--table-namebedrock-terraform-locks
```

---

##💰CostAlert

**~$392/month**or**~$0.50/hour**

Remembertodestroyaftergrading!

---

##🆘QuickTroubleshooting

###PodsNotStarting
```powershell
kubectldescribepod<pod-name>-nretail-app
kubectllogs<pod-name>-nretail-app
```

###ALBNotCreated
```powershell
kubectllogs-nkube-systemdeployment/aws-load-balancer-controller
```

###TerraformErrors
```powershell
terraformrefresh
terraformplan
```

###Can'tAccessCluster
```powershell
awseksupdate-kubeconfig--nameproject-bedrock-cluster--regionus-east-1--force
```

---

##✅Pre-SubmissionChecklist

-[]Allpodsrunning
-[]Applicationaccessible
-[]Lambdatested
-[]Developeraccesstested
-[]grading.jsongenerated
-[]CodeonGitHub
-[]Repositorypublic
-[]Architecturediagramcreated
-[]Submissiondocumentready

---

##📞Support

-**DetailedGuide**:`/docs/DEPLOYMENT_GUIDE.md`
-**README**:`/README.md`
-**DeploymentSteps**:`/DEPLOYMENT_STEPS.md`

---

**QuickStart**:Justruncommandsinorderfromtoptobottom!🚀

