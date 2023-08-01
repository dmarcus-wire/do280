# Cluster Updates

OpenShift clusters can perform Over-the-Air updates (OTA).
Upgrades supported
- Starting with OpenShift 4.10, the OTA system requires a persistent connection to
the internet.

## OTA
OTA follows a client-server approach. Red Hat hosts the cluster images and the update
infrastructure. OTA generates all possible update paths for your cluster. OTA also gathers
information about the cluster and your entitlement to determine the available upgrade paths. The
web console sends a notification when a new update is available.

Red Hat hosts both the cluster images and a "watcher", which automatically detects new images that are pushed to Quay. 

The Cluster Version Operator (CVO) receives its update status from that watcher. 

The CVO starts by updating the cluster components via their operators, and then updates any extra components that the
Operator Lifecycle Manager (OLM) manages

## Channels
- candidate channel delivers updates for testing feature acceptance in the next version of
OpenShift Container Platform
- fast channel delivers updates as soon as Red Hat declares the given version as a general
availability release
- Red Hat support and site reliability engineering (SRE) teams monitor operational clusters with the
updates from the fast channel.
    - If Red Hat observes operational issues from a fast channel update, then that update is skipped in
the stable channel.

## EUS
Starting with OpenShift Container Platform 4.8, Red Hat denotes all even-numbered minor
releases (for example, 4.8, 4.10, and 4.12) as Extended Update Support (EUS) releases.

EUS releases have no difference between stable-4.x and eus-4.x channels (where x denotes
the even-numbered minor release) until OpenShift Container Platform moves to the EUS phase.
You can switch to the EUS channel as soon as it becomes available.

Downgrades not supported (only Reinstall) - like sharks we only go forward

Project Cincinnati (https://github.com/openshift/cincinnati) is what RH runs for updates

```
# download pull secret from console.redhat.com/openshift

# change the pull secret
cat pull-secret.txt | jq > pull-secret.json

# set the pull secret on the cluster
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=pull-secret.json

oc extract secret/pull-secret -n openshift-config --confirm

# upgrade the cluster
oc adm upgrade --to=VERSION

# what versions are available
oc adm upgrade

oc debug node/master01 -- cat /host/var/lib/kubelet/config.json

oc get clusterversion version -o yaml | less

oc adm upgrade channel stable-4.12
oc adm upgrade channel fast-4.12

# CVO manages the non-cluster operators
# CVO hands of cluster operators to OLM

## DO CLUSTER HEALTH CHECKS

# send it
oc adm upgrade --to=4.12.26

# monitor the upgrade
watch oc get clusterversion,cp

# get check clusterversion
oc get clusterversion
oc get nodes
oc get pods -A | grep -v "Running\|Completed"
```

### Cluster health prior to upgrade
https://docs.openshift.com/container-platform/4.12/updating/updating-cluster-cli.html#prerequisites
```
# check cluster health
oc get nodes

# look at the spec and check the `taints` (or stressed nodes)
oc get node master01 -o yaml
oc describe node master01 | less

# do you have enough capacity to handle workload migration
oc adm top nodes

# checl the VERSION and AVAILABLE on the cluster operators
oc get co

# look at all the pods in all namespaces to make sure they are all healthy running completed
oc get pods -A | grep -v "Running\|Completed"

# check prometheus cluster alerts from the console

# take an etcd backup
# take backup of apps
# pause machinehealthchecks to minimize alerts 
# https://docs.openshift.com/container-platform/4.12/updating/updating-cluster-cli.html#machine-health-checks-pausing_updating-cluster-cli
oc get machinehealthchecks.machine.openshift.io -A
oc get machinehealthchecks.machine.openshift.io -n openshift-machine-api

# be sure not applications are relying on API endpoints that are going to be deprecated
oc version

# K8s promises that once an API endpoint supported version is released (V1 NOT alpha/beta) - you have 3x K8s releases before deprecated
# alpha > beta > v1
oc api-resources | grep -v alpha | grep -v beta
oc api-resources | grep -v alpha | grep -v alpha

# audit the APIs
# report the name of the endpoint, the number of requests made to the endpoint in the current hour
# watch the REMOVEDINRELEASE, you cannot upgrade if this is populated
oc get apirequestcounts.apiserver.openshift.io | less
# locate the users
oc get apirequestcounts.apiserver.openshift.io prioritylevelconfigurations.v1beta1.flowcontrol.apiserver.k8s.io
# describe the resource to understand the users
oc describe apirequestcounts.apiserver.openshift.io prioritylevelconfigurations.v1beta1.flowcontrol.apiserver.k8s.io

# admin ack
# Providing the administrator acknowledgement https://access.redhat.com/articles/6955381
```