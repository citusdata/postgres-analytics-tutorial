# pgopensv-analytics-tutorial
\i refresh.sql<br />
\i schema.sql<br />
\i setup\_rollup.sql<br />
\i 5minutely\_aggregation.sql<br />
\i hourly\_aggregation.sql<br />
\COPY events(customer\_id,event\_type,country,browser,device\_id,session\_id) FROM data/1.csv WITH (FORMAT CSV,HEADER TRUE);
SELECT hourly\_aggregation();
SELECT five\_minutely\_aggregation();
