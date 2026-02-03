#ProjectBedrock-DetailedDeploymentGuide

ThiscomprehensiveguidewillwalkyouthroughdeployingthecompleteProjectBedrockinfrastructurefromstarttofinish.

##TableofContents

1.[Prerequisites](#prerequisites)
2.[InitialSetup](#initial-setup)
3.[BackendConfiguration](#backend-configuration)
4.[InfrastructureDeployment](#infrastructure-deployment)
5.[ApplicationDeployment](#application-deployment)
6.[VerificationandTesting](#verification-and-testing)
7.[Optional:RDSIntegration](#optional-rds-integration)
8.[Optional:HTTPSConfiguration](#optional-https-configuration)
9.[Troubleshooting](#troubleshooting)

##Prerequisites

###1.InstallRequiredTools(Ifnotpresent)

####AWSCLI

**macOS:**
```bash
curl"https://awscli.amazonaws.com/AWSCLIV2.pkg"-o"AWSCLIV2.pkg"
sudoinstaller-pkgAWSCLIV2.pkg-target/
```

**Linux:**
```bash
curl"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"-o"awscliv2.zip"
unzipawscliv2.zip
sudo./aws/install
```

**Windows:**
Downloadandrun:https://awscli.amazonaws.com/AWSCLIV2.msi

**Verify:**
```bash
aws--version#Shouldshowv2.x
```

####Terraform

**macOS:**
```bash
brewtaphashicorp/tap
brewinstallhashicorp/terraform
```

**Linux:**
```bash
wget-O-https://apt.releases.hashicorp.com/gpg|sudogpg--dearmor-o/usr/share/keyrings/hashicorp-archive-keyring.gpg
echo"deb[signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg]https://apt.releases.hashicorp.com$(lsb_release-cs)main"|sudotee/etc/apt/sources.list.d/hashicorp.list
sudoaptupdate&&sudoaptinstallterraform
```

**Windows:**
Downloadfrom:https://www.terraform.io/downloads

**Verify:**
```bash
terraformversion#Shouldshowv1.5+
```

####kubectl

**macOS:**
```bash
brewinstallkubectl
```

**Linux:**
```bash
curl-LO"https://dl.k8s.io/release/$(curl-L-shttps://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudoinstall-oroot-groot-m0755kubectl/usr/local/bin/kubectl
```

**Windows:**
```powershell
curl.exe-LO"https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
```

**Verify:**
```bash
kubectlversion--client#Shouldshowv1.28+
```

####Helm

**macOS:**
```bash
brewinstallhelm
```

**Linux:**
```bash
curlhttps://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3|bash
```

**Windows:**
```powershell
chocoinstallkubernetes-helm
```

**Verify:**
```bash
helmversion#Shouldshowv3.13+
```
#####Now,youareset.LetusnowconfigureAWScredentials

###2.ConfigureAWSCredentials

```bash
awsconfigure
```

Provide:
-**AWSAccessKeyID**:Youraccesskey
-**AWSSecretAccessKey**:Yoursecretkey
-**Defaultregionname**:`us-east-1`
-**Defaultoutputformat**:`json`

**Verify:**
```bash
awsstsget-caller-identity
```

###3.VerifyIAMPermissions

EnsureyourIAMuser/rolehaspermissionsfor:
-EC2(VPC,Subnets,NATGateways)
-EKS(Clusters,NodeGroups)
-IAM(Roles,Policies,Users)
-S3(Buckets,Objects)
-Lambda(Functions)
-RDS(Instances,SubnetGroups)
-CloudWatch(LogGroups)
-ElasticLoadBalancing(ALB,TargetGroups)

## InitialSetup

### 1.ClonetheRepository

```bash
gitclonehttps://github.com/ififrank2013/bedrock-infra.git
cdbedrock-infra
```

### 2.ReviewConfiguration

Edit`terraform/variables.tf`ifyouwanttocustomize:

```hcl
variable"aws_region"{
default="us-east-1"
}

variable"cluster_version"{
default="1.31"#EKSversion
}

variable"node_instance_types"{
default=["t3.large"]
}

variable"enable_rds"{
default=true#RDSsettings
}

variable"enable_alb_ingress"{
default=true#EnableALB
}
```

**Important**:DoNOTchangeresourcenames:
-Clustername:`project-bedrock-cluster`
-VPCname:`project-bedrock-vpc`
-Namespace:`retail-app`
-Developeruser:`bedrock-dev-view`

## BackendConfiguration

### 1.RunBackendSetupScript

**OnLinux/macOS:**
```bash
cdscripts
chmod+xsetup-backend.sh
./setup-backend.sh
cd..
```

**OnWindows(PowerShell):**
```powershell
cdscripts
.\setup-backend.ps1
cd..
```

This script creates:
-S3bucket:`bedrock-terraform-state-alt-soe-025-0275`
-DynamoDBtable:`bedrock-terraform-locks`

### 2.Verify Backend Resources

```bash
# CheckS3bucket
awss3ls | grepbedrock-terraform-state

#Check DynamoDB table
aws dynamodb describe-table--table-namebedrock-terraform-locks
```

## Infrastructure Deployment

### 1.Initialize Terraform

```bash
cdterraform
terraforminit
```

Expected output:
```
Initializing modules...
Initializing the backend...
Successfully configured the backend "s3"!
Terraformhasbeensuccessfullyinitialized!
```

###2.ReviewthePlan

```bash
terraformplan
```

Reviewtheresourcestobecreated:
-VPCandsubnets
-EKSclusterandnodegroup
-IAMrolesandusers
-S3bucketandLambdafunction
-CloudWatchloggroups
-RDSinstances(ifenabled)
-ALBcontroller(ifenabled)

###3.ApplyInfrastructure

```bash
terraformapply
```

Type`yes`whenprompted.

**Expectedduration**:15-20minutes

**Progressindicators:**
-VPCcreated(~2min)
-EKSclustercreated(~10min)
-Nodegroupcreated(~5min)
-Add-onsinstalled(~2min)

###4.VerifyDeployment

```bash
#CheckEKScluster
awseksdescribe-cluster--nameproject-bedrock-cluster--regionus-east-1

#Getoutputs
terraformoutput
```

###5.Configurekubectl

```bash
awseksupdate-kubeconfig--nameproject-bedrock-cluster--regionus-east-1

#Verifyconnection
kubectlgetnodes
kubectlgetnamespaces
```

Expectedoutput:
```
NAMESTATUSROLESAGEVERSION
ip-10-0-11-xxx.ec2.internalReady<none>5mv1.31.0
ip-10-0-12-xxx.ec2.internalReady<none>5mv1.31.0
```

##ApplicationDeployment

###OptionA:AutomatedDeployment(Recommended)

**OnLinux/macOS:**
```bash
cd../scripts
chmod+xdeploy-app.sh
./deploy-app.sh
```

**OnWindows(PowerShell):**
```powershell
cd..\scripts
.\deploy-app.ps1
```

###OptionB:ManualDeployment

####1.AddHelmRepository

```bash
helmrepoaddretail-apphttps://aws.github.io/retail-store-sample-app
helmrepoupdate
```

####2.CreateNamespace

```bash
kubectlcreatenamespaceretail-app
```

####3.DeployApplication

**WithoutRDS(in-clusterdatabases):**
```bash
helminstallretail-appretail-app/retail-app\
--namespaceretail-app\
--values../k8s/retail-app-values.yaml\
--wait\
--timeout10m
```

**WithRDS:**
```bash
#First,getRDSendpointsfromTerraform
cd../terraform
MYSQL_ENDPOINT=$(terraformoutput-rawrds_mysql_endpoint)
POSTGRES_ENDPOINT=$(terraformoutput-rawrds_postgres_endpoint)

#GetRDSpasswordsfromSecretsManager
MYSQL_PASSWORD=$(awssecretsmanagerget-secret-value--secret-idbedrock/rds/mysql-credentials--querySecretString--outputtext|jq-r.password)
POSTGRES_PASSWORD=$(awssecretsmanagerget-secret-value--secret-idbedrock/rds/postgres-credentials--querySecretString--outputtext|jq-r.password)

#CreateKubernetessecrets
kubectlcreatesecretgenericcatalog-db-secret\
--namespaceretail-app\
--from-literal=username=catalogadmin\
--from-literal=password=$MYSQL_PASSWORD\
--from-literal=host=$MYSQL_ENDPOINT\
--from-literal=port=3306\
--from-literal=database=catalog

kubectlcreatesecretgenericorders-db-secret\
--namespaceretail-app\
--from-literal=username=ordersadmin\
--from-literal=password=$POSTGRES_PASSWORD\
--from-literal=host=$POSTGRES_ENDPOINT\
--from-literal=port=5432\
--from-literal=database=orders

#DeploywithRDSvalues
helminstallretail-appretail-app/retail-app\
--namespaceretail-app\
--values../k8s/retail-app-values-rds.yaml\
--wait\
--timeout10m
```

####4.DeployIngress

```bash
kubectlapply-f../k8s/ingress.yaml
```

##VerificationandTesting

###1.CheckPodStatus

```bash
kubectlgetpods-nretail-app
```

Allpodsshouldbein`Running`state:
```
NAMEREADYSTATUSRESTARTSAGE
ui-xxx1/1Running02m
catalog-xxx1/1Running02m
orders-xxx1/1Running02m
cart-xxx1/1Running02m
checkout-xxx1/1Running02m
assets-xxx1/1Running02m
```

###2.CheckServices

```bash
kubectlgetsvc-nretail-app
```

###3.CheckIngress

```bash
kubectlgetingress-nretail-app
```

WaitfortheALBtobeprovisioned(2-5minutes):
```
NAMECLASSHOSTSADDRESSPORTSAGE
retail-app-ingressalb*xxx.us-east-1.elb.amazonaws.com803m
```

###4.AccesstheApplication

```bash
#GetALBURL
ALB_URL=$(kubectlgetingressretail-app-ingress-nretail-app-ojsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo"ApplicationURL:http://$ALB_URL"

#Testwithcurl
curlhttp://$ALB_URL

#Oropeninbrowser
openhttp://$ALB_URL#macOS
xdg-openhttp://$ALB_URL#Linux
starthttp://$ALB_URL#Windows
```

###5.TestLambdaFunction

```bash
#Uploadtestfile
echo"Testproductimage">test-image.jpg
awss3cptest-image.jpgs3://bedrock-assets-alt-soe-025-0275/products/

#CheckLambdalogs
awslogstail/aws/lambda/bedrock-asset-processor--follow
```

Expectedoutputinlogs:
```
Imagereceived:products/test-image.jpg
```

###6.TestCloudWatchLogging

```bash
#ViewEKScontrolplanelogs
awslogstail/aws/eks/project-bedrock-cluster/cluster--follow

#Viewcontainerlogs
kubectllogs-fdeployment/ui-nretail-app
```

###7.TestDeveloperAccess

```bash
#Getdevelopercredentials
cdterraform
terraformoutputdeveloper_access_key_id
terraformoutputdeveloper_secret_access_key

#ConfigureaseparateAWSprofile
awsconfigure--profilebedrock-dev
#Enterthedevelopercredentials

#Testreadaccess(shouldwork)
awseksdescribe-cluster--nameproject-bedrock-cluster--regionus-east-1--profilebedrock-dev

#Updatekubeconfigwithdeveloperprofile
awseksupdate-kubeconfig--nameproject-bedrock-cluster--regionus-east-1--profilebedrock-dev

#TestKubernetesreadaccess(shouldwork)
kubectlgetpods-nretail-app
kubectlgetnodes
kubectldescribepod<pod-name>-nretail-app

#Testwriteaccess(shouldfail)
kubectldeletepod<pod-name>-nretail-app
#Error:Usercannotdeleteresource"pods"inAPIgroup""
```

##Optional:RDSIntegration

Ifyoudeployedwith`enable_rds=true`,theapplicationisalreadyusingRDS.Here'showtoverify:

###1.CheckRDSInstances

```bash
awsrdsdescribe-db-instances--query'DBInstances[*].[DBInstanceIdentifier,Endpoint.Address,DBInstanceStatus]'
```

###2.ConnecttoRDS(fortesting)

```bash
#GetcredentialsfromSecretsManager
MYSQL_ENDPOINT=$(cdterraform&&terraformoutput-rawrds_mysql_endpoint)
MYSQL_PASSWORD=$(awssecretsmanagerget-secret-value--secret-idbedrock/rds/mysql-credentials--querySecretString--outputtext|jq-r.password)

#Connect(requiresmysqlclient)
mysql-h$MYSQL_ENDPOINT-ucatalogadmin-p$MYSQL_PASSWORDcatalog
```

###3.VerifyApplicationisUsingRDS

```bash
#Checkcatalogpodlogs
kubectllogs-lapp=catalog-nretail-app|grep-i"database"

#ThelogsshouldshowconnectiontoRDSendpoint
```

##Optional:HTTPSConfiguration

###1.RequestACMCertificate

```bash
#Requestcertificateforyourdomain
awsacmrequest-certificate\
--domain-nameyourdomain.com\
--subject-alternative-names"*.yourdomain.com"\
--validation-methodDNS\
--regionus-east-1

#GetcertificateARN
awsacmlist-certificates--regionus-east-1
```

###2.ValidateCertificate

FollowtheDNSvalidationinstructionsintheAWSConsoleorCLI.

###3.UpdateIngress

Edit`k8s/ingress.yaml`:

```yaml
apiVersion:networking.k8s.io/v1
kind:Ingress
metadata:
name:retail-app-ingress
namespace:retail-app
annotations:
alb.ingress.kubernetes.io/scheme:internet-facing
alb.ingress.kubernetes.io/target-type:ip
alb.ingress.kubernetes.io/certificate-arn:arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERT_ID
alb.ingress.kubernetes.io/listen-ports:'[{"HTTP":80},{"HTTPS":443}]'
alb.ingress.kubernetes.io/ssl-redirect:'443'
spec:
ingressClassName:alb
rules:
-host:yourdomain.com
http:
paths:
-path:/
pathType:Prefix
backend:
service:
name:ui
port:
number:8080
```

Applythechanges:
```bash
kubectlapply-fk8s/ingress.yaml
```

###4.ConfigureDNS

PointyourdomaintotheALB:

```bash
ALB_URL=$(kubectlgetingressretail-app-ingress-nretail-app-ojsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo"CreateaCNAMErecord:yourdomain.com->$ALB_URL"
```

##Troubleshooting

###Issue:Terraforminitfails

**Error**:`Error:Failedtogetexistingworkspaces`

**Solution**:
```bash
#VerifyAWScredentials
awsstsget-caller-identity

#Checkbackendbucketexists
awss3lss3://bedrock-terraform-state-alt-soe-025-0275

#Re-runbackendsetup
cdscripts
./setup-backend.sh
```

###Issue:EKSclustercreationtimesout

**Error**:`timeoutwhilewaitingforresourcecreation`

**Solution**:
```bash
#CheckCloudFormationstacks
awscloudformationdescribe-stacks--regionus-east-1

#IfstackisinROLLBACKstate,deleteandretry
terraformdestroy-target=module.eks
terraformapply
```

###Issue:PodsstuckinPendingstate

**Error**:Podsnotstarting

**Solution**:
```bash
#Checknodestatus
kubectlgetnodes

#Describepodfordetails
kubectldescribepod<pod-name>-nretail-app

#Commoncauses:
#1.Insufficientresources-scalenodegroup
#2.Imagepullerrors-checkimagename
#3.PVCnotbound-checkstorageclass
```

###Issue:ALBnotcreated

**Error**:IngresshasnoADDRESS

**Solution**:
```bash
#CheckALBcontrollerlogs
kubectllogs-nkube-systemdeployment/aws-load-balancer-controller

#Verifyserviceaccount
kubectlgetsaaws-load-balancer-controller-nkube-system-oyaml

#CheckIAMroleannotations
kubectldescribesaaws-load-balancer-controller-nkube-system

#RestartALBcontroller
kubectlrolloutrestartdeploymentaws-load-balancer-controller-nkube-system
```

###Issue:Cannotaccessapplication

**Error**:Connectionrefusedortimeout

**Solution**:
```bash
#VerifyALBisactive
awselbv2describe-load-balancers--regionus-east-1

#Checktargethealth
ALB_ARN=$(awselbv2describe-load-balancers--query"LoadBalancers[?contains(DNSName,'k8s-retailap')].LoadBalancerArn"--outputtext)
awselbv2describe-target-health--target-group-arn<target-group-arn>

#Checksecuritygroups
kubectlgetingressretail-app-ingress-nretail-app-oyaml|grepalb.ingress
```

###Issue:Lambdanottriggering

**Error**:NologswhenuploadingtoS3

**Solution**:
```bash
#CheckLambdafunctionexists
awslambdaget-function--function-namebedrock-asset-processor

#CheckS3eventnotification
awss3apiget-bucket-notification-configuration--bucketbedrock-assets-alt-soe-025-0275

#TestLambdamanually
awslambdainvoke--function-namebedrock-asset-processor--payload'{"Records":[{"s3":{"bucket":{"name":"test"},"object":{"key":"test.jpg"}}}]}'response.json
catresponse.json
```

###Issue:Developercannotaccesscluster

**Error**:`error:Youmustbeloggedintotheserver(Unauthorized)`

**Solution**:
```bash
#VerifyIAMuserexists
awsiamget-user--user-namebedrock-dev-view

#Checkaws-authConfigMap
kubectlgetconfigmapaws-auth-nkube-system-oyaml

#VerifyRBACbinding
kubectlgetclusterrolebindingbedrock-developer-view-binding-oyaml

#Re-applyaws-auth
cdterraform
terraformapply-target=module.k8s_rbac
```

##GenerateGradingJSON

```bash
cdterraform
terraformoutput-json>../grading.json
cat../grading.json
```

VerifytheJSONcontains:
-`cluster_endpoint`
-`cluster_name`
-`region`
-`vpc_id`
-`assets_bucket_name`

##NextSteps

1.✅Verifyallpodsarerunning
2.✅Testapplicationaccess
3.✅TestLambdafunction
4.✅Testdeveloperaccess
5.✅Generategrading.json
6.✅CommitcodetoGitHub
7.✅Preparesubmissiondocument

##Cleanup

Whenyou'redoneandwanttodestroyallresources:

```bash
cdscripts
./cleanup.sh
```

Ormanually:
```bash
#Deleteapplication
helmuninstallretail-app-nretail-app
kubectldeletenamespaceretail-app

#Destroyinfrastructure
cdterraform
terraformdestroy

#Deletebackend(optional)
awss3rbs3://bedrock-terraform-state-alt-soe-025-0275--force
awsdynamodbdelete-table--table-namebedrock-terraform-locks
```

---

##SummaryChecklist

-[]Allprerequisitesinstalled
-[]AWScredentialsconfigured
-[]Backendsetupcomplete
-[]Terraformappliedsuccessfully
-[]kubectlconfigured
-[]Applicationdeployed
-[]Allpodsrunning
-[]ApplicationaccessibleviaALB
-[]Lambdafunctiontested
-[]CloudWatchlogsverified
-[]Developeraccesstested
-[]grading.jsongenerated
-[]CodecommittedtoGitHub
-[]Documentationcomplete

**Congratulations!YourProjectBedrockdeploymentiscomplete!🎉**
