CREATE TABLE events(
  event_id serial,
  event_time timestamptz default now(), 
  customer_id bigint,
  event_type text,
  country text,
  browser text,
  device_id bigint,
  session_id bigint
)
PARTITION BY RANGE (event_time);

--Create 5-minutes partitions
SELECT partman.create_parent('public.events', 'event_time', 'native', '5 minutes');
UPDATE partman.part_config SET infinite_time_partitions = true;

SELECT create_distributed_table('events','customer_id');

CREATE TABLE rollup_events_5min (
 customer_id bigint,
 event_type text,
 country text,
 browser text,
 minute timestamptz,
 event_count bigint,
 device_distinct_count hll,
 session_distinct_count hll,
 top_devices_1000 jsonb
);
CREATE UNIQUE INDEX rollup_events_5min_unique_idx ON rollup_events_5min(customer_id,event_type,country,browser,minute);
SELECT create_distributed_table('rollup_events_5min','customer_id');

CREATE TABLE rollup_events_1hr (
 customer_id bigint,
 event_type text,
 country text,
 browser text,
 hour timestamptz,
 event_count bigint,
 device_distinct_count hll,
 session_distinct_count hll,
 top_devices_1000 jsonb
);
CREATE UNIQUE INDEX rollup_events_1hr_unique_idx ON rollup_events_1hr(customer_id,event_type,country,browser,hour);
SELECT create_distributed_table('rollup_events_1hr','customer_id');
