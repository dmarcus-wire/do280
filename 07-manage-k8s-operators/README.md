
OCP is a bunch of operators running on K8s

Dump all the Operators
`oc get operatorhubs.config.openshift.io -o yaml`

Get the catalog source, to see what package manifests are available
`oc get catalogsources.operators.coreos.com -A`

notice the disabled sources

```
  spec:
    disableAllDefaultSources: true
```

the operator will extend the k8s api
when oc sends commands like get|describe to the operator it can do these new things

# Cluster Version Operator (CVO)

the boss operator. reports all the status.

CVO all cluster operators
OLM all the addon operators

```
# the results of this command
oc get co

# are handled by the CVO
oc get clusterversion

# understand what it watches
oc describe clusterversions.config.openshift.io 

# the pod where CVO is running
oc get pods -n openshift-cluster-versiion

# for example installing the File Integrity Operator
oc get api-resources | grep -i file
```

How can you see what an operator will or creates?
The operator Install Plan
The Cluster Service Version

To install an operator, you must perform the following steps:
• Locate the operator to install.
• Review the operator and its documentation for installation options and requirements.
– Decide the update channel to use.
– Decide the installation mode. For most operators, you should make them available to all
namespaces.
– Decide to deploy the operator workload to an existing namespace or to a new namespace.
– Decide whether the Operator Lifecycle Manager (OLM) applies updates automatically, or
requires an administrator to approve updates.
• Create an operator group if needed for the installation mode.
• Create a namespace for the operator workload if needed.
• Create the operator subscription.
• Review and test the operator installation.

## OLM Operator Resources Types
1. Catalog source - OLM
examines the catalog sources in the cluster and retrieves information about the operators in
each source
1. Package manifest - contains the required information to install an operator, such as the available channels
1. Operator group - define how the OLM presents operators across namespaces (which namespace to install the operator to)
1. Subscription - when it's time to install something
1. Operator - OLM creates operator resources to store information about installed operators
1. Install plan - OLM creates install plan resources as part of the installation and update process; what it's about to do
1. Cluster service version (CSV) - The CSV contains the information that the OLM requires to install the operator

```
# 0) examine catalog sources
oc get catalogsource -n openshift-marketplace

# list the package manifests for operators available to install
oc get packagemanifest

# get operator details oc describe packagemanifest from the marketplace
oc describe packagemanifest file-integrity-operator -n openshift-marketplace

# pod admission controller, not to allow workloads to run as privileged 

# 1) create and apply the namespace for the operator pod to run in
oc apply -f namespace.yaml

# 2) create and apply an operatorgroup in the namespace you create to confine the operator to a namespace
# if you are installing an operator that runs in all namespaces, use openshift-operators
oc apply -f operatorgroup.yaml

# 3) create and apply the a subscription (remember Installation) - remember this sets the installPlanApproval
oc apply -f subscription.yaml

# 4) get and review the install plan; when the install plan is approved it creates the CSV
oc get installplans
oc describe installplans install-rwbcf

# 5) if the installplan is manual, edit the installplan to set the spec.approved true

# 6) now you have a CSV (it's held until the installplan is approved)

# 7) uninstall the subscription and the CSV and OLM will cleanup the workload
oc delete subscriptions.operators.coreos.com file-integrity-operator && oc delete csv file-integrity-operator.v1.2.1

```

OLM is a Red Hat thing.
K8s

https://kubernetes.io/docs/concepts/security/pod-security-standards/
