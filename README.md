# pgopensv-analytics-tutorial
### Clone the repository
Downloads all the scripts and data needed for the tutorial.
  ```bash
  git clone https://github.com/citusdata/pgopensv-analytics-tutorial.git
  cd pgopensv-analytics-tutorial 
  ``` 
### Schema
Schema has 3 main tables:
* **events**: raw table which captures every event.
* **rollup\_events_5mins**: table to store aggregated data every 5-minute intervals.
* **rollup\_events_1hr**:   table to store aggregated data every 1-hour. <br />
Connect to postgres via psql and run the below command to create the above tables. <br />
Also note that we are sharding each of the tables on tenant\_id column. Hence they are colocated. <br />
```bash
\i schema.sql
```
### Setup incremental rollup setup
Infra to track the event\_id until a rollup (5min or 1hour) has been completed. This is used by the actual
rollup functions to continue the rollup from that event\_id.
```bash
\i setup_rollup.sql
```

### Creating rollup functions
Uses the bulk UPSERT (INSERT INTO SELECT ON CONFLICT) to perform the aggregation/rollup.<br />
<br />
**Rollup function to populate 5-minute rollup table:**
```bash
\i 5minutely_aggregation.sql
```
**Rollup function to populate 1-hr rollup table:**
```bash
\i hourly_aggregation.sql
```

### Data Load
Load a csv file into the events table. 
```bash
\COPY events(customer_id,event_type,country,browser,device_id,session_id) FROM data/1.csv WITH (FORMAT CSV,HEADER TRUE);
```

### Run aggregation queries.
**5-minute Aggregation**
```bash
SELECT hourly_aggregation();
```
**1-hr Aggregation**
```bash
SELECT five_minutely_aggregation();
```

### Dashboard Queries
```bash
--Get me the total number of events and count of distinct devices in the last 5 minutes?

SELECT sum(event_count), hll_cardinality(sum(device_distinct_count)) FROM rollup_events_5min where minute >=now()-interval '5 minutes' AND minute <=now() AND customer_id=1;

--Get me the count of distinct sessions over the last week?

SELECT sum(event_count), hll_cardinality(sum(device_distinct_count)) FROM rollup_events_1hr where hour >=date_trunc('day',now())-interval '7 days' AND hour <=now() AND customer_id=1;

-- Get me the trend of my app usage in the last 2 days broken by hour

SELECT hour, sum(event_count) event_count, hll_cardinality(sum(device_distinct_count)) device_count, hll_cardinality(sum(session_distinct_count)) session_count FROM rollup_events_1hr where hour >=date_trunc('day',now())-interval '2 days' AND hour <=now() AND customer_id=1 GROUP BY hour;
```

### Schedule Aggregation Periodically: 
You can run the above aggregations periodically (5min or 1hr) using pg\_cron
```bash
SELECT cron.schedule('', 'SELECT five_minutely_aggregation();');
SELECT cron.schedule('', 'SELECT hourly_aggregation();');
```

