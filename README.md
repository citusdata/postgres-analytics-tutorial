# Architecting Real-Time Analytics for your Customers

[Slide deck](https://docs.google.com/presentation/d/1294AeJ1EZXN6Ae1URD4DqW-ekHIc977atQoMDQnJc_M/edit?usp=sharing)

### Spin up the cluster
Use this [link](http://bit.ly/citustutorial). <br />
**Do not use the links in the UI to create the schema**. We will create it manually.

### Clone the repository
Downloads all the scripts and data needed for the tutorial.
  ```bash
  git clone https://github.com/citusdata/pgopensv-analytics-tutorial.git
  cd pgopensv-analytics-tutorial 
  ```
### Connect to the database
Connect to the cluster/database using any postgresql client. Below is an example using psql.
```bash
psql "<connection-url>"

```
Follow the below steps one by one after connecting to the cluster.

### Schema
[Schema](schema.sql) has 3 main tables:
* **events**: raw table which captures every event. It is a partitioned table. You'd creating a partition every 5 minutes. Used [pg\_partman](https://www.citusdata.com/blog/2018/01/24/citus-and-pg-partman-creating-a-scalable-time-series-database-on-PostgreSQL/) to create partitions.
* **rollup\_events_5mins**: table to store aggregated data every 5-minute intervals.
* **rollup\_events_1hr**:   table to store aggregated data every 1-hour. <br />
Connect to postgres via psql and run the below command to create the above tables. <br />
Also note that we are sharding each of the tables on tenant\_id column. Hence they are colocated. <br />
```sql
\i schema-1.sql
\i schema-2.sql
```

### Setup incremental rollup setup
[SQL Script](setup_rollup.sql) to track the event\_id until a rollup (5min or 1hour) has been completed. This is used by the actual
rollup functions to continue the rollup from that event\_id.
```sql
\i setup_rollup.sql
```

### Creating rollup functions
Uses the bulk UPSERT (INSERT INTO SELECT ON CONFLICT) to perform the aggregation/rollup.<br />
**Rollup function to populate 5-minute rollup table:**[link to function definition](5minutely_aggregation.sql) <br />
```sql
\i 5minutely_aggregation.sql
```
**Rollup function to populate 1-hr rollup table:**[link to function definition](hourly_aggregation.sql)<br />
```sql
\i hourly_aggregation.sql
```

### Data Load
Load a csv file into the events table.
```sql
\COPY events(customer_id,event_type,country,browser,device_id,session_id) FROM data/1.csv WITH (FORMAT CSV,HEADER TRUE);
\COPY events(customer_id,event_type,country,browser,device_id,session_id) FROM data/2.csv WITH (FORMAT CSV,HEADER TRUE);
```
There are [more](data) csv files which we can [load](copy.sql) later.

### Run aggregation queries.
**5-minute Aggregation**
```sql
SELECT five_minutely_aggregation();
```
**1-hr Aggregation**
```sql
SELECT hourly_aggregation();
```

### Dashboard Queries
```sql
--Get me the total number of events and count of distinct devices in the last 5 minutes?

SELECT sum(event_count), hll_cardinality(sum(device_distinct_count)) 
FROM rollup_events_5min where minute >=now()-interval '5 minutes' AND minute <=now() AND customer_id=1;

--Get me the count of distinct sessions over the last week?

SELECT sum(event_count), hll_cardinality(sum(device_distinct_count)) FROM 
rollup_events_1hr where hour >=date_trunc('day',now())-interval '7 days' AND hour <=now() AND customer_id=1;

-- Get me the trend of my app usage in the last 2 days broken by hour

SELECT hour, sum(event_count) event_count, hll_cardinality(sum(device_distinct_count)) device_count, hll_cardinality(sum(session_distinct_count)) 
session_count FROM rollup_events_1hr where hour >=date_trunc('day',now())-interval '2 days' AND hour <=now() AND customer_id=1 GROUP BY hour;

-- Get me the top devices in the past 30 minutes
SELECT (topn(topn_union_agg(top_devices_1000), 10)).item device_id
FROM rollup_events_5min  where minute >=date_trunc('day',now())-interval '30 minutes' AND minute <=now() AND customer_id=2;

```

### Schedule Aggregation Periodically: 
You can run the above aggregations periodically (5min or 1hr) using [pg\_cron](https://github.com/citusdata/pg_cron)
```sql
SELECT cron.schedule('*/5 * * * *', 'SELECT five_minutely_aggregation();');
SELECT cron.schedule('*/5 * * * *', 'SELECT hourly_aggregation();');
```

### Data Expiry
To expire data you can basically directly drop a partition. This can be done on a periodic basis.
```sql
DROP TABLE <events_partition>;
```

### References
https://www.citusdata.com/blog/2017/12/27/real-time-analytics-dashboards-with-citus/ <br />
https://www.citusdata.com/blog/2018/06/14/scalable-incremental-data-aggregation/ <br />
https://www.citusdata.com/blog/2018/03/27/topn-for-your-postgres-database/ <br />
https://www.citusdata.com/blog/2017/04/04/distributed_count_distinct_with_postgresql/ <br />
https://www.citusdata.com/blog/2018/01/24/citus-and-pg-partman-creating-a-scalable-time-series-database-on-PostgreSQL/ <br />
