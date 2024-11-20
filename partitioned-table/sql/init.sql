-- Uncomment the line below to disable parallel workers. See https://www.postgresql.org/docs/current/runtime-config-resource.html#GUC-MAX-PARALLEL-WORKERS-PER-GATHER for more details.
-- set max_parallel_workers_per_gather = 0;

create table weather_station (
    id uuid not null default gen_random_uuid(),
    name text not null,
    constraint pk_weather_station primary key (id),
    constraint uq_weather_station_name unique (name)
);

create table weather_report (
    id uuid not null default gen_random_uuid(),
    data text not null,
    received_at timestamp not null,
    weather_station_id uuid not null,
    constraint fk_weather_report_weather_station foreign key (weather_station_id) references weather_station (id)
) partition by range (received_at);

create procedure init(
    weather_stations integer,
    days_to_insert integer,
    daily_weather_report_records integer,
    retention_delay integer
) language plpgsql as $$
declare
    oldest_partition text;
    generated_date date;
    new_partition text;
begin

    raise info 'Bootstrapping the database...';

    insert into weather_station (name)
    select 'weather-station-' || i
    from generate_series(1, weather_stations) as i;
    raise info 'Inserted % weather_station records', weather_stations;

    raise info 'Inserting weather_report records for % days with a retention delay of % days...', days_to_insert, retention_delay;
    for i in 1..days_to_insert loop

        if i > retention_delay then
            select min(tablename)
            from pg_tables
            where schemaname = 'public' and tablename like 'weather_report_%'
            into oldest_partition;
            execute format('drop table %s', oldest_partition);
            raise info 'Dropped partition %', oldest_partition;
        end if;

        generated_date := current_date - (days_to_insert - i);
        new_partition := 'weather_report_' || replace(generated_date::text, '-', '_');
        execute format(
            'create table %s partition of weather_report for values from (%L) to (%L);',
            new_partition,
            generated_date::text,
            (generated_date + 1)::text
        );
        raise info 'Created partition %', new_partition;

        with ranked_weather_stations as (
            select id, rank() over (order by name) as rank
            from weather_station
        )
        insert into weather_report (data, received_at, weather_station_id)
        select
            md5(random()::text),
            clock_timestamp() - (days_to_insert - i || ' days')::interval,
            (select id from ranked_weather_stations where rank = j % weather_stations + 1)
        from generate_series(1, daily_weather_report_records) as j;
        raise info 'Day % - Inserted weather_report records', i;

    end loop;
    raise info 'Done inserting all weather_report records';

    raise info 'Done bootstrapping the database';

end;
$$;

call init(100, 60, 1000000, 30);

create function check_weather_report_unique_id()
    returns trigger as $$
begin
    if exists (select 1 from weather_report where id = new.id) then
        raise exception 'Duplicate weather_report id: %', new.id;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger weather_report_unique_id
before insert on weather_report
for each row execute function check_weather_report_unique_id();
