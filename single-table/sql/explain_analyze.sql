--explain analyze
--select wr.id, wr.data, wr.received_at
--from weather_report wr join weather_station ws on wr.weather_station_id = ws.id
--where ws.name = 'weather-station-17' and wr.received_at >= '2025-03-06'
--order by wr.received_at desc
--offset 800 limit 100;

--explain analyze
--select wr.id, wr.data, wr.received_at
--from weather_report wr
--where wr.received_at >= '2025-03-06'
--and exists(
--    select 1
--    from weather_station ws
--    where wr.weather_station_id = ws.id and ws.name = 'weather-station-17'
--)
--order by wr.received_at desc
--offset 800 limit 100;

explain analyze
select wr.id, wr.data, wr.received_at
from weather_report wr
where wr.received_at >= '2025-03-06'
and wr.weather_station_id = (
    select id
    from weather_station
    where name = 'weather-station-17'
)
order by wr.received_at desc
offset 800 limit 100;

--explain analyze
--select count(wr.id)
--from weather_report wr join weather_station ws on wr.weather_station_id = ws.id
--where ws.name = 'weather-station-17' and wr.received_at >= '2025-03-06';

--explain analyze
--select count(*)
--from weather_report wr
--where wr.received_at >= '2025-03-06'
--and exists(
--    select 1
--    from weather_station ws
--    where wr.weather_station_id = ws.id and ws.name = 'weather-station-17'
--);

explain analyze
select count(*)
from weather_report wr
where wr.received_at >= '2025-03-06'
and wr.weather_station_id = (
    select id
    from weather_station
    where name = 'weather-station-17'
);
