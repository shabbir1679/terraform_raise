import json,os,yaml

clustername=os.environ['clustername']
output = os.popen ("kubectl --kubeconfig=config get namespaces -o yaml").read()
data=yaml.load(output)

ifClsuterHasingressnginxNamespace=False

allnamespaces = []

#Get the ingress-nginx namespace else this is not applicable
for item in data['items']:
  if item['metadata']['name'] == 'ingress-nginx':
    ifClsuterHasingressnginxNamespace=True
  else:
    allnamespaces.append (item['metadata']['name'])

if ifClsuterHasingressnginxNamespace == False:
  print 'No ingress-nginx namespace on this cluster'
  exit(1)

#Get the nginx serice detail to find the dns for aws load balancer
output = os.popen ("kubectl --kubeconfig=config get svc ingress-nginx -n ingress-nginx -o yaml").read()
data=yaml.load(output)

awslbdns=data['status']['loadBalancer']['ingress'][0]['hostname']

#Get the elb id
desclb = 'aws elb describe-load-balancers --query \'LoadBalancerDescriptions[?DNSName==`'+awslbdns+'`]\' --region us-east-1'
print desclb
output = os.popen(desclb)
data=json.load(output)
securityGroups = data[0]['SecurityGroups']
awslb=data[0]['LoadBalancerName']
#print awslb

#Add all the existing nodeports to this
existinginstanceports = []
loadbalancerports = []

for listener in data[0]['ListenerDescriptions']:
  print listener['Listener']
  existinginstanceports.append(listener['Listener']['InstancePort'])
  loadbalancerports.append(listener['Listener']['LoadBalancerPort'])

print existinginstanceports
print loadbalancerports

#If the nodeport is not present in the ELB then add the new listener to ELB
for namespace in allnamespaces:
  svccmd = 'kubectl get svc -n {0} -o yaml'.format(namespace)
  metadatastr = os.popen(svccmd).read()
  datametadata=yaml.load(metadatastr)
  for svc in datametadata['items']:
    if svc['spec']['type'] == 'NodePort':
      labels = svc['metadata'].get('labels', None)
      if labels == None:
        continue
      portname = labels.get ('loadbalncerupdate', None)
      if portname:
        for port in svc['spec']['ports']:
          if portname != port['name']:
            continue
          print port
          #If the node port id not present
          if port['nodePort'] not in existinginstanceports:
            print port['targetPort']

            #When service is redeployed nodeport changes so needs to delete and add again
            if port['targetPort'] in loadbalancerports:
              deletlistener="aws elb delete-load-balancer-listeners --load-balancer-name {0} --load-balancer-ports {1}".format(awslb, port['targetPort'])
              print os.popen(deletlistener).read()

            listenercmd ="aws elb create-load-balancer-listeners --load-balancer-name {0} --listeners Protocol=tcp,LoadBalancerPort={1},InstanceProtocol=tcp,InstancePort={2}".format(awslb, port['targetPort'],port['nodePort'])
            print os.popen(listenercmd).read()
            for securitygroup in securityGroups:
              print securitygroup
              sgcmd = 'aws ec2 authorize-security-group-ingress --group-id {0} --protocol tcp --port {1} --cidr 0.0.0.0/0'.format(securitygroup, port['targetPort'])
              print os.popen(sgcmd).read()
              #print listenercmd
          
          #rare scenario. Nodeport is present but target port is different
          elif port['targetPort'] not in loadbalancerports:
            deletlistener="aws elb delete-load-balancer-listeners --load-balancer-name {0} --load-balancer-ports {1}".format(awslb, port['targetPort'])
            print os.popen(deletlistener).read()
            listenercmd ="aws elb create-load-balancer-listeners --load-balancer-name {0} --listeners Protocol=tcp,LoadBalancerPort={1},InstanceProtocol=tcp,InstancePort={2}".format(awslb, port['targetPort'],port['nodePort'])
            print os.popen(listenercmd).read()
            for securitygroup in securityGroups:
              print securitygroup
              sgcmd = 'aws ec2 authorize-security-group-ingress --group-id {0} --protocol tcp --port {1} --cidr 0.0.0.0/0'.format(securitygroup, port['targetPort'])
              print os.popen(sgcmd).read()
            
          else:
            print "ELB is already updated with "+str(port['targetPort'])
          #print os.popen(listenercmd).read()

