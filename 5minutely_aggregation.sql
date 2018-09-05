CREATE OR REPLACE FUNCTION five_minutely_aggregation(OUT start_id bigint, OUT end_id bigint)
RETURNS record
LANGUAGE plpgsql
AS $function$
BEGIN
    /* determine which page views we can safely aggregate */
    SELECT window_start, window_end INTO start_id, end_id
    FROM incremental_rollup_window('rollup_events_5min');

    /* exit early if there are no new page views to aggregate */
    IF start_id > end_id THEN RETURN; END IF;

    /* aggregate the page views, merge results if the entry already exists */
    INSERT INTO rollup_events_5min
        SELECT customer_id,
                event_type,
                country,
                browser,
                date_trunc('seconds', (event_time - TIMESTAMP 'epoch') / 300) * 300 + TIMESTAMP 'epoch' AS minute,
                count(*) as event_count,
                hll_add_agg(hll_hash_bigint(device_id)) as device_distinct_count,
                hll_add_agg(hll_hash_bigint(session_id)) as session_distinct_count,
                topn_add_agg(device_id::text) top_devices_1000
        FROM events WHERE event_id BETWEEN start_id AND end_id
        GROUP BY customer_id,event_type,country,browser,minute
        ON CONFLICT (customer_id,event_type,country,browser,minute)
        DO UPDATE
        SET event_count=excluded.event_count,
            device_distinct_count = excluded.device_distinct_count,
            session_distinct_count= excluded.session_distinct_count;

END;
$function$;
