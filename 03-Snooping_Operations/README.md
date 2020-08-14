## 03 - Snooping Operations

opensnoop and execsnoop are tools that allows us to see specific operations
(files being opened and programs being executed) in real-time. This can be used
by developers to debug their deployments.

We will first see how to use execsnoop to observe the execution of a shell
script. Then, we will use opensnoop to investigate a bug in the configuration
of a nginx deployment.

### Example 1: observing a shell script

In a first terminal, start the execsnoop gadget, selecting all pods with the
run=cooking label on the default namespace:

```
kubectl gadget execsnoop --namespace default --selector run=cooking
```

At this point, there are no such pods, so nothing is displayed.

In a second terminal, start the following shell script in the pod:
```
kubectl run --restart=Never -ti --image=fedora cooking -- sh -c 'curl -L https://www.chef.io/chef/install.sh | bash'
```

Each program started by the script should be visible in the first terminal.


### Example 2: debugging a nginx deployment

Let's deploy our nginx application. The yaml file contains the deployment with
nginx itself, the service creating a load balancer to make nginx accessible
outside of the Kubernetes cluster, and a config map with the content of the
website.

```
kubectl apply -f nginx.yaml
minikube service nginx-deployment
```

Since we use minikube, we use the "minikube service" command to make the load
balancer reachable from our computer. Once we know the URL, we can reach it
with curl or with your browser.

```
URL=http://xxx.xxx.xxx.xxx:yyyyy
curl $URL/hello.txt
```

When fetching the file hello.txt, we get a 404 error. That's a bug: the config
map contains the file hello.txt but nginx can't serve it.

To find out the cause of the bug, we can use the opensnoop gadget, selecting
the nginx deployment by label:

```
kubectl gadget opensnoop --selector app=nginx
```

This command will show in real-time the files opened by nginx.

Once you've identified the cause of the bug, you can fix the deployment:

```
kubectl edit deploy nginx-deployment
```

And reach the webpage again, with success this time:

```
curl $URL/hello.txt
```
