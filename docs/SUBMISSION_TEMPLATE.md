#ProjectBedrock-SubmissionDocument

**StudentInformation**
-**Name**:[YourFullName]
-**StudentID**:ALT/SOE/025/0275
-**GitHubUsername**:ififrank2013
-**Email**:[YourEmail]
-**Date**:February2026

---

##1.GitRepositoryLink

**RepositoryURL**:https://github.com/ififrank2013/bedrock-infra

**RepositoryAccess**:Public(orinviteInnocentChukwuemekaifprivate)

**KeyFiles**:
-`/terraform/`-AllTerraformIaCcode
-`/k8s/`-KubernetesmanifestsandHelmvalues
-`/lambda/`-Lambdafunctioncode
-`/.github/workflows/`-CI/CDpipeline
-`/grading.json`-Terraformoutputsforgrading
-`/README.md`-Completedocumentation

---

##2.ArchitectureDiagram

**DiagramURL**:[LinktoarchitecturediagramimageorPDF]

**KeyComponents**:

###NetworkLayer
-**VPC**:`project-bedrock-vpc`(10.0.0.0/16)
-**PublicSubnets**:2subnetsacrossus-east-1aandus-east-1b
-**PrivateSubnets**:2subnetsacrossus-east-1aandus-east-1b
-**NATGateways**:2NATGatewaysforhighavailability
-**InternetGateway**:Forpublicsubnetinternetaccess

###ComputeLayer
-**EKSCluster**:`project-bedrock-cluster`(Kubernetesv1.31)
-**NodeGroup**:t3.largeinstances,2-5nodes
-**Namespace**:`retail-app`forapplicationisolation

###ApplicationLayer
-**UIService**:Webfrontend
-**CatalogService**:Productcatalogmanagement
-**OrdersService**:Orderprocessing
-**CartService**:Shoppingcartfunctionality
-**CheckoutService**:Paymentprocessing
-**AssetsService**:Staticassetserving

###DataLayer(Bonus)
-**RDSMySQL**:Catalogdatabase(Multi-AZ,encrypted,automatedbackups)
-**RDSPostgreSQL**:Ordersdatabase(Multi-AZ,encrypted,automatedbackups)
-**Redis**:Sessioncache
-**RabbitMQ**:Messagequeue

###ServerlessLayer
-**S3Bucket**:`bedrock-assets-alt-soe-025-0275`forproductimages
-**LambdaFunction**:`bedrock-asset-processor`forimageprocessing
-**CloudWatch**:Centralizedloggingandmonitoring

###NetworkingLayer(Bonus)
-**ApplicationLoadBalancer**:Internet-facingALB
-**IngressController**:AWSLoadBalancerController
-**TLS**:OptionalHTTPSwithACMcertificate

---

##3.DeploymentGuide

###QuickStart

**Prerequisites**:
-AWSCLIv2.x
-Terraformv1.5+
-kubectlv1.28+
-Helmv3.13+
-Git

**Step1:CloneRepository**
```bash
gitclonehttps://github.com/ififrank2013/bedrock-infra.git
cdbedrock-infra
```

**Step2:SetupBackend**
```bash
cdscripts
./setup-backend.sh#orsetup-backend.ps1onWindows
```

**Step3:DeployInfrastructure**
```bash
cd../terraform
terraforminit
terraformplan
terraformapply
```

**Step4:Configurekubectl**
```bash
awseksupdate-kubeconfig--nameproject-bedrock-cluster--regionus-east-1
```

**Step5:DeployApplication**
```bash
cd../scripts
./deploy-app.sh#ordeploy-app.ps1onWindows
```

**Step6:AccessApplication**
```bash
kubectlgetingress-nretail-app
#AccesstheALBURLshownintheADDRESScolumn
```

###DetailedDocumentation

Forcomprehensivestep-by-stepinstructions,see:
-**README.md**:Overviewandquickstart
-**docs/DEPLOYMENT_GUIDE.md**:Detaileddeploymentguidewithtroubleshooting

---

##4.ApplicationURL

