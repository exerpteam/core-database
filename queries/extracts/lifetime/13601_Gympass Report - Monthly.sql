WITH
        PARAMS AS materialized
        (
           SELECT
                c.id AS CENTERID, 
                
                datetolongTZ (TO_CHAR (CURRENT_DATE - interval '1 month', 'YYYY-MM-DD HH24:MI:SS'), c.time_zone) -1 AS FROM_DATE,
                datetolongTZ (TO_CHAR (CURRENT_DATE, 'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS TO_DATE
            FROM
                CENTERS c
         )  

select
pa.center as center_ID,
c.name as center_name,
count (*) as participation_count, 
case pa.state when 'PARTICIPATION' then 'PARTICIPATED' else pa.state end as "participation_state / details"

---main data for report. Creator, member and time:
from participations pa
---filter to selected time and scope if needed:
join params on params.centerid = pa.center
---booking and employee data if needed:
join bookings b on pa.booking_center = b.center and pa.booking_id = b.id
--join employees emp on pa.creation_by_center = emp.personcenter and pa.creation_by_id = emp.personid
--center name:
join centers c on pa.center = c.id

where 
pa.start_time BETWEEN params.FROM_DATE AND params.TO_DATE
---- employee key: 100emp9201 --- person key: 151p84804 (GYMPASS API USER) ----
and pa.creation_by_center = 151 and pa.creation_by_id = 84804 ----LIFE TIME GYMPASS

group by 1,2,4

UNION

SELECT
        NULL,
        NULL,
        COUNT (*) AS participation_count,
        'GRAND TOTAL'
    FROM
        participations pa
    JOIN
        params ON params.centerid = pa.center
    JOIN
        bookings b ON pa.booking_center = b.center AND pa.booking_id = b.id
    JOIN
        centers c ON pa.center = c.id
    WHERE
        pa.start_time BETWEEN params.FROM_DATE AND params.TO_DATE 
        AND pa.creation_by_center = 151 AND pa.creation_by_id = 84804

UNION

SELECT
        NULL,
        NULL,
        COUNT (DISTINCT pa.center),
        'TOTAL CENTERS ALL TIME'
    FROM
        participations pa
    WHERE
        pa.creation_by_center = 151 AND pa.creation_by_id = 84804

ORDER BY 3 ASC