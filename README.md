# eks-terraform

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo chown root: /usr/local/bin/kubectl
kubectl version --client
kubectl get nodes
aws eks --region <aws-region>  update-kubeconfig --name <cluster-name>


/How to add gitlab token 

add service account in eks cluster,  

kubectl apply -f gitlab-admin-service-account.yaml

kubectl describe secret <gitlab-token>

