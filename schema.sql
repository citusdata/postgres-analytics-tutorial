CREATE TABLE events(
  id serial,
  timestamp timestamp default now(), 
  customer_id bigint,
  event_type varchar,
  country varchar,
  browser varchar,
  device_id bigint,
  session_id bigint
  );
SELECT create_distributed_table('events','customer_id');

CREATE TABLE rollup_events_5min (
 customer_id bigint,
 event_type varchar,
 country varchar,
 browser varchar,
 minute timestamp,
 event_count bigint,
 device_distinct_count hll,
 session_distinct_count hll,
 top_devices_1000 jsonb
);
CREATE UNIQUE INDEX rollup_events_5min_unique_idx ON rollup_events_5min(customer_id,event_type,country,browser,minute);
SELECT create_distributed_table('rollup_events_5min','customer_id');

CREATE TABLE rollup_events_1hr (
 customer_id bigint,
 event_type varchar,
 country varchar,
 browser varchar,
 hour timestamp,
 event_count bigint,
 device_distinct_count hll,
 session_distinct_count hll,
 top_devices_1000 jsonb
);
CREATE UNIQUE INDEX rollup_events_1hr_unique_idx ON rollup_events_1hr(customer_id,event_type,country,browser,hour);
SELECT create_distributed_table('rollup_events_1hr','customer_id');
