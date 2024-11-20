select pg_size_pretty(pg_relation_size('weather_report')) weather_report_size;

select indexname as index_name, pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
from pg_indexes
where tablename like 'weather_report%';
