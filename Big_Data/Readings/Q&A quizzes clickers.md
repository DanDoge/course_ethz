hdfs: other clients can read files being written
- hdfs blocks immutable: cannot modify bytes written, append only

regionserver splits region without permission from the hmaster
- hmaster is informed later, then it deside whether assign the region to other servers

per oxygen, optional attributes are possible

parquet can nest

mongodb find: only in first level array, not deeper

mongodb: index then able to sharding, shard key must be (prefix of) exising index

hlog: one per resionserver, now called write ahead log

quiz
- variety: various shapes of data, table tree cube graphs and unstructured
- ACID: atomicity, consistency, isolation and durability
- selection in SQL performs a projection
- in restapi, several post will create several resources
- in restapi, get should not have side effects and not have payload
- object storage can have diff. metadata but file storage metadata is fixed
- hdfs: no random access
- hdfs blocks exposed to client
- datanode organize replication pipelines
- hbase: costly to modify column family name
- hbase: bloom filters also in hfiles
- hbase: row level atomicity
- hbase: range [)
- xml: definition order must be preserved
- xml: schemas for sequences, minoccures and maxoccurs are both 1
- definition level: no. of repeated and optional ones, repetition level: no. of common prefix with previous one
  - dremel is query engine, query lang is still sql
- mapreduce: user can set reduce slot numbers
- yarn: nodemanager heartbeat and report to resourcenameger
- spark: transformation creates a new rdd, not modifying existing rdd
- lazy evaluation can reduce no of passes and grouping operations
- b+-tree chains leaves with pointers --> efficient traversal
- mongodb: only filter on the outermost nestness
- mongodb: writes are sync., checking for replicasets are not
- mongodb: indexing on objects does not effect queries accessing subfields
- mongodb: only one field in index can be array
- mongodb: indexing an array creates index for each element for the array
- mongodb: where(not depending on version) and exists(depending on version) cannot user index
- jsoniq: if then else, else(the keyword) is required, can be empty
- rdf has namespaces/IRIs not for labeling but for identifying things
- cypher lock all affected things for write
- cypher shortestpath accepts single relationships
- data warehouse is software

clicker
- DynamoDB: AP, not consistent but eventually consistent
- namenode for directory, and datanode for files
- xml 1.1 from 1.0: unicode, end of lines
- xml entity reference: &apos, &#things
- kv in HBase: smallest unit of storage, idxed by r, c, version, sharede by regions and col family
- hbase fast? kv in memstore and cache, shortcircuiting
- jsoniq: processes sequences of items
- tree-like DF --> can store as parquet