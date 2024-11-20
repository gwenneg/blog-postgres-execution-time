drop index if exists ix_btree_received_at_weather_station_id_non_covering;
create index ix_btree_received_at_weather_station_id_non_covering on weather_report using btree (received_at desc, weather_station_id);

drop index if exists ix_btree_weather_station_id_received_at_non_covering;
create index ix_btree_weather_station_id_received_at_non_covering on weather_report using btree (weather_station_id, received_at desc);

drop index if exists ix_btree_received_at_weather_station_id_covering;
create index ix_btree_received_at_weather_station_id_covering on weather_report using btree (received_at desc, weather_station_id) include (id, data);

drop index if exists ix_btree_weather_station_id_received_at_covering;
create index ix_btree_weather_station_id_received_at_covering on weather_report using btree (weather_station_id, received_at desc) include (id, data);

drop index if exists ix_brin_received_at;
create index ix_brin_received_at on weather_report using brin (received_at);
