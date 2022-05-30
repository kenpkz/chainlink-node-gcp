# Chainlink Node On Google Cloud With Confidential Compute, AlloyDB and Identity Aware Proxy 

**A guided setup is available via clicking the button below.**

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/kenpkz/chainlink-node-gcp&cloudshell_tutorial=tutorial.md)

### Architecture

![Architecture](./Chainlink%20GCP%20Architecture.png)

The architect leverages following  Google Cloud products to enhance the overall security
* **Identity Aware Proxy** (a part of the Google's zero trust network access solution) - Chainlink Nodes do not require public IP address. SSH to the nodes and web access for the node operator web page are authenticated against GCP Cloud Identity
* **Confidential Compute** - encryption-in-process is realised, becasue the memory is encrypted with a key generated from the chip at the boot time
* **Secret Manager** - Securely store the AlloyDB password, Chainlink wallet password, and the Chainlink API secret
* **Private Service Connect** - Allow the access between the Chainlink node and AlloyDB via private IP addresses customer defined in the scustomer owned subnet


#### Note
* AlloyDB is a pre-GA product at the time of writing this doc, hence the deployment of the AlloyDB is not orchestrated using Terraform. I will update the code or feel free to raise a pull request to update the code.
* Chainlink node VM contains secrets in plaintext such Chianlink wallet password, API secret, and the AlloyDB password