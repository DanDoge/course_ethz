### Dynamo

consistency to trade availability: versioning
- primary key only interface; k-v access
- eventuall consistency: all updates goes to all replicas
- always writeable, no namespaces

arch
- expose get, put
  - get return replicas with context
- partition
  - hash to a ring, data assifned to a node by walking clockwise
  - virtual nodes for heterogeneity: failure node distributed its load evenly to others
- replication
  - coordinator replicates kv at N-1 successors
  - preference list: list of nodes for a key
  - skipping positions to makesure physically, nodes are different, when using virtual nodes 
- versioning
  - change to older version should be preserved
  - vector clocks: list of node, counter pair
  - return all vc and subsequent write reconcil these conflicts
  - add a timestamp and remove older vc if it gets longer
- execution
  - R, W number of nodes in successful read write operation
  - coordinator send new things to N nodes and if W - 1(since it self also writes) respond, success
- failurse
  - send data to next noad if one dies, and hint where it should have been, send back if node is alive
  - W=1 for highest availability: as long as one node alive, write success
- replica sync
  - merkle tree to reduced data transfer
  - check root, if not equal, check children
  - exchange hash of common range for two nodes
- membership and failuter detection
  - connect to a node to issue a join/removal, propagate changes
  - a new node choose a set of tokens/virtual nodes, partition and placement also propagates, s.t. every node know the range handles by peers for forwarding
  - nodes all know some seeds and reconcile menbership with a seed
  - locally node can consider others failed if no response, and use alternative nodes, retry connection to check recovery. no need to know others when no requests. also a gossip protocal here
- adding/remove nodes: send key to new/old nodes
  
implementation
- read: send request --> wait for min. response --> fail or gather all versions, determine which to return --> if versioning, syntactic reconciliation and generate a write context --> return, but also wait for other responses, update nodes with older versions(read repair)
- every top n nodes in preference list can coordinate writes(any node can coordinate read, in case of time stamp versioning, any node can do that for write), choose the fastest one from previous read for read-your-write consistency

experiment
- write latency larger than read
  - object buffer for cacheing writes, write to disk periodically done by writing threads, coordinator choose one node to to a durable write to avoid data loss from crashing, not hurting performance, since we only wait for W(not N) responses
- increasing load, better load balancing
  - fix partition for better load balancing
- divergent version: from system failure or concurrent write(main cause)
- balance BG/FG tasks
  - replica sync, data handoff

### dremel

read only nested data
- in situ
- columnar storage format
- required, repeated, optional

nestd columnar storage
- repetition levels: how many things are repeated(w.r.t. previous one)
  - adding null if things are totally missing
- definition level: how many things are defined(repeated or optional)
- finite stage machine fro reading, traverse from st to ed per record
  - simple FSM if subset of fields to retrieve
  - server query tree to query from each disjoint partition

### Rumble

large heterogeneous nested JSON, build on top of Spark
- jsoniq: declarative, functional query
  - empty seq. if not found, also for arithmic expr.
- execution modes
  - local: java. RDD: spark rdd. DataFrame: dataframe interface(faster)
  - iterators can exploit the inputs' mode for higher efficiency
- order by: sequences are comparable if at most one item, and of the same atomic type or null

### graph DB, ch. 1, 2, 3, 4, 6

nothing new

### Database Systems: The Complete Book, ch 10.6,7

relational olap: fact table + star schema
- multidimensional olap: datacube
- nulls in queried results: rolled up dimensions

### textbook

V: volume, variety and velocity
- volume: KMGTPEZY
- variety: trees, unstructures, cubes, graphs, tables
- velocity: capacity, throughput, latency
  - capacity -- throughput: parallel, batch processing

relational integrity: same set of attributes for all rows
domain integrity: same column being the same type
atomic integrity: no nested collections/sets/lists

relational algebra
- projection: select columns, selection: select rows
- grouping or aggregation

