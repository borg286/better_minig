{
   Simple:: function(name, containerSpec) {
      "apiVersion": "apps/v1beta1",
      "kind": "Deployment",
      "metadata": {
         "name": name
      },
      "spec": {
         "replicas": 1,
         "template": {
            "metadata": {
               "labels": {
                  "app": name
               }
            },
            "spec": {
               "containers": [containerSpec]
            }
         }
      }
   }
}

