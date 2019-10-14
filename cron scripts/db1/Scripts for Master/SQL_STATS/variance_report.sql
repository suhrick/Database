use run_stats;

SELECT
SUBSTRING(digest_text,1,90) 'TEXT',
current_runtime 'AVG RUNTIME,CURR',
past_runtime 'AVG RUNTIME,PAST',
round(total_current_runtime) 'TOTAL RUNTIME,CURR',
round(total_past_runtime) 'TOTAL RUNTIME,PAST',
current_executions '# EXECUTIONS, CURR',
past_executions  '# EXECUTIONS, PAST',
round(relative_diff,1) 'RELATIVE DIFF'
FROM run_stats.historical_runtimes
LIMIT 20 ;
