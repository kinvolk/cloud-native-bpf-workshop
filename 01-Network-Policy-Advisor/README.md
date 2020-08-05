## 01 - Network Policy Advisor

For this example, we're using an example microservices application based on
[Google's
microservices-demo](https://github.com/GoogleCloudPlatform/microservices-demo)
repository.

This is a bunch of microservices that can run in a Kubernetes cluster but
come with no network-policy.  To figure out the necessary policy, we'll use
the Network Policy Advisor.

You can check out how many different resources get deployed by the manifest
by doing:

```
cat kubernetes-manifests.yaml | grep kind
```

During this exercise, we'll need to run commands in parallel. If you're
connected to the machine where you're running the exercises remotely, we
recommend that you use tmux or screen for multiplexing. If you're running
them locally on your machine, you can open new terminals however you want.

### Start the Network Policy Advisor

To get information about the type of network connections that are
established by our applications, we need to start the advisor's monitor
component.  We can do that like this:

```
kubectl gadget network-policy monitor --namespaces demo --output ./networktrace.log
```

This will start to monitor on the `demo` namespace and store all the
captured traffic in the `networktrace.log` file.

This is a long running job.  To run the next commands, you should open a
new tab or terminal.

### Start the microservices demo

With the advisor monitoring the connections, we can now deploy the demo
manifest.

```
kubectl create ns demo
kubectl apply -n demo -f kubernetes-manifests.yaml
kubectl get pod -n demo
```

It takes a while for all the pods to be fully ready. We can check out the
progress by running the `watch` command.

```
watch kubectl get pod -n demo
```

Once the pods start sending traffic between them, the network policy
advisor will capture that and store that information in the log file.  We
can look at what it's storing by checking out the file contents.

```
tail -f networktrace.log
```

### Generate the report

Once all pods are running and there's been enough time for traffic to be
generated between them, we can stop the monitor process that we started
earlier and use the captured log to generate the basic network policies.

```
kubectl gadget network-policy report --input ./networktrace.log > network-policy.yaml
```

This will create a yaml file with the suggested network policies, which can
be used as a base for creating the actual network policies.

### Delete all the pods

Once you're done with this exercise, you can delete all the generated pods,
by running the following command.

```
kubectl delete -n demo -f kubernetes-manifests.yaml
```