normal form
- first normal form: atomic integrity
- second normal form: each column contains information on eitire record(all primary keys)
- third normal form: no dependencies on things other than primary key

SQL: declarative lang, no specification of how things are done
- where: selection, select: projection
- having: selection after grouping

ACID
- atomicity: update applied completely or not al all
- consistency: data in consistant state
- isolation: the usr is only one using the system
- durability: written data not lost
- on large system: CAP: consistency, availbility, partition tolerance
  - consistancy: all nodes see the same data
  - availability: available at all times
  - partition tolerance: function even under network partition
    - cannot met all of them, whether halt system(CP) or serve different data(AP)
    - or AC and no guarantee under partition

REST API: access to data store, but to be consumes by a host lang.
- methods applied to resources
- resources: URI, scheme : authority(//things) path(/things) query(?foo=bar) fragment(#foo)
- methods: get without a body, put create/updates a resource: has side effect for subsequent get, idempotent, delete w/o body, post acts on a resources in any way fit

databases: ETL, stored as proprietary format
- or data lakes: stored on file sys and queried in place, slow but w/o ETL

scale up: poweful machine, scale out: more machines(data does not fit on single laptop or IO bottleneck)

object stores
- amazon S3(simple storage service)
  - objects in buckets, bucked ID - object ID, no hierarchies, most 5TB per object, 5GB per block(in terms of uploading)
- SLA: 99.99% time -> 1hour down per year, response time in terms of percentile
- we can use / in file names, logically enables a file path
- azure blob storage
  - account, container and blob: 3 ids
  - block access exposed to user
  - append blobs(195G) for logging and page blobs(190.7T) for vm?
  - physically organized in storage stamps

distributed file systems
- prev: object storage for huge amounts of large files
- now: large amounts of huge files
  - bring back file hierarchy, block based storage natively
  - focus on efficient scan and append to existing file, with concurrent users
  - bottlenect being throughput, not latency
- HFDS
  - file hierarchy: namespace
  - file as list of blocks/chunks, blocksize 64 or 128mb
    - smaller enough for spearding over machines adn parallel access, and for network overhead
    - large enough for smaller latency
  - namenode/datanode
    - each block replicated (replication factor) times, no primary replica
    - namenode: stores namespace(hierarchy of directory/file name, access control), mapping fro mfile to blocks(64-bit id), mapping from block to replicas(list of datanodes)
      - send client block ID for read or list of datanode locations for read/write
    - datanode: last block might be smaller: no waste of space, send regular heartbeat to namenode, notification a new block things, also full report per some hours, report block corruption, and async replicate the block elsewhere
    - namenode never initiate connection to datanode, only answer to heartbeats
    - client send things to the first datanode, and replicate through pipeline(file send by network protocal, 64kb, acks sent in streaming fashion)
    - read a file: ask for file -> return block locations, datanodse per block, sorted by distance, read from datanodes as a stream
    - write a file: create file, reply datanodes for first block(file locked, not readable for others), connect to it, organize a pipeline, sending block, getting ack, get reply for second block, ..., send close/release lock, cehck for minimal replication, then final ack. then async.ly trigger replication
  - replication strategy: data center - rack - node, path as tree paths
    - first replica on the same machine client is on, second on different rack, third on another node on the second rack, more replicas random: at most one replica per node, at most two per rack
  - fault rolerance and availability
    - metadata backedup: namespace and filetoblock is backedup, blockid to datanode does not need to(we have heartbeats)
    - after a snapshot, store a edit log, locally or on network(not HDFS)
      - upon restart, load snapshot and reply editlog, and hten wait for block reports from datanodes
    - standby/checkpoint/backup/secondary... namenode
      - editlog periodically merged to larger snapshot --> checkpoint, done by aphantom namenode
      - phantom namenode can takeover from namenode
      - standby namenode: what it is called now
      - federated namenodes: each one responsible for a specific directory
  - hdfs dfs <put linux command here>
    - URI: hdfs://, in S3: s3://, locally file:/// 

Syntax
- CSV: comma separated values
  - escape comms by "", but quote also have to be escaped
- data denormalization
  - JSON: include attribute in every tuples -> drop ientical support requirement
    - also allows for nested data
  - semi sturctured data: heterogeneous, nested data
- well-formed: whether string belongs to language
- JSON
  - string: in double quotes, escape " \ \n \r \t \u(four hexadecimal digits, allows for any char via Unicode)
  - numbers: - 123.456[Ee]-123, - is optional, + is not allowed, leading 0 not allowed, except integer part is 0, e.g. .23 not allowed
  - bool: true, false
  - null: null
  - array: list of values
  - object: {"foo": things}
    - recommends ofr keys to be unique
- XML, extensible markup lang.
  - elements: <foo>things</foo>, or <foo/> if things are empty
    - elements not in opening/closing tags, top level only one element
  - attributes: in opening element tags <foo a="b" c="d">
    - double or single quote, never quote key, no duplicate keys within the same tag, never in close tag(but can be in empty tag)
    - no elements in attribute values, key not start with XML, xml, Xml, ...
  - text: wo quotes, in elements
  - comments: <!-- comment -->, can apear in top level, but there has to be only one element at top level
  - text declaration: <?xml version="1.0 or 1.1" encoding="things"?>
    - 1.1: adding international chars.
    - <!DOCTYPE things>: must repeat top level element
  - escaping < > " ' & &lt/gt/quot/apos/amp;
    - in text & < must be escaped, in single/double quoted attribute values, single/double quote must be escaped
  - namespaces
    - identified with a URI, not always visitable in a browser
    - all elements in a namespace: top level element with declaration xmlns="uri", not attribute, since attr cannot start with xml
    - file w/o namespace: namespace is absent
    - qname: declare xmlns:foo="uri", and then use foo:bar with prefix foo
      - without prefix: absent prefix, look for xmlns="uri", otherwise namespace is absent
    - recommendation: declaration in top-level element, no two namespace with same prefix(error), and vise versa, no mixing of xmlns and xmlns:prefix declaration
    - for attributes: unprefixed ones does not live in default namespaces, not possible to have two attr with same localname but diff. prefix that point to the same namespace, e.g. <ele foo:attr="val" bar:attr="val">, where foo and bar are the same uri

wide column stores: high-throughput and low latency
- hdfs: latency for huge amounts of small files
- not a RDBMS: no data model, can nest value, no schema, no SQL, can be sparse
- BigTable/HBase
  - avoid joins --> more columns, and sparse tablem; store things accessed together together
  - enhanced kv store: key: row, col, version; sortable keys, larger value
  - column families: name being a string; also column qualifiers(?, all things binary), column created on the fly, rows need not have data in same col.s
  - versioning: timestamp, or user choose things
- logical queries
  - get: retrieve row specifying rowID, optionally request some cols or a specific/latest-k version
  - put: put a val specifying col family, column qualifier, optionall version(default: timestamp), locking at row level
  - scan: query whole table or part of table, optionally at a specific version or time range. fundamental for high throughput in parallel processing
  - delete: specifying rowID, col family qualifier, optionally specific version or <= a version
- arch
  - partitioning on rows(consecutive  regions, id.ed by [lower, upper) key) and col.s, a partition is a store: intersecton of region and column family
  - HMaster, Regionserver: processes, commonly on namenode and datanode respectively
    - HMaster: assign responsibility of region to one region server: all col families in this region handled by the same region server --> fault tolerrance handled by HDFS. split by region server because of many writes in the same interval(hot spots? --> salting or hashes in rowID prefixes), HMaster reassign regions to other region servers if it has too many, reassign if one region server fails
- storage: nothing less than a set of cells, IDed by rowID column family version
  - each cell eventually persisted on HDFS, HFiles, flat list of KeyValues, one per cell, sorted in increasing order(rowID, col family, qualifier, version(decreasing order, recent to old))
  - a KeyValue: length of keys, length of values, key, value
    - key: rowID, col family, col qualifier, timestamp. row length, row, col family length, col family, col qualifier, time stamp(fixed size), key type(for marking as deleted)
    - KeyVales organized in blocks(not HDFS block)
    - HFile also contains an index of all blocks with key boundaries, load to mem prior to reading
  - new cells added in mem, if full, flushed to new HFile(all cells written in ascneding key order, while building index, sorting is done at adding time(add to tree))
    - write ahead log to not lost things, HLog, one per store
    - conpaction: merge some files together(merge sort), done in logarithmic pattern --> LSM
  - lookup: there is a main big lookup table: listing all regions of all tables, with region server in charse and metadata(for splitting regions, etc.) --> also a HBase table, fits on a singel machine ,known to everyone, client must communicatte with HMAster to create/del/upd tables
  - caching: cells can be cached in separate menory region
  - bloom filters: avoid checking every hfile, maintaining filters for each hfile or even column
  - data locality: HFile writen to HFDS, first replica on the same node, localling reading data w/o communicating with namenode, short-circuiting not always possible when replicas moved, but compaction bring HFile back again
  
data model and validation
- csv: enforce relational integrity and atomic integrity, domain integrity implicit(at least as string)
- json: nodes are information items and form information set
  - logical tree: values as nodes and key as edges
- xml: information items are elements arrtibutes texts
  - labels also on nodes
  - while json information item does not know the key it is associated, but xml know the name
  - document information items/element/attribute/char/comment/...
    - document: root of xml tree, properties: children: element information item, version
    - element information item: local name, children, attributes, parent
    - attribute information item: local name, normalized value, parent
    - char: character code, parent. one item per char or group them together
- validation: schema in RDB defined before data population(schema on write), but in case of json xml, validation can happen ex post, schema on read
  - thus document goes two steps: well-formedness chech, validation check
  - homogeneous collections: documents valid against a specific schema
  - type systems
    - atomic types(string, numbers: integers(or subtypeso  integers), decimals(usually base 10), floating point, booleans, date and times(Gregorians calendar, hexagesimal basis --> ISO 8601 standard, gYear: only year), duration: avoid month and days, year+month or day+hour+min, binary: hexaecimal or base64 +/.= for padding, null: valid value for any type or null as absence(thus {} and {"foo": null} are not distinguishable))
    - structured types: lists, records(maps from string to values), maps(map from atomic value to any value), sets, xml elements and attributes(xml has no support ofr records and maps)
    - sequence types: cardinality(once, optional, any occurence, at least once)
      - disthinguish collection of items(massiely large, relational table) and list of items(restricted in size) 
- json validation
  - JSound syntax: {"key": "type"}, string, anyURI, integer, duration, yearMonthDuration
  - JSON schema: {"type": "object", "properties": {"foo": "types"}}, types only six(except numbers also include integer)
  - both can restrict length of string, numbers in a interval
  - by default, key is optional: "!foo" require the presence of key, for json schema: "required": ["foo" ]
  - JSound syntax: extra keys are forbidden(i.e. closed)
  - JSON schema: extra keys are allowed by defualt(i.e. open), except: "additionalProperties": false
  - for nested structures: {"foo": ["types" ]}, work also for multiple dimensions {"foo": [["types" ]]}, in JSound, things can nest arbitrarily, also for JSON schema
  - JSound allow for user-defined types
  - only in JSound syntax: 
    - "@foo" --> primary keys, must be diff. in a array
    - "foo?" --> allow for null
    - "foo": "type=bar" default value in case of absent
    - for validation, quote does not matter, only check whether the lexical values are part of lexical space
    - "item": type that accept any values
  - JSON schema: "key": false --> forbid a field
    - also possible to combine validation check "anyOf": [{"type": "foo"}, {"type": "bar"}], similarlly "allOf", "oneOf", "not"
      - in JSound: "foo|bar" support only