**RetailStoreApplication**:
-**URL**:http://[ALB-DNS-NAME]
-**Example**:http://k8s-retailap-xxxxxxxx-yyyyyyyy.us-east-1.elb.amazonaws.com

**HowtoGetURL**:
```bash
kubectlgetingressretail-app-ingress-nretail-app-ojsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**ApplicationFeatures**:
-Productbrowsing
-Shoppingcart
-Orderplacement
-Userauthentication
-Assetmanagement

**HealthCheck**:
```bash
curlhttp://[ALB-DNS-NAME]/
#Shouldreturn200OKwithHTMLcontent
```

---

##5.GradingCredentials

###DeveloperIAMUser:`bedrock-dev-view`

**AccessKeyID**:`[RetrievedfromTerraformoutput]`

**Toretrievecredentials**:
```bash
cdterraform
terraformoutputdeveloper_access_key_id
terraformoutputdeveloper_secret_access_key
```

**SecretAccessKey**:`[RetrievedfromTerraformoutput-KEEPSECURE]`

**UserPermissions**:
-**AWSConsole**:ReadOnlyAccesspolicy(viewresources,cannotmodify)
-**Kubernetes**:ViewClusterRole(read-onlyaccesstoallnamespaces)

**TestCommands**:
```bash
#ConfigureAWSCLIwiththesecredentials
awsconfigure--profilebedrock-dev

#TestAWSreadaccess
awseksdescribe-cluster--nameproject-bedrock-cluster--regionus-east-1--profilebedrock-dev

#Configurekubectl
awseksupdate-kubeconfig--nameproject-bedrock-cluster--regionus-east-1--profilebedrock-dev

#TestKubernetesreadaccess(shouldwork)
kubectlgetpods-nretail-app
kubectlgetnodes
kubectldescribepod[POD-NAME]-nretail-app

#Testwriteaccess(shouldfail)
kubectldeletepod[POD-NAME]-nretail-app
#Expected:Error-Forbidden
```

---

##6.GradingData

###TerraformOutputs

**grading.jsonLocation**:`/grading.json`inrepositoryroot

**Togenerate/update**:
```bash
cdterraform
terraformoutput-json>../grading.json
```

**KeyOutputs**(fromgrading.json):
-`cluster_endpoint`:EKSAPIserverendpoint
-`cluster_name`:"project-bedrock-cluster"
-`region`:"us-east-1"
-`vpc_id`:VPCidentifier
-`assets_bucket_name`:"bedrock-assets-alt-soe-025-0275"

###ResourceVerificationCommands

**EKSCluster**:
```bash
awseksdescribe-cluster--nameproject-bedrock-cluster--regionus-east-1--query'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}'
```

**VPC**:
```bash
awsec2describe-vpcs--filters"Name=tag:Name,Values=project-bedrock-vpc"--query'Vpcs[0].{VpcId:VpcId,CidrBlock:CidrBlock}'
```

**ApplicationPods**:
```bash
kubectlgetpods-nretail-app-owide
```

**S3Bucket**:
```bash
awss3lss3://bedrock-assets-alt-soe-025-0275
```

**LambdaFunction**:
```bash
awslambdaget-function--function-namebedrock-asset-processor--query'Configuration.{FunctionName:FunctionName,Runtime:Runtime,Handler:Handler}'
```

---

##7.CoreRequirementsCompletion

###✅4.1InfrastructureasCode(IaC)

**Status**:Complete

**Evidence**:
-AllinfrastructuredefinedinTerraform
-VPCwithpublic/privatesubnetsacross2AZs(us-east-1a,us-east-1b)
-EKSclusterv1.31named`project-bedrock-cluster`
-IAMrolesfollowleast-privilegeprinciple
-RemotestateinS3withDynamoDBlocking

**Files**:`/terraform/main.tf`,`/terraform/modules/`

---

###✅4.2ApplicationDeployment

**Status**:Complete

**Evidence**:
-RetailStoreSampleAppdeployedviaHelm
-Runningin`retail-app`namespace
-In-clusterdependencies(MySQL,PostgreSQL,Redis,RabbitMQ)
-Allpodshealthyandrunning

**Files**:`/k8s/retail-app-values.yaml`

**Verification**:
```bash
kubectlgetpods-nretail-app
#AllpodsshouldshowSTATUS:Running
```

---

###✅4.3SecureDeveloperAccess

**Status**:Complete

**Evidence**:
-IAMuser`bedrock-dev-view`created
-AWSConsole:ReadOnlyAccesspolicyattached
-Kubernetes:Mappedto`view`ClusterRole
-Accesskeysgeneratedandprovided

**Files**:`/terraform/modules/iam/`,`/terraform/modules/k8s-rbac/`

**Verification**:
```bash
#Readaccessworks
kubectlgetpods-nretail-app--assystem:serviceaccount:retail-app:default

