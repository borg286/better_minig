{
   "apiVersion":"spinnaker.io/v1alpha2",
   "kind":"SpinnakerService",
   "metadata":{
      "name":"spinnaker"
   },
   "spec":{
      #"kustomize":{"front50":{"deployment":{
      #  "patchesStrategicMerge":[|||
      #    spec:
      #      template:
      #       spec:
      #          containers:
      #          - name: front50
      ##            volumeMounts:
      #            - name: ca-cert
      #              mountPath: /etc/ssa/certs
      #          volumes:
      #          - name: ca-cert
      #            secret:
      #             secretName: k3s-serving
      ##             items:
      #             - key: tls.crt
      #               path: k3s.crt 
      #  |||]}}},
      "expose":{
         "service":{
             "type": "NodePort"
         },
         "type":"service"
      },
      "spinnakerConfig":{
         "config":{
            "persistentStorage":{
               "persistentStoreType":"s3",
               "s3":{
                    "endpoint":"http://minio-hl.default.svc.cluster.local",
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
