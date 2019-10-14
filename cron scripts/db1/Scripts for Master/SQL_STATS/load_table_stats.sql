use  run_stats;
insert into run_stats.table_statistics_history
select TABLE_SCHEMA,TABLE_NAME,ROWS_READ,ROWS_CHANGED,ROWS_CHANGED_X_INDEXES,now()
from information_schema.table_statistics
where (TABLE_SCHEMA = 'teladoc_eds' or TABLE_SCHEMA like 'erx%')
and TABLE_NAME not like 'tmp_%' and TABLE_NAME not like 'ALG_%';
