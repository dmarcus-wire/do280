# Deploy and update applications from resource manifests that are parameterized for different target environments.
- Deploy and update applications from resource manifests that are:
    - stored as YAML files.
    - augmented by Kustomize.

# Imparative VS Delcarative
-  Imperative commands configure each resource, one at time.
    - Impaired reproducibility
    - Lacking version control
    - Lacking support for GitOps
- Declarative commands are instead the preferred way to manage resources, by using resource manifests. 
    - A *resource manifest* is a file, in JSON or YAML format, with resource definition and configuration information encapsulate all the attributes of an application in a file or a set of related files. 
    - K8s uses declarative commands to read the resource manifests and to apply changes to the cluster *to meet the state that the resource manifest defines*.
    - Resource manifests: 
        - ensure that applications can be precisely reproduced
        - are in YAML or JSON format, and thus can be version-controlled
        - version control of resource manifests enables tracing of configuration changes. 
            - adverse changes can be rolled back to an earlier version to support recoverability.
        - reproducibility from resource manifests supports the automation of the GitOps practices of CI/ CD

# Testing above

## Imparative approaches require sequential order of operations
An imperative workflow is useful for developing and testing. The process is
analogous to using a debugger to step through code execution one line at a time. Using imperative
commands usually provides clearer error messages, because an error occurs after adding a
specific component.

However, long command lines and a fragmented application deployment are not ideal for
deploying an application in production. With imperative commands, changes are a sequence of
commands that must be maintained to reflect the intended state of the resources. The sequence
of commands must be tracked and kept up to date.

Create a new managed pod with an app, because an unmanaged app will just die if it has a problem
```
oc create deployment myapp --image quay.io/ajblum/hello-openshift:latest
```

Warning message from above deployment OCP api autoinjects the correct scc
```
Warning: would violate PodSecurity "restricted:v1.24": allowPrivilegeEscalation != false (container "hello-openshift" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "hello-openshift" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "hello-openshift" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "hello-openshift" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
```

add a new alias in ~/.bashrc to suppress errors messages
```
alias oc='/usr/local/bin/oc $@ 2> >(grep -v "would violate PodSecurity")'
source .bashrc
```

expose the deploy to create a service on port 8080
```
oc expose deployment/myapp --port 8080
```

expose the service to create the route
```
oc expose service/myapp
```

check the route
```
oc get route
curl myapp-workflow-test.apps.ocp4.example.com
```

This approach is problematic, because at enterprise scale it doesn't lend itself well to reproducibility, version control and overall CI/CD.

## Declarative approach

Instead of tracking a sequence of commands, a manifest file captures the intended state of the
sequence. In contrast to using imperative commands, declarative commands use a manifest file,
or a set of manifest files, to combine all the details for creating those components into YAML
files that can be applied in a single command. Future changes to the manifest files require only
reapplying the manifests. Instead of tracking a sequence of complex commands, version control
systems can track changes to the manifest file.

Create a directory of our resource manifest files
```
mkdir myapp
cd myapp/

# Dry run, don't send to server, just build the spec (manifest) in structured YAML you would see 
oc create deployment myapp --image quay.io/ajblum/hello-openshift:latest --dry-run=client -o yaml > myapp-deployment.yaml

# dry run and validate the manifates
# intentionally add 2x whitespace at the strategy field
oc apply -f . --dry-run=server --validate=true
# Error from server (BadRequest): error when creating "myapp-deployment.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.selector.strategy"

# create the manifest for the services
oc expose deployment/myapp --port 8080 --dry-run=client -o yaml > myapp-service.yaml
oc apply -f myapp-service.yaml

# create the manifest for the route
oc expose service/myapp --dry-run=client -o yaml > myapp-route.yaml
oc apply -f myapp-route.yaml
```

Diff files local versus on the server
```
# check the diff of a file local versus the server
oc diff -f .
```

## first lab to roll through versions in Git for expoplanets
you can run `grep kind database.yaml` to summarize what is in the manifest 
```
$ grep kind database.yaml 
kind: ConfigMap
kind: Secret
kind: Deployment
kind: Service

$ grep kind exoplanets.yaml
kind: ConfigMap
kind: Secret
kind: Deployment
kind: Service
    service.alpha.openshift.io/dependencies: '[{"kind": "Service", "name": "database"}]'
kind: Route
    kind: Service

# dry run apply the manifests
$ oc apply -f . --dry-run=server --validate=true

# apply the manifests
$ oc apply -f .

# monitor the deployment
$ oc get pods -w 
$ watch oc get deployments,pods

# get the images for the containers in a deployment
$ oc get deployment -o wide

# check the spec before applying
$ oc apply -f . --dry-run=server --validate=true
```

Updating `secrets`, `environment variables`, `services`, `service accounts` and `configmaps` do not update the rollout out of the box. There is no live way to change the process. You have to re-rollout manually, there is no trigger to set.
- In `Deployments`, only a a type `config` trigger (label, image, etc...the config of the deployment)


```
# manually start rollout to grab new secrets
$ oc rollout restart deployment/{database,exoplanets}
```

Recommendation to use oc apply always.
oc create does a two way merge (local and server only)
oc apply does a three way merge (local, server, and annotations)

