# pgopensv-analytics-tutorial
\i refresh.sql
\i schema.sql
\i setup_rollup.sql
\i 5minutely_aggregation.sql
\i hourly_aggregation.sql
\COPY events(customer_id,event_type,country,browser,device_id,session_id) FROM data/1.csv WITH (FORMAT CSV,HEADER TRUE);
SELECT hourly_aggregation();
SELECT five_minutely_aggregation();
