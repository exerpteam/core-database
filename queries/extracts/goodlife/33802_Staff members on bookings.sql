-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            -- March  - Corona Virus
            datetolongTZ(TO_CHAR(to_date($$fromdate$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ),
            c.time_zone) AS fromDateCorona,
            datetolongTZ(TO_CHAR(to_date('2020-08-20','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ),
            c.time_zone)-1 AS toDateCorona,
            c.id           AS centerid
        FROM
            centers c
    )
SELECT
    pa.center as participant_center,
    pa.id as participant_id,
    p.center as person_center,
    p.id as person_id,
    'WEB' AS userinterface,
    FALSE as sendCancelMessage,
    b.center||'book'||b.id as bookingid,
    b.name,
    p.center ||'p'||p.id as personID,
    p.external_id as staff_personexternal,
    longtodateC(b.starttime,b.center) AS bookingStart--,E.*
FROM
    employees E
JOIN
    PARAMS
ON
    E.personcenter = PARAMS.CENTERID
JOIN
    PERSONS P
ON
    E.personcenter = P.CENTER
AND E.personid = P.ID
JOIN
    participations PA
ON
    P.CENTER = PA.participant_center
AND P.ID = PA.participant_id
and pa.state ='BOOKED'
JOIN
    BOOKINGS B
ON
    B.CENTER = PA.booking_center
AND B.ID = PA.booking_id
AND B.STATE = 'ACTIVE'
--AND B.activity IN (SELECT ID FROM ACTIVITY A WHERE A.NAME = 'Gym Floor')
WHERE
     b.center in ($$scope$$)
    and PA.start_time >=fromDateCorona
    AND E.blocked = FALSE
  --  AND P.external_id = '1028206'
  ORDER BY 11,1,10