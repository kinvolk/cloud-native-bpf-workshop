## 02 - Traceloop

Traceloop is a tool that allows us to see the last syscalls executed by a
process, without adding the slowness that strace adds.

### Look at the already stored information

The traceloop gadget is constantly monitoring pods, so whatever our
cluster has been running since we've added the gadget pod will be already
stored there. You can see all the currently available traces by listing
them for all namespaces, using the `list` subcommand.

```
kubectl gadget traceloop list -A
```

If you completed the network advisor policy exercise, this list will
include all the pods that were started for that. For a freshly started
cluster, it could be that there's only a few pods that have information.

Notice that there's an index column in the list that you get. You'll need
that index when retrieving the syscalls for a running pod.

To look at the syscalls of a pod that's currently running, we'll use the
`pod` subcommand, we need to pass it the namespace, the pod name, and the
index. For example, to look at the first trace for pod
`coredns-66bff467f8-ntxqt` in the `kube-system` namespace, we need to do:

```
kubectl gadget traceloop pod kube-system coredns-66bff467f8-ntxqt 0
```

We can see the last calls that were executed in the pod.

## Inspect a failing pod

The most interesting part of the traceloop gadget is that it allows us to
debug a pod that crashed, even after it's gone. To see that in action,
let's start a pod that will crash.


## Example with nginx

```
kubectl apply -f nginx.yaml
minikube service nginx-deployment
```

- Go to http://192.168.39.189:32123/hello
- Notice the 404 error

```
kubectl gadget opensnoop --selector app=nginx
```

```
kubectl edit deploy nginx-deployment
```