# Kustomize
Kustomize is a configuration management tool to make declarative changes to application configurations and components and preserve the original base YAML files. 

Why?
- When using Kubernetes, multiple teams use multiple environments, such as development, staging, testing, and production, to deploy applications. These environments use applications with minor configuration changes.
- Many organizations deploy a single application to multiple data centers for multiple teams and regions. Depending on the load, the organization needs a different number of replicas for every region. The organization might need various configurations that are specific to a data center or team.

What?
All these use cases require a single set of manifests with multiple customizations at multiple levels. Kustomize can support such use cases.

Kustomize works on directories that contain a kustomization.yaml file at the root. 
Kustomize has a concept of base and overlays.

reference: https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/ 

## Base
'common starting material'
A base directory contains a kustomization.yaml file. The kustomization.yaml file has a list resource field to include all resource files.

```
base
├── configmap.yaml
├── deployment.yaml
├── secret.yaml
├── service.yaml
├── route.yaml
└── kustomization.yaml
```

## Overlay 
'common starting material or base resource files, but apply them differently'
Kustomize overlays declarative YAML artifacts, or patches, that override the general settings without modifying the original files. The overlay directory contains a kustomization.yaml file. The kustomization.yaml file can refer to one or more directories as bases. Multiple overlays can use a common base kustomization directory.

```
base
├── configmap.yaml
├── deployment.yaml
├── secret.yaml
├── service.yaml
├── route.yaml
└── kustomization.yaml
overlay
└── development
 └── kustomization.yaml
└── testing
    └── kustomization.yaml
└── production
 ├── kustomization.yaml
 └── patch.yaml
```

## Testing the concepts

```
# create dirs
$ mkdir -p hello-openshift/base hello-openshift/overlays

# change to the base folder
cd hello-openshift/base

# create manifest files for the deplyoment and service
$ oc create deployment hello --image=quay.io/ajblum/hello-openshift:latest --dry-run=client -o yaml > base/hello-deployment.yaml
$ oc create service clusterip hello --tcp 8080:8080 --dry-run=client -o yaml > base/hello-service.yaml

# create a kustomization file in base
kind: kustomization
resources:
  - hello-deployment.yaml
  - hello-service.yaml

# apply the kustomize
$ oc apply -k base/

# set env variables imparatively to understand what the spec should look like for setting a custom message in the spec: containers:
$ oc set env deployment.apps/hello RESPONSE="a custom message" --dry-run=client -o yaml 

```

## Patching files

Patches can be used to apply different customizations to Resources. Kustomize supports different patching mechanisms through patchesStrategicMerge and patchesJson6902. patchesStrategicMerge is a list of file paths.

reference: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#customizing

You don't have to define the whole spec, just what you want to change.

```
# create an overlay
$ mkdir overlays/dev

# redirect the set env to a new file
$ oc set env deployment.apps/hello RESPONSE="a custom message" --dry-run=client -o yaml > overlays/dev/hello-deployment-patch.yaml

# manually cleanup all the unnecessary data
  1 apiVersion: apps/v1
  2 kind: Deployment
  3 metadata:
  4   name: hello
  5 spec:
  6   template:
  7     spec:
  8       containers:
  9       - env:
 10         - name: RESPONSE
 11           value: a custom message
 12         name: hello-openshift

# look at the file directory
.
├── base
│   ├── hello-deployment.yaml
│   ├── hello-route.yaml
│   ├── hello-service.yaml
│   └── kustomization.yaml
└── overlays
    └── dev
        └── hello-deployment-patch.yaml

# create another kustomization.yaml file for the overlay
# tell the file to use the base files
# tell the file to transform them with the patches
  1 kind: Kustomization
  2 resources:
  3   - ../../base
  4 
  5 patches:
  6   - path: hello-deployment-patch.yaml
  7   target:
  8     kind: Deployment
  9     name: hello

# check the file structure
.
├── base
│   ├── hello-deployment.yaml
│   ├── hello-route.yaml
│   ├── hello-service.yaml
│   └── kustomization.yaml
└── overlays
    └── dev
        ├── hello-deployment-patch.yaml
        └── kustomization.yaml

# create a prod directory and change the transformer tag
kind: Kustomization
resources:
  - ../../base

images:
  - name: quay.io/ajblum/hello-openshift
    newTag: prod

# check the structure
.
├── base
│   ├── hello-deployment.yaml
│   ├── hello-route.yaml
│   ├── hello-service.yaml
│   └── kustomization.yaml
└── overlays
    ├── dev
    │   ├── hello-deployment-patch.yaml
    │   └── kustomization.yaml
    └── prd
        └── kustomization.yaml

# apply the overlay
$ oc apply -k overlays/prd/


```

## Kustomize Generators
Configuration maps hold non-confidential data by using a key-value pair. Secrets are similar
to configuration maps, but secrets hold confidential information such as usernames and
passwords. Kustomize has configMapGenerator and secretGenerator fields that generate
configuration map and secret resources.

## Lab

```
# check the kustomize manifest
$ oc diff -f base/kustomization.yaml 

# what is different between local changes and on the server
$ oc kustomize base | oc diff -f -
OR
$ oc diff -k base/


```
 