# Diploma
Configuting K8s for BMSTU department

Link to the thesis - [GoogleDocs](https://docs.google.com/document/d/1j3J5q9caRZ7amjac2oHKkS3EQivKc2Pc/edit)

K8s token is placed in /tmp/kubernetes_join_command
kubectl taint node <NODE_NAME> node-role.kubernetes.io/control-plane:NoSchedule-

http://prometheus.kube-system.svc.cluster.local:9090 - DNS for Grafana -> Prometheus

Grafana dashboard is 315

### Terraform
Installing Terraform<br>
<code>brew tap hashicorp/tap</code> <br>
<code>brew update</code><br>
<code>brew install terraform</code><br>

Check terraform version <br> 
<code>terraform -version</code>

"Terraform" folder contains everything for deploying Kubernetes enitities to Cluster.<br>
Prerequisite: <br>
<ul>
  <li>Execute command in the kubernetes control plane: <br> <code>kubectl config view --minify --flatten </code> </li>
  <li>Copy and paste cluster credentials and host to <b>terraform.tfvars:</b> <br>
  </li>
</ul>

   ```
      host                   = "https://127.0.0.1:32768"
      client_certificate     = "LS0tLS1CRUdJTiB..."
      client_key             = "LS0tLS1CRUdJTiB..."
      cluster_ca_certificate = "LS0tLS1CRUdJTiB..."
   ```
Thanks for attention!
