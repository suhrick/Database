USE run_stats;

SELECT digest_text Text, SUM(count_star) executions, SUM(avg_timer_wait / 1000000000000) Avg_Run_Time, SUM(sum_timer_wait / 100000000000) Time_Consumed, SUM(sum_rows_examined) Rows_Examined
FROM
        stats_history
    WHERE
        report_date BETWEEN DATE_SUB(NOW(), INTERVAL 7 DAY) AND NOW()
            AND digest_text NOT LIKE 'SHOW%'
            AND digest_text NOT LIKE 'CREATE TEMP%'
            AND digest_text NOT LIKE '%ALG%'
            AND digest_text NOT LIKE 'SET %'
            AND digest_text NOT LIKE '%xml%'
            AND digest_text NOT LIKE 'ROLLBACK%'
            AND digest_text NOT LIKE 'UNLOCK%'
            AND digest_text NOT LIKE 'COMMIT%'
            AND digest_text NOT LIKE 'EXPLAIN %'
            AND digest_text NOT LIKE 'UPDATE `pharmacy_ids`%'
            AND digest_text NOT LIKE 'USE %'
 AND digest NOT IN (
SELECT
        digest
    FROM
        stats_history
    WHERE
            report_date BETWEEN(NOW() - INTERVAL 60 DAY) AND (NOW() - INTERVAL 8 DAY)
            AND digest_text NOT LIKE 'SHOW%'
            AND digest_text NOT LIKE 'CREATE TEMP%'
            AND digest_text NOT LIKE '%ALG%'
            AND digest_text NOT LIKE 'SET %'
            AND digest_text NOT LIKE '%xml%'
            AND digest_text NOT LIKE 'ROLLBACK%'
            AND digest_text NOT LIKE 'UNLOCK%'
            AND digest_text NOT LIKE 'COMMIT%'
            AND digest_text NOT LIKE 'EXPLAIN %'
            AND digest_text NOT LIKE 'UPDATE `pharmacy_ids`%'
            AND digest_text NOT LIKE 'USE %')
 AND (count_star > 100000
      OR (sum_timer_wait / 100000000000)  > 1800
      OR sum_rows_examined > 10000000
 )
 GROUP BY digest_text
 ORDER BY SUM(sum_timer_wait / 100000000000) DESC
\G
