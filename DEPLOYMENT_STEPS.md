#DEPLOYMENTSTEPS-ExecuteTheseCommandsinOrder

ThisguidewalksyouthroughdeployingProjectBedrockfromstarttofinish.

##IMPORTANTPREREQUISITES

Beforestarting,ensureyouhave:
1.AWSAccountwithappropriateIAMpermissions
2.AWSCLIv2.xinstalledandconfigured
3.Terraformv1.5+installed
4.kubectlv1.28+installed
5.Helmv3.13+installed
6.Gitinstalled

---

##STEP1:InitializeGitRepository

```powershell
#Navigatetobedrock-infradirectory
cdC:\Users\olivc\OneDrive\Documents\altschool-barakat-cohort\third-semester\capstone-project\bedrock-infra

#Initializegitrepository
gitinit

#Addallfiles
gitadd.

#Makeinitialcommit
gitcommit-m"Initialcommit:CompleteProjectBedrockinfrastructure"
```

---

##STEP2:CreateGitHubRepository

1.Gotohttps://github.com/new
2.Repositoryname:`bedrock-infra`
3.Description:"ProjectBedrock-InnovateMartEKSInfrastructure(AltSchoolCapstone)"
4.Makeit**Public**
5.DoNOTinitializewithREADME(itisalreadyincluded)
6.Click"Createrepository"

Thenpushyourcode:

```powershell
#Addremote
gitremoteaddoriginhttps://github.com/ififrank2013/bedrock-infra.git

#PushtoGitHub
gitbranch-Mmain
gitpush-uoriginmain
```

---

##STEP3:SetupAWSBackend

ThiscreatestheS3bucketandDynamoDBtableforTerraformstate.

```powershell
#Runthebackendsetupscript
cdscripts
.\setup-backend.ps1

#Verifybackendresourceswerecreated
awss3ls|Select-String"bedrock-terraform-state"
awsdynamodblist-tables|Select-String"bedrock-terraform-locks"
```

**ExpectedOutput:**
```
Backendsetupcomplete!
```

---

##STEP4:DeployInfrastructurewithTerraform

```powershell
#Navigatetoterraformdirectory
cd..\terraform

#InitializeTerraform(downloadsprovidersandmodules)
terraforminit

#Reviewwhatwillbecreated(optionalbutrecommended)
terraformplan

#Applytheinfrastructure
terraformapply
```

Whenprompted,type`yes`andpressEnter.

**Thiswilltake15-20minutes.**

**ExpectedOutput:**
```
Applycomplete!Resources:50+added,0changed,0destroyed.

Outputs:
cluster_endpoint="https://xxxxx.gr7.us-east-1.eks.amazonaws.com"
cluster_name="project-bedrock-cluster"
region="us-east-1"
vpc_id="vpc-xxxxx"
assets_bucket_name="bedrock-assets-alt-soe-025-0275"
...
```

---

##STEP5:Configurekubectl

```powershell
#UpdatekubeconfigtoaccesstheEKScluster
awseksupdate-kubeconfig--nameproject-bedrock-cluster--regionus-east-1

#Verifyclusteraccess
kubectlcluster-info

#Checknodesareready
kubectlgetnodes
```

**ExpectedOutput:**
```
NAMESTATUSROLESAGEVERSION
ip-10-0-11-xxx.ec2.internalReady<none>5mv1.31.0
ip-10-0-12-xxx.ec2.internalReady<none>5mv1.31.0
ip-10-0-11-yyy.ec2.internalReady<none>5mv1.31.0
```

---

##STEP6:DeployRetailApplication

```powershell
#Navigatebacktoscriptsdirectory
cd..\scripts

#Runthedeploymentscript
.\deploy-app.ps1
```

**Thiswilltake5-10minutes.**

**ExpectedOutput:**
```
Deploymentcomplete!
ApplicationURL:http://k8s-retailap-xxxxx.us-east-1.elb.amazonaws.com
```

---

##STEP7:VerifyDeployment

###CheckAllPodsareRunning

```powershell
kubectlgetpods-nretail-app
```

**Expected:**Allpodsshouldshow`STATUS:Running`and`READY:1/1`

###GetApplicationURL

```powershell
kubectlgetingress-nretail-app
```

Lookforthe`ADDRESS`column-that'syourALBURL.

###TestApplication

```powershell
#GettheURL
$ALB_URL=kubectlgetingressretail-app-ingress-nretail-app-ojsonpath='{.status.loadBalancer.ingress[0].hostname}'

#Testwithcurl
curlhttp://$ALB_URL

#Oropeninbrowser
Start-Process"http://$ALB_URL"
```

---

##STEP8:TestLambdaFunction

