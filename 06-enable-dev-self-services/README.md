# Enable Developer Self-Service

These measures prevent workloads from affecting other workloads. Although RBAC can limit the kinds of resources that users can create, administrators might want further measures to ensure correct operation of the cluster.

Resource limits
- Kubernetes can limit the resources that a workload consumes. Workloads can specify an
upper bound of the resources that they expect to use under normal operation. If a workload
malfunctions or has unexpected load, then resource limits prevent the workload from
consuming an excessive amount of resources and impacting other workloads.

Resource requests
- Workloads can declare their minimum required resources. Kubernetes tracks requested
resources by workloads, and prevents deployments of new workloads if the cluster has
insufficient resources. Resource requests ensure that workloads get their needed resources.

Resource Quotas
- When a resource quota exists in a namespace, Kubernetes prevents the creation of
workloads that exceed the quota.

Cluster resource quotas 
- follow a similar structure to namespace resource quotas. However, cluster
resource quotas use selectors to choose which namespaces the quota applies to.
- Navigate to Administration > CustomResourceDefinitions

`oc create quota|resourcequota --help`

`oc create clusterresourcequota -h`

```
# max allowed
limits.cpu=
limits.memory=

# minimum resources
requests.cpu=
requests.memory=
```

# Per-Project Resource Constraints: Limit Ranges

Limit ranges are namespaced objects
that define limits for workloads within the namespace.

OpenShift introduces projects to improve security and users' experience of working with
namespaces. The OpenShift API server adds the Project resource type. When you make a query
to list projects, the API server lists namespaces, filters the visible namespaces to your user, and
returns the visible namespaces in project format.

When you create
a project request, the OpenShift API server creates a namespace from a template. By using
a template, cluster administrators can customize namespace creation. For example, cluster
administrators can ensure that new namespaces have specific permissions, resource quotas, or
limit ranges.

```
# search for self-provisioner clusterroles
oc get clusterrole | grep self-pro

# describe self-provisioner
oc describe clusterrole self-provisioner

# check the role bindings
oc get clusterrolebindings -o wide | grep self-provision

# check the self-provisioners
oc get clusterrolebindings self-provisioners -o yaml

# if you remove a cluster role binding
oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth^C


# notice this will pull from the hardcoded setting and recreate from binding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"

# to prevent overwritting your changes, you have to change annotation to FALSE
# you also have to change the subject to a NULL value

```

You can only have 1 tempalate per cluster

`oc get projects.config.openshift.io cluster -o yaml`

This template has the same behavior as the default project creation in OpenShift. The template
adds a role binding that grants the admin cluster role over the new namespace to the user who
requests the project.

`oc adm create-bootstrap-project-template -o yaml > file`

REMEMBER CHANGE BINDINGS NOT ROLES FOR THE EXAM.

make it persistent across reboots CHANGE to `false`
`rbac.authorization.kubernetes.io/autoupdate: "true"`

to disable self-provisioning
```
 oc annotate clusterrolebinding/self-provisioners \
 --overwrite rbac.authorization.kubernetes.io/autoupdate=false

 oc patch clusterrolebinding.rbac self-provisioners \
 -p '{"subjects": null}'
```

remember to update the api server
`oc edit projects.config.openshift.io cluster`