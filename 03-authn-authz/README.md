# Configuring Identity Providers

- users interact with the API server
- identity resource keeps record of attempt to authenticate
- service account apps to API server comms wiithout user credentials
- group represent a set of users
- role API definition that users are permitted to perform

Authentication == prove who you are.
Authorization == prove what you can do.

## check permissions
```
curl https://api.ocp4.example.com:6443

{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
  "reason": "Forbidden",
  "details": {},
  "code": 403
}

curl -s https://api.ocp4.example.com:6443/.well-known/oauth-authorization-server

{
  "issuer": "https://oauth-openshift.apps.ocp4.example.com",
  "authorization_endpoint": "https://oauth-openshift.apps.ocp4.example.com/oauth/authorize",
  "token_endpoint": "https://oauth-openshift.apps.ocp4.example.com/oauth/token",
  "scopes_supported": [
    "user:check-access",
    "user:full",
    "user:info",
    "user:list-projects",
    "user:list-scoped-projects"
  ],
  "response_types_supported": [
    "code",
    "token"
  ],
  "grant_types_supported": [
    "authorization_code",
    "implicit"
  ],
  "code_challenge_methods_supported": [
    "plain",
    "S256"
  ]
}

# what is happening
oc login --loglevel 7 -u <username> -p <password> https://api.server.com

# who am I in context
oc whoami -c

# review your config
cat ~/.kube/config

```

## Identity Providers
1. HTPasswd
1. Keystone
1. LDAP
1. GitHub or GitHub Enterprise
1. OpenID Connect

Why is there two {kube,openshift}-apiserver

The OAuth custom resource must be updated with your chosen identity provider. You can define
multiple identity providers, of the same or different kinds, on the same OAuth custom resource.

## Authn as Cluster Admin
1. `X.509 Certifiicate` (meant to stay around ==backdoor; store this in vault or bitwarden)
```
This is generated at install time into ocp4/auth/kubeconfig
$ cat ocp4/auth/kubeconfig

notice the client-certificate-data...this an encoded NOT encrypted string...means you can base64 decode

echo -n 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURaekNDQWsrZ0F3SUJBZ0lJWmE1OUNWTTZEend3RFFZSktvWklodmNOQVFFTEJRQXdOakVTTUJBR0ExVUUKQ3hNSmIzQmxibk5vYVdaME1TQXdIZ1lEVlFRREV4ZGhaRzFwYmkxcmRXSmxZMjl1Wm1sbkxYTnBaMjVsY2pBZQpGdzB5TXpBMU1ETXhPREF4TVRGYUZ3MHpNekEwTXpBeE9EQXhNVEZhTURBeEZ6QVZCZ05WQkFvVERuTjVjM1JsCmJUcHRZWE4wWlhKek1SVXdFd1lEVlFRREV3eHplWE4wWlcwNllXUnRhVzR3Z2dFaU1BMEdDU3FHU0liM0RRRUIKQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUURNcldrWnRZZnNXZ0RTd3J4eVp1MHBMSTgwUkJXbTFsRHdNcTJTSnkvSQpFejVScjdFUjcxTHJ1RkxBbFFtSHd3dDczUCtuNlV5b2JiMXRISGFjdXB3QmlCMFZZMHFKQkFVNTk1aWwrN1B2ClA2c3BCRGFyWHBXbTNDdlF6WlB4T3RGZm11QjlmQzgvd2JERWJtMzFyS1YxL1lEakpzU29yangyckxFKzhKM1gKZjFVQm1WMUdNZVJnWEtPK1VnZTZBWVJNVHlrbXl0YXlma2ZReXNWL1EvZE1zdTMxTWtVeGVzZTk5VkJIelZrdgpYV1JFckViSDFLU0xKaHgyOHhsS3JDclhxdzVwZ0dITit4dG9TS2kwWXNvTzZMWWlWZmZSZnlmc3VqOFIxYjZsCjI2YlFLWUFtMEZpVGg3UnVEV1lleEQ0WG9hV3MvSlpvK29YdXN6Z1p3bmdiQWdNQkFBR2pmekI5TUE0R0ExVWQKRHdFQi93UUVBd0lGb0RBZEJnTlZIU1VFRmpBVUJnZ3JCZ0VGQlFjREFRWUlLd1lCQlFVSEF3SXdEQVlEVlIwVApBUUgvQkFJd0FEQWRCZ05WSFE0RUZnUVVza1Y2bEFDd25rOXZJa0poWFFHRlBRRVVDS3d3SHdZRFZSMGpCQmd3CkZvQVVHZThQek1xdEpUMTFLN2hiTTdwSVpEZElVeFl3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUZqc0l2emUKTklvWm5JWDhRZktYRENyQ3BJZkpXSS8zM3R5NHJqUG1JRWJwQWVJUE9Jb1FKdndjTEROaUdnVjRjTENBV0JlTAozRHRCd0VlTkxJakphUC9naTYxV1RBUWkvaCtiYXhnQnBJakU1bzlEMU1GU05hRHNBQnBITmN5UnFxZ3FGam1mCnNjTjhHV2h3TjFvTlZoVHJQQktvZzhGNEJwTCtCdEM0Y2ZiL2oxMUxJeFRKcGxDQVNDUkxtSGdrcFNQVkxFRlYKbmxxK2VLWTlQUjVJeHI5THV4b2NGZ2x2KytDcWRNVU5MNFREYnhFZUlMNGp2UDlFWWRMRkJGM2hteWl0TkZaNQpKMEhSOUJJT0hxN0JEVFlEY0N0TWpaeGJLQ2tlMDY2NldlU0ZXcG45L2JVOEoybjJEMnV4V1VDU3prTG1yVGI4CitPNzZFTHRJeHFsNkNZUT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=' | base64 -d | openssl x509 -in - -noout -text

how do you use this?
copy this to your local machine     scp user@server:/home/lab/ocp4/auth/kubeconfig .
update your env variable            export KUBECONFIG=/home/student/kubeconfig 
don't forget to unset               unset KUBECONFIG


To use the kubeconfig file to authenticate oc commands, you must copy the file to your
workstation and set the absolute or relative path to the KUBECONFIG environment variable.

$ export KUBECONFIG=/home/user/auth/kubeconfig
```

