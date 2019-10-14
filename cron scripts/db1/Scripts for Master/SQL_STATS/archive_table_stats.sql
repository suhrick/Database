use run_stats;
INSERT INTO table_statistics_history_archive SELECT * FROM table_statistics_history WHERE `RUN_DATE` < (NOW() - INTERVAL 15 DAY);
DELETE FROM table_statistics_history WHERE `RUN_DATE` < (NOW() - INTERVAL 15 DAY);
