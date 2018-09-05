CREATE TABLE rollups (
    name text primary key,
    event_table_name text not null,
    event_id_sequence_name text not null,
    last_aggregated_id bigint default 0
);

CREATE OR REPLACE FUNCTION incremental_rollup_window(rollup_name text, OUT window_start bigint, OUT window_end bigint)
RETURNS record
LANGUAGE plpgsql
AS $function$
DECLARE
    table_to_lock regclass;
BEGIN
    /*
     * Perform aggregation from the last aggregated ID + 1 up to the last committed ID.
     * We do a SELECT .. FOR UPDATE on the row in the rollup table to prevent
     * aggregations from running concurrently.
     */
    SELECT event_table_name, last_aggregated_id+1, pg_sequence_last_value(event_id_sequence_name)
    INTO table_to_lock, window_start, window_end
    FROM rollups
    WHERE name = rollup_name FOR UPDATE;

    IF NOT FOUND THEN
        RAISE 'rollup ''%'' is not in the rollups table', rollup_name;
    END IF;

    IF window_end IS NULL THEN
        /* sequence was never used */
        window_end := 0;
        RETURN;
    END IF;

    /*
     * Play a little trick: We very briefly lock the table for writes in order to
     * wait for all pending writes to finish. That way, we are sure that there are
     * no more uncommitted writes with a identifier lower or equal to window_end.
     * By throwing an exception, we release the lock immediately after obtaining it
     * such that writes can resume.
     */
    BEGIN
        EXECUTE format('LOCK %s IN EXCLUSIVE MODE', table_to_lock);
        RAISE 'release table lock';
    EXCEPTION WHEN OTHERS THEN
    END;

    /*
     * Remember the end of the window to continue from there next time.
     */
    UPDATE rollups SET last_aggregated_id = window_end WHERE name = rollup_name;
END;
$function$;

-- Entries for the rollup tables so that they are getting tracked in incremental rollup process.
INSERT INTO rollups (name, event_table_name, event_id_sequence_name)
VALUES ('rollup_events_5min', 'events','events_event_id_seq');

INSERT INTO rollups (name, event_table_name, event_id_sequence_name)
VALUES ('rollup_events_1hr', 'events','events_event_id_seq');
