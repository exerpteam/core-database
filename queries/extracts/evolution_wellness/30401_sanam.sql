-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
            c.id AS CENTER_ID,
            CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
        FROM
            centers c
    )
        SELECT
            ck.person_center||'p'||ck.person_id,
            TO_CHAR(longtodatec(ck.checkin_time, ck.person_center), 'DD-MM-YYYY HH24:MI:SS') AS "Check-In Date/Time",
            aia.txtvalue
        FROM
            checkins ck
        JOIN
            params p
            ON p.CENTER_ID = ck.person_center
        LEFT JOIN
            person_ext_attrs aia
            ON aia.personcenter = ck.person_center
            AND aia.personid = ck.person_id
            AND aia.name IN ('VitalityCheckinMY','VitalityCheckin','VitalityCheckinID','VitalityCheckinTH')                    
        WHERE
            ck.checkin_time BETWEEN p.FromDate AND p.ToDate
            AND
            aia.txtvalue IS NOT NULL
   
