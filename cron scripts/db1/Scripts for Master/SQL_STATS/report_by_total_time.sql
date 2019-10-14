USE run_stats;
SELECT
  stop_stats.digest_text Text,
  stop_stats.count_star Executions,
  stop_stats.sum_timer_wait/ 1000000000000 Total_Time,
  (stop_stats.min_timer_wait/ 1000000000000) Fastest,
  (stop_stats.avg_timer_wait/ 1000000000000)  Avg,
  (stop_stats.max_timer_wait/ 1000000000000) Slowest,
  stop_stats.sum_rows_examined Total_Rows_Examined,
  stop_stats.sum_rows_sent Total_Rows_Returned,
  stop_stats.sum_rows_examined / stop_stats.count_star Avg_Rows_Examined,
   stop_stats.first_seen First_Seen,
   stop_stats.last_seen Last_Seen
  FROM
  stop_stats
  WHERE stop_stats.digest_text IS NOT NULL
AND stop_stats.digest_text NOT IN ('BEGIN','COMMIT')
AND stop_stats.digest_text NOT LIKE ('%tungsten%')
AND stop_stats.digest_text NOT LIKE ('%autocommit%')
AND stop_stats.digest_text <> 'SELECT ?'
AND stop_stats.digest_text NOT LIKE ('%SHOW%')
AND stop_stats.digest_text NOT LIKE ('%stop_stats%')
ORDER BY Total_Time DESC
limit 15
\G