#Writeaccessdenied
kubectldeletepod[POD]-nretail-app--assystem:serviceaccount:retail-app:default
```

---

###✅4.4Observability(Logging)

**Status**:Complete

**Evidence**:
-EKSControlPlaneloggingenabled(API,Audit,Authenticator,ControllerManager,Scheduler)
-CloudWatchObservabilityadd-oninstalled
-ContainerlogsshippingtoCloudWatch
-Loggroupscreatedwithproperretention

**Files**:`/terraform/modules/observability/`

**Verification**:
```bash
#Controlplanelogs
awslogsdescribe-log-groups--log-group-name-prefix/aws/eks/project-bedrock-cluster

#Containerlogs
kubectllogs-fdeployment/ui-nretail-app
```

---

###✅4.5Event-DrivenExtension(Serverless)

**Status**:Complete

**Evidence**:
-S3bucket:`bedrock-assets-alt-soe-025-0275`
-Lambdafunction:`bedrock-asset-processor`
-S3eventnotificationconfigured
-LambdalogsfileuploadstoCloudWatch

**Files**:`/lambda/asset_processor.py`,`/terraform/modules/serverless/`

**Verification**:
```bash
#Uploadtestfile
echo"Test">test.jpg
awss3cptest.jpgs3://bedrock-assets-alt-soe-025-0275/

#Checklogs
awslogstail/aws/lambda/bedrock-asset-processor--follow
#Shouldshow:"Imagereceived:test.jpg"
```

---

###✅4.6CI/CDAutomation

**Status**:Complete

**Evidence**:
-GitHubActionsworkflowconfigured
-PullRequest:Runs`terraformplan`
-MergetoMain:Runs`terraformapply`
-AWScredentialsstoredasGitHubsecrets
-Automaticapplicationdeployment

**Files**:`/.github/workflows/terraform.yml`

**PipelineFeatures**:
-Terraformformatcheck
-Terraformvalidation
-PlanpreviewonPR
-Auto-applyonmerge
-Applicationdeployment
-grading.jsongeneration

---

##8.BonusObjectivesCompletion

###✅5.1ManagedPersistenceLayer

**Status**:Complete

**Evidence**:
-RDSMySQLinstanceforCatalogservice
-RDSPostgreSQLinstanceforOrdersservice
-Multi-AZdeploymentforhighavailability
-Automatedbackupswith7-dayretention
-Encryptionatrestenabled
-CredentialsstoredinAWSSecretsManager

**Files**:`/terraform/modules/rds/`,`/k8s/retail-app-values-rds.yaml`

**CostOptimization**:
-Usingdb.t3.microinstances
-GP3storageforbetterprice/performance
-Automatedbackupsduringlow-traffichours

**Verification**:
```bash
awsrdsdescribe-db-instances--query'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus]'
```

---

###✅5.2AdvancedNetworking&Ingress

**Status**:Complete

**Evidence**:
-AWSLoadBalancerControllerinstalled
-Ingressresourceconfigured
-ApplicationLoadBalancerprovisioned
-Internet-facingaccessenabled
-Targettype:IPmodeforEKS
-Healthchecksconfigured

**Files**:`/terraform/modules/alb-controller/`,`/k8s/ingress.yaml`

**OptionalFeatures**:
-TLSterminationsupport(withACMcertificate)
-HTTPSredirectcapability
-Customdomainsupport

**Verification**:
```bash
kubectlgetingress-nretail-app
#ShouldshowADDRESSwithALBDNSname
```

---

##9.CompliancewithTechnicalStandards

###✅NamingConventions

|Resource|RequiredName|ActualName|✅|
|----------|--------------|-------------|-----|
|AWSRegion|us-east-1|us-east-1|✅|
|EKSCluster|project-bedrock-cluster|project-bedrock-cluster|✅|
|VPC|project-bedrock-vpc|project-bedrock-vpc|✅|
|Namespace|retail-app|retail-app|✅|
|IAMUser|bedrock-dev-view|bedrock-dev-view|✅|
|S3Bucket|bedrock-assets-[student-id]|bedrock-assets-alt-soe-025-0275|✅|
|Lambda|bedrock-asset-processor|bedrock-asset-processor|✅|

###✅ResourceTagging

Allresourcestaggedwith:
```
Project:barakat-2025-capstone
ManagedBy:Terraform
Environment:production
StudentID:ALT-SOE-025-0275
```

**Verification**:
```bash
#CheckEKStags
awseksdescribe-cluster--nameproject-bedrock-cluster--query'cluster.tags'

