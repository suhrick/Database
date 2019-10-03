TRUNCATE TABLE run_stats.stop_stats;

INSERT INTO run_stats.stop_stats
SELECT
  schema_name,
  digest,
  digest_text,
count_star,
sum_timer_wait,
min_timer_wait,
avg_timer_wait,
max_timer_wait,
sum_rows_examined,
sum_rows_sent,
last_seen,
first_seen
FROM
  performance_schema.`events_statements_summary_by_digest`
  WHERE digest IS NOT NULL
    AND schema_name IS NOT NULL;

INSERT INTO run_stats.`stats_history` (
  `schema_name` ,
  `digest` ,
  `digest_text` ,
  `count_star` ,
  `sum_timer_wait` ,
  `min_timer_wait` ,
  `avg_timer_wait` ,
  `max_timer_wait` ,
  `sum_rows_examined` ,
  `sum_rows_sent` ,
  `last_seen` ,
  `first_seen` )
  SELECT
  `schema_name` ,
  `digest` ,
  `digest_text` ,
  `count_star` ,
  `sum_timer_wait` ,
  `min_timer_wait` ,
  `avg_timer_wait` ,
  `max_timer_wait` ,
  `sum_rows_examined` ,
  `sum_rows_sent` ,
  `last_seen` ,
  `first_seen`
  FROM run_stats.stop_stats;
