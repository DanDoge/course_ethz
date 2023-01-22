sql
- string match  cand like 'foo%'
  - = for exact matches
  - ~ for regular expressions
- from a join b using(c)
- filter after group by: having
- with a as (), b as () select things
- intersect or exists

dynamo
- virtual nodes: round up(or down), practically, smallest server with 2 virtual nodes(avoid huge rounding error)

hdfs
- datanode can execute multiple application tasks concurrently
-  extra spaces more than a block --> round up to block size in OS(4k maybe)
-  object storage has limit on object size(sinze cannot partitioned)

xmljson
- no -- in comments, no duplicate attribute, < must be excaped in text, & also excape
- - can in xml names
- json: must double quote, null only(Null is not valid)

hbase
- pure row store: good for point lookup, expensice scan
- pure column store: effiicent scan, random access for retireve a row
- wide column store: tradeoff. flexible shcema, performance and storage overhead
- denormalization: no need to join, difficult for consistency, overhead, epxencive scan
- hbase block: fill kv pairs until exceed the limit(so always >= limit)
  - one entry per block in index

data models
- mixed = true: allow char data mixed in child elements, default = true
- attributes: optional by default, open by default

mapreduce, spark
- input kv for map is not sorted
- yarn: scale, rigidity, recourse utilization, flexibility
  - resource manager cna request resources back from running application
- rdd.persist() for caching, otherwise recomputed per action
  - evict old ones using lru
  - .unpersist()
  - persist() and cache() both lazy
- spark: hash partition by default
  - partitionby(): tuple objects, is transformation
  - faster than mapreduce: in mem, mergeinto stages
- sparkdf
  - array_contains("arr", "foo")
  - array_size()
  - explode().alias("foo") for unnest array
  - select * from table lateral view explode(array) as foo where foo.something = "bar"

document store
- ...is a subclass of kv store
- find first/second in array --> replace foo.arr : bar with foo.0.arr : bar
- index on _id by default, cannot remove
  - index on embedded document support only equality match
    - not foo.bar things using {foo : 1}
- mongodb can use intersetion for two indices
  - but slower
- hash indices for partition
- mongodb has joins

jsoniq
- distinct-values
- 1 idxed
- div for division
- eq ne gt lt le
  - = > for exist in arr

OLAP
- slide: subset, dice: aggregate