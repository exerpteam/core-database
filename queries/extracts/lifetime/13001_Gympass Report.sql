WITH
        PARAMS AS
        (
         SELECT
                    ID                                                                                                                          AS CENTERID,
                    datetolongc (TO_CHAR (to_date (:from_date, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'), c.id)                        AS FROM_DATE,
                    datetolongc (TO_CHAR (to_date (:to_date, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'), c.id) + (24 * 3600 * 1000) - 1 AS TO_DATE
               FROM
                    CENTERS c
        )
        

select center_ID, center_name, count (*) as participation_count, participation_state
 from (
 
select
pa.center as center_ID,
case pa.state when 'PARTICIPATION' then 'PARTICIPATED' else pa.state end as participation_state,
c.name as center_name

--,
--pa.creation_by_center||'p'||pa.creation_by_id as creator_p,
--emp.center||'emp'||emp.id as creator_emp,
--pa.participant_center||'p'||pa.participant_id as participant_key,
--CASE pa.user_interface_type WHEN 0 THEN 'OTHER' WHEN 1 THEN 'CLIENT' WHEN 2 THEN 'WEB' WHEN 3 THEN 'KIOSK' WHEN 4 THEN 'SCRIPT' WHEN 5 THEN 'API' WHEN 6 THEN 'MOBILE API' ELSE 'Undefined' END AS USER_INTERFACE_TYPE,
--b.center||'book'||b.id as booking_key,
--TO_CHAR(longtodateTZ(b.starttime, c.time_zone),'MM/DD/YYYY HH24:MI')   AS "Booking start time",
--b.name as booking_name

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

and 
---- employee key: 100emp9201 --- person key: 151p84804 (GYMPASS API USER) ----
pa.creation_by_center = 151 and pa.creation_by_id = 84804


) t1
        group by center_ID, center_name, participation_state
        order by center_ID asc      
        ;