#CheckVPCtags
awsec2describe-vpcs--filters"Name=tag:Name,Values=project-bedrock-vpc"--query'Vpcs[0].Tags'
```

###✅TerraformOutputs

Requiredoutputspresentinrootmodule:
-✅cluster_endpoint
-✅cluster_name
-✅region
-✅vpc_id
-✅assets_bucket_name

**Verification**:
```bash
cdterraform
terraformoutput
```

---

##10.TestingandValidation

###ApplicationTesting

**Test1:WebInterface**
```bash
#GetURL
ALB_URL=$(kubectlgetingressretail-app-ingress-nretail-app-ojsonpath='{.status.loadBalancer.ingress[0].hostname}')

#Testhomepage
curl-Ihttp://$ALB_URL
#Expected:HTTP/1.1200OK

#Openinbrowser
openhttp://$ALB_URL
```

**Test2:ServiceCommunication**
```bash
#Testinternalservicecommunication
kubectlexec-itdeployment/ui-nretail-app--curlcatalog:8080/health
#Expected:{"status":"healthy"}
```

###LambdaTesting

**Test3:S3EventTrigger**
```bash
#Uploadfile
awss3cptest-image.jpgs3://bedrock-assets-alt-soe-025-0275/products/

#Verifyprocessing
awslogstail/aws/lambda/bedrock-asset-processor--since1m
#Expected:"Imagereceived:products/test-image.jpg"
```

###SecurityTesting

**Test4:DeveloperAccess**
```bash
#Configuredevelopercredentials
awsconfigure--profilebedrock-dev
#[Enteraccesskeyandsecretfromgradingcredentials]

#Testreadaccess(shouldwork)
kubectlgetpods-nretail-app

#Testwriteaccess(shouldfail)
kubectldeletepod[POD-NAME]-nretail-app
#Expected:Errorfromserver(Forbidden)
```

###ObservabilityTesting

**Test5:CloudWatchLogs**
```bash
#Viewcontrolplanelogs
awslogstail/aws/eks/project-bedrock-cluster/cluster--since10m

