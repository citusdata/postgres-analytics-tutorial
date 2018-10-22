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