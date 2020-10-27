{
   "apiVersion":"spinnaker.io/v1alpha2",
   "kind":"SpinnakerService",
   "metadata":{
      "name":"spinnaker"
   },
   "spec":{
      "kustomize":{"front50":{"deployment":{
        "patchesStrategicMerge":[|||
          spec:
            template:
             spec:
                containers:
                - name: front50
                  command: ["/bin/sh", "-c",
                            "/hack/init/init-script.sh"]
                  volumeMounts:
                  - name: ca-cert
                    mountPath: /tmp/certs
                  - name: init-script
                    mountPath: "/hack/init"
                volumes:
                - name: init-script
                  configMap:
                    name: init-script
                    defaultMode: 0755
                - name: ca-cert
                  secret:
                   secretName: k3s-serving
                   items:
                   - key: tls.crt
                     path: k3s.crt
                   - key: tls.key
                     path: k3s.key
        |||]}}},
      "expose":{
         "service":{
             "type": "NodePort"
         },
         "type":"service"
      },
      "spinnakerConfig":{
         "config":{
            "persistentStorage":{
               "persistentStoreType":"redis",
               "redis":{},
               "s3":{
                    "endpoint":"https://minio-.default.svc.cluster.local",
                    "accessKeyId": "minio",
                    "secretAccessKey":"minio123",
                    "bucket": "spinnakerbucket",
                    "rootFolder":"front50"
               }
            },
            "version":"1.17.1"
         },
      },
   }
}
