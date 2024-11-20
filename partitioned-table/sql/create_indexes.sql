drop index if exists ix_btree_weather_station_id_received_at_covering;
create index ix_btree_weather_station_id_received_at_covering on weather_report using btree (weather_station_id, received_at desc) include (id, data);
