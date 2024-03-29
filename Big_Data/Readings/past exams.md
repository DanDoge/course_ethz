- data totality: 
- parallel and batch processing: why?
  - parallel for capacity -- throughput
  - batch for throughput -- latency
- data definition language
  - create, alter, drop things
- C in ACID and CAP
  - in CAP: all nodes see same data
  - in ACID: before and after transactions, data is consistant(e.g. summation related things)
  - not same: acid for single node, cap for clusters
- rack units
  - height of rack module
- spark transformation for projection
  - map?
- semi structured documents: normal form?
  - can be nested and heterogeneous
- xml attributes: data structure?
  - no duplicate
- mongodb replica set contain all data in collection?
  - all data in the same shard
- write concern in mongodb
  - check min. no. of nodes performed update

- hdfs: flat storage file system? --> no, hierarchy
  - optimized for batch processing? --> yes, per apache
  - read: addr of datanode sorted by proximity? --> yes
  - read: client signal read finished? --> no mention
- hbase: deletion how? --> keytype for deletion falg in kv
- spark: fault tolerance?
- mongodb: atomicity level? --> level of single document

- hbase: single point of failure? --> hmaster
  - hbase: level of ACID? --> row
  - CAP type? --> CP
- mapreduce: recompute things if fail?(v1)
  - no. splits and no. blocks?
- capacityscheduler? --> literally
- pairRDD: unique key? partition? function support?
  - not unique: we have reducebykey transformation
  - functional support: all, and also some specifically for pair rdd
- xml: comment in comment?, excape <>?
  - i think no: no -- in comment, excape <
- jsoniq: sequence = something?
  - existance query
- mongodb: find(arg1, arg2), optional?
  - we do can find()
- CRUD
- neo4j: arch? --> master - worker
  - ACID transaction?
  - latency in write?
- rollup
- 2018 jsoniq things
  - count([]) --> 1
  - seq lt 1.7 --> error, seq and value comparison
  - groupby but return without grouby vadiables --> equivalent to no group by
  - (1, (2, 3), foo, bar) --> (1, 2, 3, foo, bar)

- hdfs: full posix? --> no
- xml naming rules: case sensitive
  - start with letter or _
  - cannot xml Xml, xML
  - contain letters, digits, hyphens, _, ., :
  - no spaces
- xml attr: live in no namespaces if no prefixed
- json data type?
- hfiles: kv are sorted by key
- B+-tree used in RDBMS
- xs:simpleType and xs:complexType must always be direct children of an xs:element node
- dremel: 1 table per leave node in tree
- since it is user code, do not trust application master
- mongodb: elematch {}, not []
- cypher: order by but no group by(done by aggr. functions)
  - possible for match multipe pattens
  - where can use patterns
- triple graph: what can be what? --> literal only object, no blank node for predicate
- materialization in data warehouse? --> precomputed aggregations

- throughput: definition?
- sql 3-valued logic? --> t, f, null
- Parsing an XML file includes downloading the resources located at the declared namespace URIs?
- xml optional attr.: use = optional
- sparkdf require schema to use? --> not required
- mongodb: lock all affected docs when writing?
- neo4j: relationship has properties? --> only types
  - node have multiple labels? --> yes
- cypher: has regex matching
  - node record has properties? --> not in physical storage

- max. capacity of amazon s3 bucket
- object storage: high sequentilal thogurhput?
- heartbeat: timestamp from datanode to namenode?
  - inform storage capacity/in-use storage? --> yes
- xml rules?
- tabular integrity?
- hbase: add col. family? --> yes?
  - schema-less? --> yes
- mapreduce: communication between reduce tasks?
- document store: project away?

- default size of hblocks? --> 128mb
- compaction threshold? --> then 2^k * such value
- memstore: sorted? --> yes
- neo4j: acid transactions?