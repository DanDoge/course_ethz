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
- xml validation
  - all elements in XMLSchema namespace, recommend declaring as xs, xsd
  - top element xs:schema
  - inside: <xs:element name="foo" type="xs:string">
  - extra wtire spaces, newlines and indentation are fine
  - builtin types: strings(incl. xs:anyURI), numbers, datetimes, time intervals, binary, bolleans, null does not exist
  - define user-defined atomic types
    - <xs:simpleType name="foo">
  - complex types: 
    - complex content(nested no tex nodes with direct children)
    - simple content(no nexted elements, text attributes possible)
    - empty content: no nested no text, attributes possible
    - mixed content: can nest, can text
  - attribute: <xs:attribute> can have default in case of missing
  - xml schema are also xml, valid against xml "meta" schema, which is valid against itself
- data frames: forbid open object types, forbid schemas that allow too permissive or allow any values, allow for null and absent values
  - relational tables are df, df can nest btu homogeneous
- data formats
  - for a valid df, different formats: parquet, avro, root, protocol buffers
    - space efficent: smaller, performance efficnet: fast to read
    - schema stored as a header, do not need repeat, compressing
    - parquet: columnar fashion, grouping values with same key
  - data formats classification: whether valid against df schema; whether nest; whether textual

massive parallel processing
- jsonl: one json per line
- hadoop sequence file: list of kv, not sorted(but ordered), keys not unique --> generated with mapreduce
- while hdfs, s3 support intra file parallelism, practically use many-files patterns
  - convenient for mapreduce, easier to down/upload
- mapreduce
  - map phase on entire input, shuffle another map producing output
  - input, intermediate, output all large collection of kv pairs(not unique k, not sorted by k), type knwon at complie time, common that intermediate and output types are same
  - partition input into splits, mapping, shuffle and group by key, reduce(one call per key)
  - arch:
    - input from cloud, hdfs, wide column store
    - (original mapreduce) jobtracker, tasktracker
      - using hdfs, usually there is replica of block on tasktracker/datanode
      - in map phase, intermediate pairs flushed to disk(LSMT of sequence files)
        - then open http wait for connection, shuffling can start before map over, reduce can only start after map
    - mapping files to pairs: each line/multiple line as a value, key being offset, or things befoer sepatare char. being key, after being value
    - optimization: conbining in map phase
      - often, same as reduce: intermediate kv same as output kv
      - reduce function is both associative and commutative
  - terminology: mapper reducer only used when naming classes
    - map function, map task, map slot, map phase
    - task: an assignment consisting series of calls of map function, sequentially
      - no combine task
    - slot: cpu core and some memory, each slot process tasks sequentially
    - paralleism across slots: phases
- first version mapreduce: mapslots and reduce slots preallocated
- hdfs blocks at most 128mb, but kv pairs in a split may spread across two blocks remote call possible --> hdfs api can read a block partially

resource management
- limintation of mapreduce: jobtracker doing resource management, scheduling, monitoring, job lifecycle and fault tolerance
  - not scale, bottlenect at jobtracker, difficult to do things well, static resource allocation
- yarn
  - resource manager, node managers(provide slot known as containers)
  - rm assign one container as application master running the application, am communicate with rm to book and use more container
  - several apps can run concurrentla in teh same cluster
  - mapreduce, spark nto designed for singel user running one job, but optimize resource use and cost
  - resource management: am can request and release container at any time, granted by rm fully or partially, by signing and issuing container token to ap, then am connect nm with the token, then ap ships code and param
  - rm can also issue token to external clients, s.t. they can start am
  - version2 of mapreduce: job lifecycle management to am. container can contain several map slots(save latency of seting up container)
    - am allocating containers when end of map phase approaches, map containers released when reduce slots start processing
    - am rerequest containers when map container fail, when reduce container fail, may have to restart job again
    - scheduling: nm, am send heartbeats to rm
      - strategies: fifo, capacity(quota per division), 
      - fair scheduling(dynamic decisions)
        - steady fair share, instantaneous fair share, current share
        - dominant resource fairness algo: calc donimant resource percentage, and allocate on this dimension

