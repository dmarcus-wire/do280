# do280
Red Hat OpenShift Administration II: Operating a Production Kubernetes Cluster

# sections

1. Declarative Resource Management  
    1. Imperative commands perform actions, such as creating a deployment, by specifying all
    necessary parameters as command-line arguments.
        1. Impaired reproducibility
        1. Lacking version control
        1. Lacking support for GitOps
    1. In the declarative workflow, you create manifests that describe resources in the YAML or JSON
    formats, and use commands such as kubectl apply to deploy the resources to a cluster.
1. Deploy Packaged Applications
    1. 3 ways to deploy
        1. ocp templates
            1. oc process
        1. kustomize
            1. oc apply -k
        1. helm
            1. oc ????
1. Authentication and Authorization      
1. Network Security
    1. first, you need a TLS certificate
    1.  3 ways to secure routes
        1. edge (on the router)
        1. passthrough (on the app)
        1. re-encryption
    1. `networkpolicy` control pod to pod and namespace to namespace allowed traffic (think firewall)
    1. using the tls protocol to encrypt traffic between pods for allowed networkpolicies (think encryption)
    1. `oc set volumes`
1. Expose non-HTTP/SNI Applications    
1. Enable Developer Self-Service      
1. Manage Kubernetes Operators      
1. Application Security      
1. OpenShift Updates      

# Resources:
1. [Which do you choose (template, kustomize, and helm)](https://learn.redhat.com/t5/Containers-DevOps-OpenShift/Helm-chart-Templates-or-Kustomization-file/m-p/22321/highlight/true#M1293)
1. [Certified Helm Chart Requirements](https://redhat-connect.gitbook.io/partner-guide-for-red-hat-openshift-and-container/helm-chart-certification/overview)
1. [OpenShift Helm Charts](https://charts.openshift.io/)

# configuration

## config aliases
```
alias kl='oc login -u kubeadmin -p <password> https://api.ocp4.example.com:6443'
alias al='oc login -u admin -p <password> https://api.ocp4.example.com:6443'
alias dl='oc login -u developer -p <password> https://api.ocp4.example.com:6443'
source .bashrc
```
## config vimrc
```
# eat new sweets 
set et nu sw=2 ts=2
```

## Configure oc tab completion (KNOW)

```
oc completion bash > oc_completion
source oc_completion
```

# review
https://www.redhat.com/en/services/training/red-hat-certified-openshift-administrator-exam?section=objectives 

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