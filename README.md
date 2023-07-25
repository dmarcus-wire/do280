# do280
Red Hat OpenShift Administration II: Operating a Production Kubernetes Cluster

# sections

1. Declarative Resource Management  
    1. Imperative commands perform actions, such as creating a deployment, by specifying all
    necessary parameters as command-line arguments.
    1. In the declarative workflow, you create manifests that describe resources in the YAML or JSON
    formats, and use commands such as kubectl apply to deploy the resources to a cluster.
    1. Kubernetes provides tools, such as the kubectl diff command, to review your changes
    before applying them.
    1. You can use Kustomize to create multiple deployments from a single base code with different
    customizations.
    1. The kubectl command integrates Kustomize into the apply subcommand and others.
    1. Kustomize organizes content around bases and overlays.
    1. Bases and overlays can create and modify existing resources from other bases and overlays
1. Deploy Packaged Applications  
    1. Deploy an application and its dependencies from resource manifests that are stored in an OpenShift template.
    1. Deploy and update applications from resource manifests that are packaged as Helm charts.
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

## chapter 1
```
# git clone
$ git clone https://<URL> --branch vN.N.N

# checkout branch
$ git branch -a
$ git checkout vN.N.N

# check commit
$ git log --oneline OR git show

# check project structure
$ tree

# create new project
$ oc new-project <name>

# apply kustomize
$ oc apply -k base --dry-run=client --validate=true
$ oc apply -k base

# checkout branch
$ git checkout vN.N.N

# check commit
$ git log --oneline OR git show

# check project structure
$ tree

# check the diiff
$ oc diff -k base

# apply kustomize
$ oc apply -k base --dry-run=client --validate=true

# create a new prod project
$ oc new-project declarative-review-production

# apply kustomize
$ oc apply -k overlays/production
```

## chapter 2
```

```