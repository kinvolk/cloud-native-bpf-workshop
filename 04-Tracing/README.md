## 04 - Tracing with kubectl-trace

For this section, we are going to use
[kubectl-trace](https://github.com/iovisor/kubectl-trace) which is a
different plugin that also uses BPF to give us more information about
what's going on in our system. It lets us run
[bpftrace](https://github.com/iovisor/bpftrace) expression inside our
Kubernetes clusters.


### Getting kubectl-trace

If you didn't install `kubectl-trace` before, you need to do it to follow
these exercises. For convenience, you can run the `get_kubectl_trace`
script in this directory, which will download and install `kubectl-trace`,
either by using krew, if you have it enabled, or by downloading it and
copying it to the same path as `kubectl`.  If there are any errors, check
the [kubectl-trace
documentation](https://github.com/iovisor/kubectl-trace#installing)

### Providing kernel headers for minikube

To successfully run traces inside minikube, the kernel headers need to be
readable. This is currently not possible in the latest `kubectl-trace`
release as it doesn't ship with the necessary decompression tools. So,
we've provided a docker image that includes this tools and lets us run
`kubectl-trace` inside minikube.  To use that image, we need to pass a
couple of flags to the `run` command. For convenience, we suggest you create
the following alias:

```
alias kubectl-trace-run="kubectl trace run \
    --imagename 'docker.io/albanc/kubectl-trace-bpftrace:e896345e3d8f80aa968422c6199ac5180d688f65' \
    --init-imagename 'docker.io/albanc/kubectl-trace-init:e896345e3d8f80aa968422c6199ac5180d688f65'"
```

**Note**: If you're running minikube inside a VM using the `none` driver,
you need to provide the OS kernel headers yourself.

### Basic kubectl-trace usage

To use `kubectl-trace` we need to create `bpftrace` expressions, which can
be passed directly through the command line or in a file. These expressions
are really powerful and flexible. You can use the [One Liner
Tutorial](https://github.com/iovisor/bpftrace/blob/master/docs/tutorial_one_liners.md)
and the [Reference
Guide](https://github.com/iovisor/bpftrace/blob/master/docs/reference_guide.md)
to get more information on how to construct them.

To apply these expressions, we need to tell `kubectl-trace` the node or the
pod to run them in. Let's start with a simple expression to check the
syscalls executed in a node.

First, list the nodes with `kubectl get nodes` and then pick the node name
where you want to run your trace. In the case of a locally running minikube
with just one node, the node is called `minikube`.  In that case, to start
a trace that counts the syscalls executed in the node, we can do:

```
kubectl-trace-run minikube -e 'tracepoint:syscalls:sys_enter_* { @[probe] = count(); }'
trace 70a89758-dedc-11ea-a384-002590bde278 created
```

When we tell kubectl-trace to run this trace, it tells us that the trace
was created and we get back our prompt. We can let this trace run for as
long as we want. We could start a bunch of pods, or generate some load in
our cluster, whatever it is that we want to investigate.

We can get a list of the traces that `kubectl-trace` knows about using
`kubectl trace get`.

```
$ kubectl trace get
NAMESPACE       NODE    NAME                                                    STATUS          AGE
default         minikubekubectl-trace-cc4a12d4-dede-11ea-8779-002590bde278      Running         1m47s
```

When we are ready for the trace to stop, we can attach to it with
`kubectl trace attach <trace-name>` and then we can stop it with Ctrl-C.
This will cause the summary at the end of the trace to get printed. A
second Ctrl-C will finish the attachment.

If we don't want to disconnect from the trace, we can pass the `-a` flag to
stay attached when the trace is created

Other similar expressions that can be tried like this:
```
# Counts the amount of syscalls per command name
kubectl-trace-run minikube -e 'tracepoint:syscalls:sys_enter_* { @[comm] = count(); }'

# Counts the amount of calls to sys_enter_write per command name:
kubectl-trace-run minikube -e 'tracepoint:syscalls:sys_enter_write { @[comm] = count(); }'

# Show the contents of the buffer being written for one specific command (coredns):
kubectl-trace-run minikube -e '
  tracepoint:syscalls:sys_enter_write
  /comm == "coredns"/
  { printf("%s\n", str(args->buf)); }'
```

### More advanced usage

The expressions that we can construct with `bpftrace` can get very complex.
On top of the inline expressions we can also pass a file with more commands
and information, including comments and formatting whitespace.

The `bashreadline.bt` in this directory, is an example of such file. It
includes some boilerplate, followed by a few commands. Having it in this
format makes it more readable.

This file uses the `uretprobe` probe, which allows us to do dynamic tracing
on user level programs. It also uses a handy trick provided by
`kubectl-trace` to let us access said userspace, the `$container_pid`
variable:

```
uretprobe:/proc/$container_pid/root/bin/bash:readline
```

The way `uretprobe` works requires access to the inode of the command that
we want to trace.  To get the right inode, when kubectl-trace attaches a
probe to a container, it replaces the `$container_pid` variable with the
process id of the main process in that container. That way, we can find the
right inode for the probe.

To see this script in action, we're going to need two terminals. In the
first terminal, we'll start a test pod with the ubuntu image, and we'll
execute bash:
```
kubectl run -ti --rm --restart=Never --image ubuntu testpod -- /bin/bash
```

In the second terminal, we'll start a trace for this pod, and we'll pass
the `bashreadline.bt` file for the commands:
```
kubectl-trace-run -f bashreadline.bt pod/testpod --attach
```

Now, back in the first terminal, we can type any commands in our bash
command, and they will get printed by our tracer.

### How kubectl-trace translates calls into bpftrace commands

We can also have a quick look under the hood to check how the translation
of the process id was done. To do that, we can ssh into the cluster with
`minikube ssh` and take a look at the program that's running.

```
$ ./minikube ssh
                         _             _
            _         _ ( )           ( )
  ___ ___  (_)  ___  (_)| |/')  _   _ | |_      __
/' _ ` _ `\| |/' _ `\| || , <  ( ) ( )| '_`\  /'__`\
| ( ) ( ) || || ( ) || || |\`\ | (_) || |_) )(  ___/
(_) (_) (_)(_)(_) (_)(_)(_) (_)`\___/'(_,__/'`\____)

$ ps fax | grep bpftrace
  39143 pts/0    S+     0:00              \_ grep bpftrace
  35288 pts/0    S+     0:01                  \_ /bin/bpftrace /tmp/program-container.bt

$ sudo grep uretprobe /proc/35288/root/tmp/program-container.bt
 * This works by tracing the readline() function using a uretprobe (uprobes).
uretprobe:/proc/35124/root/bin/bash:readline

$ ps ax | grep /bin/bash
  35124 pts/0    Ss+    0:00 /bin/bash
  39700 pts/0    S+     0:00 grep /bin/bash
```

We can see that when we ran our `kubectl-trace`, a `bpftrace` program was
started. And when we inspect the program that's running on the node, it has
the specific PID of the bash command that we ran. The `$container_id`
variable was replaced.

### Tracing a function inside a webserver program

For the last example, we'll start a container with a webserving application
called [caturday](https://github.com/fntlnz/caturday).

First, start the caturday application by running:

```
kubectl apply -f caturday.yml
```

Once this is running, we can connect to the service, either by using
`minikube service caturday -n caturday`, or
`kubectl port-forward service/caturday -n caturday 8080:80`

And then we can load the webpage and check that it's working. Try reloading
it a few times to get a few different cat images.

Once the webserver is running, we can now run a trace on the pod. To do
that, we'll first get the pod name with: `kubectl get pod -n caturday`, and
then store it to `PODNAME` variable.

Finally, we can run:
```
kubectl-trace-run pod/$PODNAME -a -n caturday \
    -e 'uretprobe:/proc/$container_pid/exe:"main.counterValue" { printf("%d\n", retval) }'
```

This will trace the `main.counterValue` function inside the webserver. This
function is called each time our website gets a request. So, if we do a few
more requests to the website while this trace is running, we'll see that
the function keeps incrementing the counter for each request.

