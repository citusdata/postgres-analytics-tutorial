# pgopensv-analytics-tutorial
### Clone the repository
Downloads all the scripts and data needed for the tutorial.
  ```bash
  git clone https://github.com/citusdata/pgopensv-analytics-tutorial.git
  cd pgopensv-analytics-tutorial 
  ``` 
### Schema
Schema has 3 main tables
* **events**: raw table which captures every event.
* **rollup\_5mins**: table to store aggregated data every 5-minute intervals.
* **rollup\_1hr**:   table to store aggregated data every 1-hour. <br />
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
\COPY events(customer\_id,event\_type,country,browser,device\_id,session\_id) FROM data/1.csv WITH (FORMAT CSV,HEADER TRUE);
```

### Run aggregation queries.
**5-minute Aggregation**
```bash
SELECT hourly\_aggregation();
```
**1-hr Aggregation**
```bash
SELECT five\_minutely\_aggregation();
```

