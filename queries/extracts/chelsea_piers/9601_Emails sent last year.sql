---emails per day, last year
WITH
        PARAMS AS
        (
           SELECT
                c.id AS CENTERID, 
                CAST (datetolongTZ (TO_CHAR ('2024-01-01 00:00:00'), c.time_zone) AS BIGINT) -1 AS FROM_DATE,
                CAST (datetolongTZ (TO_CHAR ('2024-12-31 23:59:59'), c.time_zone) AS BIGINT) AS TO_DATE
            FROM
                CENTERS c
         ) 
select 
    count(*) as count,
    to_char(longtodatec(m.earliest_delivery_time, m.center), 'yyyy-mm-dd') as earliest_delivery_date
from messages m
join params on m.center = params.centerid
where m.DELIVERYMETHOD = 1 ---1 email
and m.DELIVERYCODE = 2 ---2 email
and m.earliest_delivery_time between params.from_date and params.to_date
group by 2
order by 2