```powershell
#Createatestimage
"Testproductimage"|Out-File-FilePathtest-image.jpg-EncodingASCII

#UploadtoS3
awss3cptest-image.jpgs3://bedrock-assets-alt-soe-025-0275/products/

#CheckLambdalogs(wait10secondsfirst)
Start-Sleep-Seconds10
awslogstail/aws/lambda/bedrock-asset-processor--since1m
```

**ExpectedOutputinlogs:**
```
Imagereceived:products/test-image.jpg
```

---

##STEP9:TestDeveloperAccess

```powershell
#Getdevelopercredentials
cd..\terraform
$ACCESS_KEY=terraformoutput-rawdeveloper_access_key_id
$SECRET_KEY=terraformoutput-rawdeveloper_secret_access_key

#Displaycredentials(savetheseforsubmission)
Write-Host"DeveloperAccessKeyID:$ACCESS_KEY"
Write-Host"DeveloperSecretAccessKey:$SECRET_KEY"

#ConfigureaseparateAWSprofileforthedeveloper
awsconfigure--profilebedrock-dev
#Whenprompted:
#AWSAccessKeyID:[paste$ACCESS_KEY]
#AWSSecretAccessKey:[paste$SECRET_KEY]
#Defaultregion:us-east-1
#Defaultoutputformat:json

#TestAWSreadaccess(shouldwork)
awseksdescribe-cluster--nameproject-bedrock-cluster--regionus-east-1--profilebedrock-dev

#Updatekubeconfigwithdeveloperprofile
awseksupdate-kubeconfig--nameproject-bedrock-cluster--regionus-east-1--profilebedrock-dev

#TestKubernetesreadaccess(shouldwork)
kubectlgetpods-nretail-app
kubectlgetnodes

#Testwriteaccess(shouldfailwithForbiddenerror)
$POD=kubectlgetpods-nretail-app-oname|Select-Object-First1
kubectldelete$POD
```

**Expected:**Thedeletecommandshouldfailwith"Forbidden"error.

---

##STEP10:GenerateGradingJSON

```powershell
#Generatethegrading.jsonfile
cd..\terraform
terraformoutput-json|Out-File-FilePath..\grading.json-EncodingUTF8

#Viewthefile
Get-Content..\grading.json

#Addtogit
cd..
gitaddgrading.json
gitcommit-m"Addgrading.jsonwithterraformoutputs"
gitpush
```

---

##STEP11:SetupGitHubActionsSecrets

1.GotoyourrepositoryonGitHub:https://github.com/ififrank2013/bedrock-infra
2.Click**Settings**→**Secretsandvariables**→**Actions**
3.Click**Newrepositorysecret**
4.Addtwosecrets:

**Secret1:**
-Name:`AWS_ACCESS_KEY_ID`
-Value:YourAWSaccesskeyID

**Secret2:**
-Name:`AWS_SECRET_ACCESS_KEY`
-Value:YourAWSsecretaccesskey

---

##STEP12:TestCI/CDPipeline

```powershell
#Createatestbranch
gitcheckout-btest-cicd

#Makeasmallchange
"#Testchange"|Add-ContentREADME.md

#Commitandpush
gitaddREADME.md
gitcommit-m"TestCI/CDpipeline"
gitpushorigintest-cicd
```

Then:
1.GotoGitHubandcreateaPullRequest
2.WatchtheGitHubActionsworkflowrun`terraformplan`
3.ReviewtheplaninthePRcomments
4.MergethePRtotrigger`terraformapply`

---

##STEP13:CreateArchitectureDiagram

Useoneofthesetoolstocreateyourdiagram:
-**Draw.io**:https://app.diagrams.net/
-**Lucidchart**:https://www.lucidchart.com/
-**Excalidraw**:https://excalidraw.com/

ReferencetheASCIIdiagraminREADME.mdforstructure.

Savethediagramas`architecture.png`anduploadtoyourrepository:

```powershell
#Aftercreatingthediagram
cddocs
#Placeyourarchitecture.pngfilehere

#Addtogit
gitaddarchitecture.png
gitcommit-m"Addarchitecturediagram"
gitpush
```

---

##STEP14:PrepareSubmissionDocument

1.Open`/docs/SUBMISSION_TEMPLATE.md`
2.Fillinalltherequiredinformation:
-Yourfullname
-Youremail
-ActualALBURLfromStep7
-DevelopercredentialsfromStep9
-Linktoarchitecturediagram

3.ExportasPDForshareasGoogleDoc

###CreateGoogleDoc:
1.CopycontentsofSUBMISSION_TEMPLATE.md
2.GotoGoogleDocs:https://docs.google.com/document/
3.Pasteandformatthecontent
4.Getshareablelinkwith"Viewer"access
5.SharewithInnocentChukwuemeka

