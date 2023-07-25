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