#Viewapplicationlogs
kubectllogsdeployment/catalog-nretail-app--tail=50
```

---

##11.CostConsiderations

###MonthlyCostEstimate

|Service|Configuration|Est.Cost/Month|
|---------|--------------|-----------------|
|EKSCluster|1cluster|$72|
|EC2(Nodes)|3xt3.large|~$190|
|NATGateway|2gateways|~$65|
|ALB|1loadbalancer|~$23|
|RDSMySQL|db.t3.micro|~$15|
|RDSPostgreSQL|db.t3.micro|~$15|
|S3|Storage+requests|~$1|
|CloudWatch|Logs+metrics|~$10|
|**Total**||**~$391/month**|

**CostOptimizationStrategies**:
1.UseSpotInstancesfornon-productionworkloads
2.Enableclusterautoscalertoscaledownduringlowtraffic
3.UseS3lifecyclepoliciesforoldassets
4.OptimizeCloudWatchlogretention
5.ConsiderReservedInstancesforpredictableworkloads

---

##12.SecurityBestPracticesImplemented

###NetworkSecurity
-✅PrivatesubnetsforEKSnodes
-✅Securitygroupswithleast-privilegerules
-✅NATGatewaysforcontrolledegress

###IAMSecurity
-✅Least-privilegeIAMroles
-✅IAMRolesforServiceAccounts(IRSA)
-✅Nohardcodedcredentials

###DataSecurity
-✅S3bucketencryption(AES-256)
-✅RDSencryptionatrest
-✅SecretsstoredinAWSSecretsManager
-✅TLSfordataintransit(optionalHTTPS)

###KubernetesSecurity
-✅RBACenabled
-✅Namespaceisolation
-✅Read-onlydeveloperaccess
-✅Podsecuritystandards

---

##13.KnownLimitationsandFutureImprovements

###CurrentLimitations
1.Nomulti-regiondeployment(singleregion:us-east-1)
2.Basicmonitoring(CloudWatchonly,noPrometheus/Grafana)
3.Nodisasterrecoveryautomation
4.ManualRDSpasswordrotation

###FutureImprovements
1.**HighAvailability**:Multi-regionEKSclusterwithGlobalAccelerator
2.**AdvancedMonitoring**:Prometheus,Grafana,andJaegerfordistributedtracing
3.**GitOps**:ArgoCDforapplicationdeployment
4.**Security**:ImplementOPA/Gatekeeperforpolicyenforcement
5.**Scaling**:ClusterautoscalerandHPAforapplications
6.**Backup**:VeleroforKubernetesbackupandrestore
7.**Cost**:FinOpsdashboardforcostoptimization
8.**Secrets**:ExternalSecretsOperatorforsecretmanagement

---

##14.DocumentationLinks

###RepositoryDocumentation
-**MainREADME**:https://github.com/ififrank2013/bedrock-infra/blob/main/README.md
-**DeploymentGuide**:https://github.com/ififrank2013/bedrock-infra/blob/main/docs/DEPLOYMENT_GUIDE.md
-**TerraformModules**:https://github.com/ififrank2013/bedrock-infra/tree/main/terraform/modules

###AWSResources
-**EKSBestPractices**:https://aws.github.io/aws-eks-best-practices/
-**RetailStoreSampleApp**:https://github.com/aws-containers/retail-store-sample-app
-**AWSLoadBalancerController**:https://kubernetes-sigs.github.io/aws-load-balancer-controller/

---

##15.Acknowledgments

Specialthanksto:
-**AltSchoolAfrica**-Forprovidingthiscomprehensiveassessment
-**InnocentChukwuemeka**-Forcourseinstructionandguidance
-**AWS**-Forexcellentdocumentationandsampleapplications
-**Terraform**-Forinfrastructureascodetooling
-**KubernetesCommunity**-Forcontainerorchestrationplatform

---

##16.ContactInformation

**Student**:[YourName]
**Email**:[YourEmail]
**GitHub**:[@ififrank2013](https://github.com/ififrank2013)
**LinkedIn**:[YourLinkedIn]

**ForQuestionsorIssues**:
-OpenanissueonGitHub:https://github.com/ififrank2013/bedrock-infra/issues
-Email:[YourEmail]

---

##17.Declaration

Iherebydeclarethat:
1.Thisworkismyownoriginalwork
2.Allresourceshavebeenproperlycited
3.TheinfrastructureadherestoAWSbestpractices
4.Allnamingconventionsandstandardshavebeenfollowed
5.Thedeploymenthasbeentestedandvalidated

**Signature**:___________________
**Date**:February2026

---

**ENDOFSUBMISSIONDOCUMENT**

---

##QuickAccessLinks

-🔗**GitHubRepository**:https://github.com/ififrank2013/bedrock-infra
-🌐**ApplicationURL**:[YourALBURL]
-📊**ArchitectureDiagram**:[Yourdiagramlink]
-📝**GradingJSON**:https://github.com/ififrank2013/bedrock-infra/blob/main/grading.json
-📚**Documentation**:https://github.com/ififrank2013/bedrock-infra/blob/main/README.md

**ProjectStatus**:✅CompleteandReadyforGrading
