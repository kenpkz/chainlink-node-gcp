# Chainlink Node On Google Cloud With Confidential Compute, AlloyDB and Identity Aware Proxy 

## Create AlloyDB
Terraform provide for AlloyDB has not been released, hence we will use gcloud SDK to provision the AlloyDB clsuter, instnce and the database.

* refer to the [official Google Cloud AlloyDB doc](https://cloud.google.com/alloydb/docs/cluster-create) for the ***prerequisites*** such as VPC Private Service Control and IAM permissions
* replace `region`, `location`, `project` etc. in the code below to your own value


#### Create a secret in Secret Manager for the AlloyDB Password

```bash
printf $(gpg --gen-random --armor 1 13) | gcloud secrets create alloydb-password --data-file=-
```

#### Creaet Chainlink API password & login password
We will need these secrets to launch Chainlink node later
```bash
printf $(gpg --gen-random --armor 1 13) | gcloud secrets create chainlink-password --data-file=-
printf $(gpg --gen-random --armor 1 13) | gcloud secrets create api-password --data-file=-
```

#### Create the AlloyDB Cluster

* Enable required APIs based on this [doc](https://cloud.google.com/alloydb/docs/project-enable-access)

* Change the `project`, `network`, `region` parameter to your own values 
```bash
gcloud beta alloydb clusters create chainlink-cluster \
    --password=$(gcloud secrets versions access 1 --secret="alloydb-password") \
    --network=default \
    --region=asia-southeast1 \
    --project=chainlink-node-351704

```
#### Create the AlloyDB Instance

```bash
gcloud beta alloydb instances create chainlink-instance \
    --instance-type=PRIMARY \
    --cpu-count=4 \
    --region=asia-southeast1 \
    --cluster=chainlink-cluster \
    --project=chainlink-node-351704

```
#### Create the database
Follow the [instructions here to connect to the AlloyDB Instance](https://cloud.google.com/alloydb/docs/connect-psql)

Follow the [instructions here to create a database](https://cloud.google.com/alloydb/docs/database-create)

You can retrieve the AlloyDB password from Secret Manager

>Use `chainlinkdb` as the database name, or you can define your own value, but ensure you edit the databse name accordingly on line 23 in the `startup.sh` file



## Create GCE VM Managed Instance Group

#### Create VM Template
We will create a Confidential Compute VM template for the Chainlink node without the public IP address. We will use Identity Aware Proxy to access the machine, and Google Cloud Load Balancer to expose the 

* Replace `[your-gcp-project-id]`
* Replace `[your-service-account]`
* Replace 

```bash
gcloud compute instance-templates create-with-container chainlink-node-template --project=[your-gcp-project-id] --machine-type=n2d-standard-4 --network-interface=subnet=default,no-address --maintenance-policy=TERMINATE --provisioning-model=STANDARD --service-account=[your-service-account] --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --region=asia-east2 --tags=chainlink-node --container-image=smartcontract/chainlink --container-restart-policy=always --create-disk=auto-delete=yes,boot=yes,device-name=chainlink-node-template,image=projects/confidential-vm-images/global/images/ubuntu-2004-focal-v20220404,mode=rw,size=100,type=pd-balanced --shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=container-vm=ubuntu-2004-focal-v20220404

```




## Create AlloDB PostgreSQL



```

### Create Alloydb Cluster
```
gcloud beta alloydb clusters create my-cluster --region=asia-southeast1 --password=postgres

```