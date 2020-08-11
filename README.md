
#TODO



# Services to incorperate

* Sandstorm or Appscale
* Cassandra for a blobstore-like service
* Kubernetes ScheduledJob documentation
* Etcd at a global service
* Gerrit for code review
* opentelemetry.io
* Spark for offline processing
* ScyllaDB for eventual high-write rate
* Spark Streaming
* leveldb/hyperdb/rocksdb/lmdb or something to handle packing data/protobufs into files

# Neet to implement services
* FCM for alert notifications, as well as irc chats.
* Silence Manager, I think that an existing alert manager with prometheus has one.
* url shortener
* canary analysis that feeds off of prometheus data and gives verdict if there is stastical difference betwen the 2 streams.
* load shedding library
* ACL library
* weekly summary of work in md format
* meta channel
  * Rate limiting
  * Experiment data
  * Auth tokens
* Playbook service
* dos protection
* Lamprey services
  * Pubsub
  * cache
  * Quota checker
  * Logging (log4j2 with prometheus defaults)
* rpcz (context routed around to report count of RPCs broken down by incomming service,method and outgoing method,service.
* Jira or something like that
* IRC with FCM push capabilities

