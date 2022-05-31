# Chainlink Node On Google Cloud With Confidential Compute, AlloyDB and Identity Aware Proxy 
## Creating secrets required in Secret Manager
## It is recommended to start with a brand new GCP project for this setup
#### Create a secret in Secret Manager for the AlloyDB Password

```bash
gcloud services enable secretmanager.googleapis.com
```

```bash
printf $(gpg --gen-random --armor 1 13) | gcloud secrets create alloydb-password --data-file=-
```

#### Creaet Chainlink API password & login password
We will need these secrets to launch Chainlink node later
```bash
printf $(gpg --gen-random --armor 1 13) | gcloud secrets create chainlink-password --data-file=-
printf $(gpg --gen-random --armor 1 13) | gcloud secrets create api-password --data-file=-
```

## Create AlloyDB
Terraform provide for AlloyDB has not been released, hence we will use gcloud SDK to provision the AlloyDB clsuter, instnce and the database.

* refer to the [official Google Cloud AlloyDB doc](https://cloud.google.com/alloydb/docs/cluster-create) for the ***prerequisites*** such as VPC Private Service Control and IAM permissions
* ensure the VPC, Private Service Connect are setup


#### Create the AlloyDB Cluster

* Enable required APIs based on this [doc](https://cloud.google.com/alloydb/docs/project-enable-access)

* Change the `project`, `network`, `region`, `network` parameter to your own values 
```bash
gcloud beta alloydb clusters create chainlink-cluster \
    --password=$(gcloud secrets versions access 1 --secret="alloydb-password") \
    --network=default \
    --region=asia-southeast1 \
    --project=`your project`

```
#### Create the AlloyDB Instance

```bash
gcloud beta alloydb instances create chainlink-instance \
    --instance-type=PRIMARY \
    --cpu-count=4 \
    --region=asia-southeast1 \
    --cluster=chainlink-cluster \
    --project=`your project`

```
#### Create the database
Follow the [instructions here to connect to the AlloyDB Instance](https://cloud.google.com/alloydb/docs/connect-psql)

Follow the [instructions here to create a database](https://cloud.google.com/alloydb/docs/database-create)

You can retrieve the AlloyDB password from Secret Manager

>Use `chainlinkdb` as the database name, or you can define your own value, but ensure you edit the databse name accordingly on line 23 in the `startup.sh` file



## Create Chianlink Node Confidential VMs, Global HTTPS Load Balancer etc. using Terraform



> The prerequisites are the GPC project, VPC have been provisioned, and the IAM identity to execute the Terraform code has sufficient privilege. If you are following along using the Cloud Shell tutorial, it will be the IAM identity that you used to sign in the current GCP session.

> You can manually enable required GCP product APIs listed in the `services.renamemetotf` file. Or you can change the `services.renamemetotf` file to `services.tf`, Terraform will enable the service APIs. **Be careful if you use Terraform to enable APIs and run `terraform destroy`, there might errors because the service APIs might get deleted before depended resources.**   

#### Prepare the Terraform scripts
1. Change the variables to your own values in the `terraform.tfvars` file
2. Change the AlloyDB Instance IP address on line 25 in the `startup.sh` file
3. Change the Chainlink login email address to your own value on line 28 in the `startup.sh` file

> The setup is using the rinkeby testnet, if you would like to point to the mainnet, change the setting in the `startup.sh` file accordingly based on the Chainlink official doc [here](https://docs.chain.link/docs/running-a-chainlink-node/)

#### Execute the Terraform scripts
```bash
terraform init
terraform plan -var-file="terraform.tfvars"
```
Check the output of the Terraform plan

```bash
terraform apply -var-file="terraform.tfvars" --auto-approve
```

> **Notes** 
> * The VM startup script will bring up the ethereum client and the chainlink node, and it will take some time. The console may be showing the VMs are ready, but the scripts might still be running in the background. 
> * Give it 5 - 10 minutes, and SSH into VMs to check if docker images are running using `sudo docker ps`
> * One of the VMs will show chainlink node container as "unhealthy", and the other VM has chainlink node container showing "healthy". This is an expected behaviour as Chainlink node is currently single threaded.

## Configure the TLS Certificate
On line 61 in the `chainlink-mig-lb.tf` file, we provisioned a Google managed TLS certificate based on the domain provied on line 7 in the `terraform.tfvars` file. To finalise the certificate provisioning, we need to add an A record for the domain.

1. Find the provisioned HTTPS Load Balancer external IP address
   ```bash
   gcloud compute forwarding-rules list --filter="NAME:(chainlink-lb-https)"
   ```
2. Create an A record for your chosen domain with the IP address above

It will take sometime for the certificate to be fully provisioned after the A record is added. You can check the status using the command below.

```bash
gcloud compute ssl-certificates list
```

## Configure the Identity Aware Proxy, Cloud Armor for the Chainlink Web Access
#### Identity Aware Proxy
Assign the identities with `roles/iap.httpsResourceAccessor` role, refer to the doc [here](https://cloud.google.com/iap/docs/managing-access)

```bash
gcloud iap web remove-iam-policy-binding --resource-type=backend-services --service=chainlink-lb-backend-default --member='user:your@user.com' --role='roles/iap.httpsResourceAccessor'

```

> Note HTTPS access on the HTTPS Load Balancer must be working before the IAP web access can function correclty

#### Cloud Armor
In this setup, we only apply the rate limiting policy. Adjust the parameters in the policy below to your own values, refer to the doc [here] (https://cloud.google.com/armor/docs/configure-security-policies#rate-limiting) for more details.

Create the Cloud Armor policy and the rate limiting rule
```bash
gcloud compute security-policies create sec-policy --type=CLOUD_ARMOR

gcloud compute security-policies rules create 100 \
    --security-policy sec-policy     \
    --src-ip-ranges="0.0.0.0/0"     \
    --action=throttle                \
    --rate-limit-threshold-count=10000 \
    --rate-limit-threshold-interval-sec=60 \
    --conform-action=allow           \
    --exceed-action=deny-429         \
    --enforce-on-key=IP
```

Attach the policy to the HTTPS Load Balancer. When prompted, choose `[1]` the global as the region
```bash
gcloud compute backend-services update chainlink-lb-backend-default --security-policy=sec-policy
```

## Access the Chainlink Web Page
Retrieve the password from the Secret Manager
```bash
gcloud secrets versions access 1 --secret="api-password"
```

Browse to the domain that you set, and use the username you set in the `startup.sh` line 28 and the password from the gcloud above

