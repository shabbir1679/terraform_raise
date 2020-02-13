kops get clusters --state s3://tools-data-toolstsyspropenterprise-us-east-1-tsys/kops
kops export kubecfg --name $clustername --state s3://tools-data-toolstsyspropenterprise-us-east-1-tsys/kops
cp /var/jenkins_home/.kube/config .

#kubectl --kubeconfig=config get node 
kubectl --kubeconfig=config config use-context $clustername 
#kubectl --kubeconfig=config get node --kubeconfig=config

