--Get me the total number of events and count of distinct devices in the last 5 minutes?

SELECT sum(event_count), hll_cardinality(sum(device_distinct_count)) FROM rollup_events_5min where minute >=now()-interval '5 minutes' AND minute <=now() AND customer_id=1;

--Get me the count of distinct sessions over the last week?

SELECT sum(event_count), hll_cardinality(sum(device_distinct_count)) FROM rollup_events_1hr where hour >=date_trunc('day',now())-interval '7 days' AND hour <=now() AND customer_id=1;

-- Get me the trend of my app usage in the last 2 days broken by hour

SELECT hour, sum(event_count) event_count, hll_cardinality(sum(device_distinct_count)) device_count, hll_cardinality(sum(session_distinct_count)) session_count FROM rollup_events_1hr where hour >=date_trunc('day',now())-interval '2 days' AND hour <=now() AND customer_id=1 GROUP BY hour;