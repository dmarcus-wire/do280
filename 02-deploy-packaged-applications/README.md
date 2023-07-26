# OpenShift Templates

A template is a Kubernetes custom resource that describes a set of Kubernetes resource
configurations. Templates can have parameters. You can create a set of related Kubernetes
resources from a template by processing the template, and providing values for the parameters.

The template resource is a Kubernetes extension that Red Hat for OpenShift provides. The Cluster
Samples Operator populates templates (and image streams) in the openshift namespace. You
can opt out of adding templates during installation, and you can restrict the list of templates that
the operator populates.

The templates that the *Cluster Samples Operator* provides are in the openshift namespace
`$ oc get templates -n openshift`

To evaluate any template, use the oc describe template template-name -n openshift
command to view more details about the template, including the description, the labels that the
template uses, the template parameters, and the resources that the template generates.

`$ oc describe template cache-service -n openshift`

`oc process` command turns templates into resources

## oc new-app (Imparative)
Using the oc new-app command to deploy the template resources is convenient for
development and testing. However, for production usage, consume templates in a manner that
helps resource and configuration tracking. For example, the oc new-app command can only
create new resources, not update existing resources.

## oc process (Declarative)
You can use the oc process command to apply parameters to a template, to produce manifests
to deploy the templates with a set of parameters. The oc process command can process both
templates that are stored in files locally, and templates that are stored in the cluster. However, to
process templates in a namespace, you must have write permissions on the template namespace.
- Use the -f option with the oc process command to process a template that is defined in a file:
- Use -o yaml

THIS IS JUST STDIN, so you have to | oc apply -f - OR writeout to .yaml than apply

## Lab

```
# search templates
$ oc get template -n openshift | grep mysql

# describe the template; see the objects it will create; the parameters you can set
$ oc describe templates mysql-persistent -n openshift
OR
# to see the params
$ oc process --parameters mysql-persistent -n openshift

# create a new project
oc new-project packaged-tempaltes

# deploy the template with custom parameters
$ oc new-app --template=mysql-persistent -p MYSQL_USER=user1 -p MYSQL_PASSWORD=mypassword

# see what is created
$ oc get all

# quick test
$ oc rsh mysql-<pod>
env
> mysql -uuser1 -pmypassword
> show databases;

# process the frontend tempalte
$ oc process --parameters roster-template
$ oc process roster-template -p MYSQL_USER=user1 -p MYSQL_PASSWORD=mypasswd -p INIT_DB=true

# apply the template
$ oc process roster-template -p MYSQL_USER=user1 -p MYSQL_PASSWORD=mypasswd -p INIT_DB=true | oc apply -f -

# create a parameters file to update the objects with new parameters
MYSQL_USER=user1
MYSQL_PASSWORD=mypasswd
IMAGE=registry.ocp4.example.com:8443/redhattraining/do280-roster:v2

# test before pushing
$ oc process roster-template --param-file=params -o yaml | grep image

# check the diff against the server file
$ oc process roster-template --param-file=params -o yaml | oc diff -f -

# apply it
$
```

# Helm

Helm is an open source application that helps to manage the lifecycle of Kubernetes applications.
Helm introduces the concept of charts. A chart is a package that describes a set of Kubernetes
resources that you can deploy. Helm charts define values that you can customize when deploying
an application. Helm includes functions to distribute charts and updates.

However, Helm does not cover all needs to manage certain kinds of applications. Operators have a
more complete model that can handle the lifecycle of more complex applications. 

A Helm chart defines Kubernetes resources that you can deploy. A chart is a collection of files
with a defined structure. These files include chart metadata (such as the chart name or version),
resource definitions, and supporting material.
- how would you take a backup of the data to prepare for an upgrade?
- how do you do dynamic application scaling?
- how do you install and uninstall intelligently?

Helm is a command-line application. 

The helm command interacts with the following entities:
1. Charts - Charts are the packaged applications that the helm command deploys.
1. Releases - A release is the result of deploying a chart. You can deploy a chart many times to the same
cluster. Each deployment is a different release.
1. Versions - A Helm chart can have many versions. Chart authors can release updates to charts, to adapt
to later application versions, introduce new features, or fix issues.

When you CREATE A RELEASE, it means you are installing a certain version

## Installing Helm
[For installing Helm on OpenShift](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.13/html/building_applications/working-with-helm-charts#on-linux)
1. checkout https://mirror.openshift.com/pub/
1. go to OCP v4 > Clients > [helm](https://mirror.openshift.com/pub/openshift-v4/clients/)
1. `wget https://developers.redhat.com/content-gateway/file/pub/openshift-v4/clients/helm/3.11.1/helm-linux-amd64``
1. `chmod 755 helm-linux-amd64``
1. `mv helm-linux-amd64 /usr/local/bin/helm``

## Using Helm
```
# helm [tab] [tab]

# check your helm version
helm version

# check your helm source
which helm

# which repos do you have access to
helm repo list

# add a repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# update the cache for helm
helm repo update

# search for a chart via CLI
helm search repo --versions
helm search repo hashicorp

# list the chart
helm show chart openshift-helm-charts/hashicorp-vault 

# show the configuration details about the chart
helm show values openshift-helm-charts/hashicorp-vault 

# you can override the chart with a Kustomize overlay

# add the helm charts to openshift web console
oc apply -f https://charts.openshift.io/openshift-charts-repo.yaml

# search the web console
oc whoami --show-console

# log in to web console > developer perspective > create a project > search developer catalog

```

## example take chart, create a release

```
# create new project
oc new-project helm-test

# add repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# search repo 
helm search repo --versions
helm search repo hashicorp

# dry run install a chart (needs admin because its creating clusterrole)
helm install testvault openshift-helm-charts/hashicorp-vault --dry-run -o yaml

# install the chart
helm install testvault openshift-helm-charts/hashicorp-vault 

# check the status
helm status testvault

# what did it create
oc get all
helm get manifest testvault | grep kind

# uninstall the helm chart
helm uninstall testvault

# list charts
helm list
```