generic dataflow management
- resilient distributed datasets
  - resilient: in mem or on disk , recomputed if needed
  - distributed: partitioned and spread over multiple machines
  - collection fo anything: values within same RDD share same static type, generalization of mapreduce
  - lifecycle: created from local disk, cloud storage, from file system or from mem
    - transformation: rdd -> rdd
      - unary: filter(rdd --> remain? true/false, preserving teh relative order), map(rdd --> single rdd), flatMap(rdd --> rdd*, map in mapreduce), distinct, sample
      - binary: union, intersection, subtraction
      - pair transformation(for kv pairs): key(take the key), value, reducebykey(given a binary opeartor, required to give neutral element for empty partition, reduce of mapreduce), groupbykey(key --> list of values), sortbykey(fiven order on the key), mapvalues(map function applied to values only), join(match pairs with same key and return key -> {val1, val2}, if multiple keys, all combinations are output), subtractbykey(remove keys appeared in the right) 
    - action: rdd  -> storage  or screen
      - collect: downloads all values to client machine, output as local list(only do this if small)
      - count: computes total number of values(in parallel)
      - count by value(only do this if small number of distunct values)
      - take: return first n
      - top: return last n
      - take sample
      - reduce: normally required to give neutral element
      - saveastextfile/saveasobjectfile: for spark, format up to user 
      - actions for pair rdd: countbykey, lookup(given key)
  - lazy evaluation: creation and transformation on their own do nothing, with action the entire computation is put into motion
- arch
  - narrow-dependency transformation: parallized, no communication, e.g. map, flatmap, filter. local read hdfs(short-circuiting), sequential calls of tranfromation function: task --> assigned to slots: cores in yarn containers(containers called executors), processing sequential within each slot(one or more per executor), in parallel across executors
    - chains of them: in the same slot, there is a single set of tasks for entire chain of transformations, called stage(correspond to a phase in mapreduce)
  - shuffling
    - wait for completion of other slots
    - typically linear succession of stages on physical level(topo sort)
  - optimizations: 
    - pinning rdd: pin intermediate rdd if the comp. graph share a subgraph, in case we have the mem/disk for that
    - pre-partitioning: remove shuffling if they are already in order
- dataframes in spark
  - df as specific kind fo rdd: rdd of rows, with relational integrity, domain integrity, not necessarily atomic integrity
  - df stored columnwise in mem, attribute name not repeated, --> more compact
    - and optimized, e.g. not reading a col if not used
  - no free lunch: infer the schema from json files/csv/parquet(with a declared schema)
  - spark sql or dataframe transformation api: no guarantee execution order
  - df structured types: arrays, structures(string key), maps(all val same type)
- skip sparksql: refer to notebooks

document stores
- typically specializes in eother json or xml
- optimized for many records of small ro medium sizes
- do selection projetion, aggregation and sorting well, but not join
- mongodb: storage BSON: less space, support for additional type
  - auto add distinct _id
  - skip again mongodb code
  - projection: find({condition}, {"things need": 1, "od not need": 0})
  - sort: .sort({"asc": 1, "dsc": -1})
  - again order of calls does not matter
  - absent fields: .find({"foo": null})
  - sort fields with diff. types: order of types
  - use dot syntex ofr nested search "foo.bar", {"foo" : "bar"} looks for exact match
    - for array, look for .any()
  - complex pipelines
- arch: sharding by selecting one or several fields(ordered) intervals
  - replica set: set of nodes running mongodb server, nodes iwthin same replica all have copy of same data, each shard assigned to exactly one replica set
  - writing: mondb checks specific min. number of nodes(in the same replica) have updated, then user call returns, then replication continues in the bg(async)
  - index: find/range queries, built requested by user, sync or async
    - hash indices: optim. point queries, O(1), consume space(to avoid collisions), no range queries(looking up every value, impissible for decimal or double), foo.createIndex({"bar": "hash"})
    - tree: B+tree, node size fo a block
      - all leaves exactly same depth, number of children within interval(d+1, 2d+1, except root(2, 2d+1) or 0), list of values interlaced with pointer to children(d, 2d) of them
      - all values on leaves iwth a pointer to docs, value can repeat on non-leaf nodes for comparison purposes
      - typically chain all leaves for traversals(support min/max only range query)
      - split and incease depth(if needed) when inserting, and merge when deleting
      - logn lookup
    - secondary index: tree index for _id
      - e.g. having index ABCD, then index for A, AB, ABC are useless

querying denormalized datasets
- skip JSONiq
- data-independent layer on top of datalakes and ETL DBMS
- query lang: declarative, functional, set-based