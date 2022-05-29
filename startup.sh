#!/bin/bash
apt-get update
apt-get install docker.io -y

# Change the service account to the service account created in the chainlink-node-template.tf, which is used by the GCE VMs. The format is chainlink-sa@[your-project-id].iam.gserviceaccount.com
gcloud config set account chainlink-sa@chainlink-node-351704.iam.gserviceaccount.com

# Start Ethereum client
mkdir ~/.geth-rinkeby
docker pull ethereum/client-go:latest
docker run --name eth -d -p 8546:8546 -v ~/.geth-rinkeby:/geth -it ethereum/client-go --rinkeby --ws --ipcdisable --ws.addr 0.0.0.0 --ws.origins="*" --datadir /geth

# Start Chainlink
mkdir ~/.chainlink-rinkeby
echo "ROOT=/chainlink
LOG_LEVEL=debug
ETH_CHAIN_ID=4
CHAINLINK_TLS_PORT=0
SECURE_COOKIES=false
ALLOW_ORIGINS=*" > ~/.chainlink-rinkeby/.env
ETH_CONTAINER_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker ps -f name=eth -q))
echo "ETH_URL=ws://$ETH_CONTAINER_IP:8546" >> ~/.chainlink-rinkeby/.env
# Once AlloDB methods become GA, you could use following command to find the instance IP address, as opposed to hardcoding it here $(gcloud beta alloydb instances describe chainlink-instance --cluster=chainlink-cluster --region=asia-southeast1 --format="value(ipAddress)")
echo "DATABASE_URL=postgresql://postgres:$(gcloud secrets versions access 1 --secret="alloydb-password")@10.103.72.2:5432/chainlinkdb" >> ~/.chainlink-rinkeby/.env

# Change the email to your defined value
echo "user@example.com" > ~/.chainlink-rinkeby/.api
echo $(gcloud secrets versions access 1 --secret="api-password") >> ~/.chainlink-rinkeby/.api
echo $(gcloud secrets versions access 1 --secret="chainlink-password") > ~/.chainlink-rinkeby/.password
cd ~/.chainlink-rinkeby && docker run -d -p 6688:6688 -v ~/.chainlink-rinkeby:/chainlink -it --env-file=.env smartcontract/chainlink:1.3.0 local n -p /chainlink/.password -a /chainlink/.api

