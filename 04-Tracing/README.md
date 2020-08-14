## 04 - Tracing


Start the caturday example by running: `kubectl apply -f caturday.yml`

Once this is running, connect to the service, either by using
`minikube service caturday -n caturday`, or
`kubectl port-forward service/caturday -n caturday 8080:80`

Connect to the webpage and check that it's working.

Now run a trace on the pod. To do that, first get the pod name with:
`kubectl get pod -n caturday`, and export it to PODNAME.

Then run:
```
kubectl trace run -e 'uretprobe:/proc/$container_pid/exe:"main.counterValue" { printf("%d\n", retval) }' \
    pod/$PODNAME -a -n caturday
```


