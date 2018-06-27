{
   Simple:: function(name, port) {
      "apiVersion": "v1",
      "kind": "Service",
      "metadata": {
         "name": name + "-svc",
         "labels": {
           "app": name
         }
      },
      "spec": {
         "ports": [{
           "port": port,
           "protocol": "TCP",
           "targetPort": port,
         }],
         "type": "LoadBalancer",
         "selector": {
            "app": name
         }
      }
   }
}
