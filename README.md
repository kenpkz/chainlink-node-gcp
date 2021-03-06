# Chainlink Node On Google Cloud 

This blog unpacks the architecture of the Chainlink nodes on Google Cloud blueprint and key Google Cloud products involved. If you’d like to deploy the blueprint directly, feel free to click the button below to start the guided setup or visit the [Github Repo](https://github.com/kenpkz/chainlink-node-gcp)

### Clicking the button below to start the guided setup 

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/kenpkz/chainlink-node-gcp&cloudshell_tutorial=tutorial.md)

### Architecture

![Architecture](./Chainlink%20GCP%20Architecture.png)

**Key products used in the setup**
###[Confidential Compute](https://cloud.google.com/confidential-computing) 
With 2nd Gen AMD EPYC CPUs, Confidential Computing realises encryption-in-process without any application code change and minimum performance impact. This feature provides the Chainlink operators an additional layer of trust.

### [AlloyDB For PostgreSQL](https://cloud.google.com/alloydb)
AlloyDB For PostgreSQL is a fully managed and highly available PostgreSQL-compatible database service for the Chainlink node backend.

### [Identity Aware Proxy (IAP)](https://cloud.google.com/iap) 
  
IAP is a part of Google's zero trust network access solution. With IAP, Chainlink Node VMs do not require public IP addresses. SSH to the nodes, and web access for the node operator web page are authenticated against GCP Cloud Identity via IAP.

### [Secret Manager](https://cloud.google.com/secret-manager)
Secret Manager is used to securely store the AlloyDB password, Chainlink wallet password, and the Chainlink API secrets. 


### [Private Service Connect](https://cloud.google.com/vpc/docs/private-service-connect)
Private Service Connect allows the access between the Chainlink node VMs and AlloyDB through private IP addresses defined in the customer owned subnet.


#### Note
* AlloyDB is a pre-GA product at the time of writing this blog, there isn’t a Terraform provider for AlloyDB, hence the deployment of the AlloyDB in this blueprint is not orchestrated through Terraform. Feel free to update the code on your own, or raise a Github pull request, once the Terraform provider for AlloyDB becomes available.
* At the startup time, Chainlink software requires plaintext secrets on the disk. Therefore the Chainlink node VM contains secrets in plaintext, such as Chianlink wallet password, API secret, and the AlloyDB password. Node operators should remove the .env, .password, and .api files after confirming the Chainlink node is running as expected.