1. `kubeadmin` Virtual User (meant to be deleted post install)
This info will exist on the machine OCP was provisioned from in the ocp4 folder in the ``.openshift_install.log`
```
After installation completes, OpenShift creates the kubeadmin virtual user. The kubeadmin
secret in the kube-system namespace contains the hashed password for the kubeadmin user.
The kubeadmin user has cluster administrator privileges.

```

### Finding the kube admin secret (DO THIS LAST)
```
# search the cluster for kubeadmin secret
$ oc get secrets -A | grep kubeadmin

# you can view the pass hash, which is what you are supposed to delete even if the password gets out
$ oc extract secret/kubeadmin -n kube-system --to -

# deleting the kubeadmin secret so the user can't authenticate anymore
$ oc delete secret kubeadmin -n kube-system
```

## Configuring HTPasswd Identity Provider
The HTPasswd identity provider validates users against a secret that contains usernames and
passwords that are generated with the htpasswd command from the Apache HTTP Server
project. Only a cluster administrator can change the data inside the HTPasswd secret. Regular
users cannot change their own passwords.

FOLLOW THE DOCS: 
1. https://access.redhat.com/documentation/en-us/openshift_container_platform/4.12/html-single/authentication_and_authorization/index#identity-provider-creating-htpasswd-file-linux_configuring-htpasswd-identity-provider
1. https://access.redhat.com/documentation/en-us/openshift_container_platform/4.12/html/authentication_and_authorization/configuring-identity-providers#configuring-htpasswd-identity-provider

```
# list oauths
oc get oauths
oc get oauths cluster -o yaml

# the cluster operator (co) is constantly watching this
oc get co
oc describe co authentication
oc get oauths.config.openshift.io cluster -o yaml

# install htpasswd
yum what provides */htpasswd
yum install httpd-tools

# create htpasswd file in htpasswd format
htpasswd -c -b -B users.htpasswd myuser1 redhat

# append a user to the file
htpasswd -b -B users.htpasswd myuser2 redhat

# delete a user entry
htpasswd -D users.htpasswd myadmin

# create a secret from the htpasswd in the project the co is watching
oc create secret generic htpass-secret --from-file=htpasswd=<path_to_users.htpasswd> -n openshift-config
oc create secret generic htpass-secret --from-file=htpasswd=users.htpasswd -n openshift-config --dry-run -o yaml

# check the encoded htpasswd
echo -n 'bXl1c2VyMTokMnkkMDUkQnl4SWRnQkRpMVBQYUFiOWhlUE9BdTJCb2FTVTZzN21tUWhGQnVwMDMyRDZaTmYuQlJOVzYKbXl1c2VyMjokMnkkMDUkZmZtajJDMmVxeHRPaWJacUJuL0t2LjU2eXZiUDZWd1dhdkVSVDhBc1U4MmhYa0pBcy5YL2UK' | base64 -d

# send it
oc create secret generic htpass-secret --from-file=htpasswd=users.htpasswd -n openshift-config
```

### updating a password
```
# update a users password
# extract the secret
oc extract secret/htpass-secret -n openshift-config --to htpasswd.temp --confirm

# add, delete and readd, or update a user
htpasswd -D htpasswd.temp/htpasswd myuser1
htpasswd -b -B htpasswd.temp/htpasswd myuser1 redhat

# update the htpass payload
oc set data secret/htpass-secret --from-file=htpasswd=htpasswd.temp/htpasswd -n openshift-config

```

### create the OAuth custom resource
https://access.redhat.com/documentation/en-us/openshift_container_platform/4.12/html/authentication_and_authorization/configuring-identity-providers#identity-provider-htpasswd-CR_configuring-htpasswd-identity-provider

oc edit means you edit a live resources, so to be declarative you should create a resource file

```
# export the oauths file
oc get oauths.config.openshift.io cluster -o yaml > oauths.yaml

# inject into the spec identity provider
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: my_htpasswd_provider 
    mappingMethod: claim 
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret 


# check the diff on the server
cat oauths.yaml | oc diff -f -

# check the apply
oc apply -f oauths.yaml --dry-run=server --validate

# apply it
oc apply -f oauths.yaml

# check the oauth pods
oc get pods -A | grep oauth
oc get pods -n openshift-authentication -w

# check the events
oc describe oc authentication
```

# Assigning Administrative Privileges

The cluster-wide cluster-admin role grants cluster administration privileges to users and
groups. With this role, the user can perform any action on any resources within the cluster. The
following example assigns the cluster-admin role to the student user.

```
oc adm policy add-cluster-role-to-user cluster-admin student

# how do you create the binding for users to create project requests
# hint: self provisioner

# what roles have self something
oc get clusterroles | grep self

# what role group has oauth
oc get clusterrolebindings -o wide | grep oauth

# 
oc adm policy add-cluster-role-to-group self-provisioner system:authenticated:oauth --rolebinding-name='self-provisioners'

# if auto update is set to TRUE, you could just restart the api server

oc get clusterroles | grep self
```

Resources:
1. a handy tool for context switching https://github.com/jonmosco/kube-ps1
1. another handy tool to context switching, https://github.com/ahmetb/kubectx
1. how to assign users X509 certs instead of passwords `oc explain csr` with their own custom kubeconfigs