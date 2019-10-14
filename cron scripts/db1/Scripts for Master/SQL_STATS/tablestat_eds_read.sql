use run_stats;
SELECT
table_name,
FORMAT(Read_Last_Week,0) AS `Rows Read 7 Days Ago`,
FORMAT(Read_This_Week,0) AS `Rows Read Yesterday`,
`%_Increase_Rows_Read`,
FORMAT(Changed_Last_Week,0) AS `Rows Changed 7 Days Ago`,
FORMAT(Changed_This_Week,0) AS `Rows Changed Yesterday`,
`%_Increase_Rows_Changed`
FROM table_stats_changed_report
where table_schema = 'teladoc_eds'
ORDER BY Read_This_Week DESC LIMIT 20;