---

##STEP15:FinalVerificationChecklist

Runthesecommandstoverifyeverything:

```powershell
#1.EKSCluster
awseksdescribe-cluster--nameproject-bedrock-cluster--regionus-east-1--query'cluster.status'
#Expected:"ACTIVE"

#2.AllPodsRunning
kubectlgetpods-nretail-app
#Expected:AllpodsSTATUS:Running

#3.ApplicationAccessible
$ALB_URL=kubectlgetingressretail-app-ingress-nretail-app-ojsonpath='{.status.loadBalancer.ingress[0].hostname}'
curl-I"http://$ALB_URL"
#Expected:HTTP/1.1200OK

#4.LambdaFunction
awslambdaget-function--function-namebedrock-asset-processor--query'Configuration.FunctionName'
#Expected:"bedrock-asset-processor"

#5.S3Bucket
awss3lss3://bedrock-assets-alt-soe-025-0275
#Expected:Listofobjects(includingyourtestfile)

#6.CloudWatchLogs
awslogsdescribe-log-groups--log-group-name-prefix/aws/eks/project-bedrock-cluster
#Expected:Listofloggroups

#7.RDSInstances
awsrdsdescribe-db-instances--query'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]'
#Expected:Twoinstances(mysqlandpostgres)withstatus"available"

#8.VPC
awsec2describe-vpcs--filters"Name=tag:Name,Values=project-bedrock-vpc"--query'Vpcs[0].VpcId'
#Expected:vpc-xxxxx

#9.TerraformState
awss3lss3://bedrock-terraform-state-alt-soe-025-0275/bedrock/
#Expected:terraform.tfstatefile

#10.GitHubRepository
#Visit:https://github.com/ififrank2013/bedrock-infra
#Verifyallfilesarepushed
```

---

##SUBMISSIONCHECKLIST

Beforesubmitting,ensure:

-[]GitHubrepositoryispublicoraccessgrantedtoinstructor
-[]Allcodeispushedtomainbranch
-[]grading.jsonisinrepositoryroot
-[]README.mdiscompleteandaccurate
-[]Architecturediagramiscreatedandadded
-[]ApplicationisaccessibleviaALBURL
-[]Allpodsarerunninginretail-appnamespace
-[]Lambdafunctionisworking(testwithS3upload)
-[]Developeraccesscredentialsaredocumented
-[]CloudWatchlogsareenabledandaccessible
-[]RDSinstancesarerunning(ifenabled)
-[]ALBisprovisionedandroutingtraffic
-[]CI/CDpipelineisconfiguredinGitHubActions
-[]Submissiondocumentisprepared(GoogleDocorPDF)
-[]Allnamingconventionsarecorrect
-[]Allresourcesaretaggedproperly

---

##🎉CONGRATULATIONS!

Youhavesuccessfully:
-Deployedaproduction-gradeEKScluster
-ConfiguredVPCwithpublic/privatesubnets
-ImplementedIAMandRBACsecurity
-SetupCloudWatchobservability
-Createdserverlesseventprocessing
-Deployedamicroservicesapplication
-ImplementedCI/CDpipeline
-AddedRDSmanageddatabases(bonus)
-ConfiguredALBwithIngress(bonus)

YourProjectBedrockinfrastructureiscompleteandreadyforgrading.

---

##🆘TROUBLESHOOTING

Ifsomethinggoeswrong,check:

1.**AWSCredentials**:`awsstsget-caller-identity`
2.**TerraformState**:`cdterraform&&terraformshow`
3.**ClusterStatus**:`kubectlcluster-info`
4.**PodLogs**:`kubectllogs<pod-name>-nretail-app`
5.**Events**:`kubectlgetevents-nretail-app--sort-by='.lastTimestamp'`

Fordetailedtroubleshooting,see`/docs/DEPLOYMENT_GUIDE.md`.

---

##🧹CLEANUP(ONLYAFTERGRADING)

**WARNING:Thiswilldeleteeverything!**

```powershell
#Deleteapplication
helmuninstallretail-app-nretail-app
kubectldeletenamespaceretail-app

#WaitforLoadBalancerstobedeleted
Start-Sleep-Seconds60

#Destroyinfrastructure
cdterraform
terraformdestroy

#Type'yes'whenprompted

#Deletebackend(optional)
awss3rms3://bedrock-terraform-state-alt-soe-025-0275--recursive
awss3rbs3://bedrock-terraform-state-alt-soe-025-0275
awsdynamodbdelete-table--table-namebedrock-terraform-locks
```

---

**Goodluckwithyoursubmission!**

