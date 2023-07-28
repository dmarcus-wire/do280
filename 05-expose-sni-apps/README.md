# Load Balancer Services

## Exposing Non-HTTP Services
in some scenarios, ingresses and routes are not sufficient to expose the service that a pod provides.

many protocols do not have equivalent features. Ingress and route resources can expose only HTTP services. To expose non-HTTP services, you must use a different resource. 

https://docs.openshift.com/container-platform/4.13/networking/configuring_ingress_cluster_traffic/overview-traffic.html

The methods are recommended, in order or preference:

1. If you have HTTP/HTTPS, use an Ingress Controller (aka route).
    1. Allows access to HTTP/HTTPS traffic and TLS-encrypted protocols other than HTTPS (for example, TLS with the SNI header).
1. If you have a TLS-encrypted protocol other than HTTPS. For example, for `TLS with the SNI header`, use an Ingress Controller.
1. Otherwise, use a 
    1. `Load Balancer` Allows traffic to non-standard ports through an IP address assigned from a pool. Most cloud platforms offer a method to start a service with a load-balancer IP address.
        1. `MetalLB` Allows traffic to a specific IP address or address from a pool on the machine network. For bare-metal installations or platforms that are like bare metal, MetalLB provides a way to start a service with a load-balancer IP address.
    1. an `External IP` Allows traffic to non-standard ports through an IP address assigned from a pool. Allows traffic to non-standard ports through a specific IP address.
    1. `NodePort` Expose a service on all nodes in the cluster (least secure/scalable).

https://metallb.universe.tf/installation/clouds/#metallb-on-openshift-ocp 

`oc create service -h`
  clusterip      Create a ClusterIP service
  externalname   Create an ExternalName service (bridge legacy apps; dns trickery; cname pointer)
  loadbalancer   Create a LoadBalancer service (must have your own lb)
  nodeport       Create a NodePort service (ingress)

```
# metallb was provided

# expose a port with a non-default external load balancer
oc expose deployment/virtual-rtsp-1 --type LoadBalancer --target-port 8554
oc expose deployment/virtual-rtsp-2 --type LoadBalancer --target-port 8554
oc expose deployment/virtual-rtsp-3 --type LoadBalancer --target-port 8554

# OR you can create a load balancer service
oc create service loadbalancer -h
```

## Multus

https://docs.openshift.com/container-platform/4.13/networking/multiple_networks/understanding-multiple-networks.html#additional-networks-provided

Expose applications to external access by using a secondary network. (second interface to the pod).
You keep the primary network (etho0) for things like metrics.
The Multus CNI (container network interface) plug-in helps to attach pods to custom networks.
These custom networks can be either existing networks outside the cluster, or custom networks
that are internal to the cluster.

### Create the definition NAD

```
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: custom 
spec:
  config: |-
    {
      "cniVersion": "0.3.1",
      "name": "custom",
      "type": "host-device",
      "device": "ens4",
      "ipam": {
        "type": "static",
        "addresses": [ 
         {"address": "192.168.51.10/24"}
        ]
      }
    }
```
### update the deployment pod spec annotation

```
    template:
      metadata:
        annotations: 
          k8s.v1.cni.cncf.io/networks: custom
```

eth0 ALWAYS standard pod interface (10.8)
multus will apply net1, net2, etc. (192.)

```
oc debug node/master01
chroot /host /bin/bash
ip addr show ens4

crictl ps | grep database
```

Why isn't node port preferred and Load Balancers are?
```
# create a project
oc new-project non-http-lb

# create a deployment
oc create deployment myapp --image=quay.io/ajblum/hello-openshift

# create a loadbalancer service
oc create service loadbalancer myapp-lb --tcp 8080:8080

# you can also provide multiple ports mapped to the container
# you can also do this with nodeport, but you have to manage access separately
oc create service loadbalancer myapp-lb --tcp 8080:8080,8888:8888

# update the label service selector to myapp manually
oc edit myapp-lb

# same endpoint mapped to multiple ports from the same loadbalancer
oc get endpoints 

# create a nodeport service (remember the same pod can be exposed multiple ways)
oc create service nodeport myapp-nodeport --tcp 8080:8080

# update the label service selector to myapp manually
oc edit myapp-nodeport

# view it all
# notice the nodeport the app is only exposed there...what is the IP of the node? is the node routable? is the node disconnected so people don't have shell access to your node? You have to curl the node IP with the node port mapping
# notice the external ip is provided by the lb. It's load balancing the node ports below, so you don't have to be so precise or expose the explicit node port. you are putting the owness on the lb
oc get services -o wide

# you can scale just fine to have multiple endpoints
oc scale deployment/myapp --replicas 3

# remember load balancers require a lb, and node ports are just available as-is
# lb services are not cheap and node-ports are
```

https://docs.openshift.com/container-platform/4.13/networking/multiple_networks/configuring-additional-network.html#nw-multus-host-device-object_configuring-additional-network