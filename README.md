# do280
Red Hat OpenShift Administration II: Operating a Production Kubernetes Cluster

# sections

1. Declarative Resource Management  
    1. Deploy applications from resource manifests from YAML files that are stored in a GitLab repository.
    1. Inspect new manifests for potential update issues.
    1. Update application deployments from new YAML manifests.
    1. Force the redeployment of pods when necessary
    1. Deploy and update applications from resource manifests that are augmented by Kustomize.
1. Deploy Packaged Applications    
1. Authentication and Authorization      
1. Network Security            
1. Expose non-HTTP/SNI Applications    
1. Enable Developer Self-Service      
1. Manage Kubernetes Operators      
1. Application Security      
1. OpenShift Updates      

# configuration
1. config aliases
```
alias kl='oc login -u kubeadmin -p <password> https://api.ocp4.example.com:6443'
alias al='oc login -u admin -p <password> https://api.ocp4.example.com:6443'
alias dl='oc login -u developer -p <password> https://api.ocp4.example.com:6443'
source .bashrc
```
1. config vimrc
```
# eat new sweets 
set et nu sw=2 ts=2
```

# review