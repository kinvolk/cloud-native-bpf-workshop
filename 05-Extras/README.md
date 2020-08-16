## 05 - Extras

This section will demo the usage of `bpftool` and some `bcc` tools directly on the
worker node in order to explain how things work behind the scene.

This extra will be shown if time allows. This can also be done independently by
attendees after the tutorial.

### Execsnoop with filter on a label

Let's start by starting the execsnoop gadget in one terminal:
```
kubectl gadget execsnoop --selector role=extras
```

We can figure out what's running on the worker node:
```
./minikube ssh
sudo -s
ps aux | grep [e]xecsnoop
```

We notice that the bcc tool `execsnoop` is executed with this parameter:
```
/usr/share/bcc/tools/execsnoop --mntnsmap /sys/fs/bpf/gadget/mntnsset-20200817XXXXXX-XXXXXXXXXXXX
```

Inspektor Gadget starts execsnoop with a label filter: it will only get "exec"
events from processes inside the containers mentioned in this BPF map.

### Inspect BPF maps with bpftool

Let's inspect the contents of this BPF map with `bpftool`. `bpftool` is not
installed by default on Minikube, so we will run it via a container:

```
docker run -ti --rm --privileged -v /sys/fs/bpf:/sys/fs/bpf --pid=host kinvolk/bpftool \
  bpftool map dump pinned /sys/fs/bpf/gadget/mntnsset-20200817XXXXXX-XXXXXXXXXXXX
```

As you can see, the map is currently empty: execsnoop is monitoring exactly
zero containers because none matches the label `role=extras`:
```
kubectl get pod --selector role=extras -A
```

### Adding and removing pods dynamically

So let's start a couple of pods with the `role=extras` label in other terminals:
```
kubectl run --rm -ti --restart=Never --image ubuntu --labels="app=shell,role=extras" shell -- bash
kubectl run --rm -ti --restart=Never --image ubuntu --labels="app=shell2,role=extras" shell2 -- bash
```

And a third pod without this `role=extras` label:
```
kubectl run --rm -ti --restart=Never --image ubuntu --labels="app=shell3,role=none" shell3 -- bash
```

Running the same `bpftool` command as before should now see that the BPF
map contains the two containers that have the requested label.

Inspektor Gadget identifies the container with the mount namespace id. You
can get the mount namespace id of one of the containers by looking at
`/proc/self/ns/mnt` inside the container. The following commands must be executed
in the container (reusing the terminal where you run `kubectl run` or using
`kubectl exec`):
```
readlink /proc/self/ns/mnt
printf '%016x' $(stat -Lc '%i' /proc/self/ns/mnt) | sed 's/.\{2\}/&\n/g' | tac | xargs echo
```

More details in bcc's documentation about [Special
filtering](https://github.com/iovisor/bcc/blob/master/docs/special_filtering.md)

### Filtering with labels with bcc directly

Now that you know how it works, you can run execsnoop from bcc directly and
filter on some pods without using Inspektor Gadget.

Create the BPF map:
```
docker run -ti --rm --privileged -v /sys/fs/bpf:/sys/fs/bpf --pid=host kinvolk/bpftool \
        bpftool map create /sys/fs/bpf/mnt_ns_set type hash key 8 value 4 entries 128 \
        name mnt_ns_set flags 0
```

Get the mount namespace id of a pod:
```
NS_ID_HEX="$(printf '%016x' $(stat -Lc '%i' /proc/self/ns/mnt) | sed 's/.\{2\}/&\n/g' | tac|xargs echo)"
echo "export NS_ID_HEX=\"$NS_ID_HEX\""
```

Start bcc's execsnoop and monitor this container only:
```
export NS_ID_HEX=...
docker run -ti --rm --privileged -v /sys/fs/bpf:/sys/fs/bpf --pid=host kinvolk/bpftool \
        bpftool map update pinned /sys/fs/bpf/mnt_ns_set key hex $NS_ID_HEX value hex 00 00 00 00 any


docker run -ti --rm --privileged -v /usr/src:/usr/src -v /lib/modules:/lib/modules \
        -v /sys/fs/bpf:/sys/fs/bpf --pid=host kinvolk/bcc \
        /usr/share/bcc/tools/execsnoop --mntnsmap /sys/fs/bpf/mnt_ns_set
```

That's an awful lot of work! This is exactly what the execsnoop gadget is
saving us from doing.
