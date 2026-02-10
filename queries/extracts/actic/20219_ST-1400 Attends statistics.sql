-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    attends_inner.center as SENTER,
    p.CENTER || 'p' || p.ID AS MEDLEMSID,
    p.FULLNAME AS MEDLEMSNAVN,
    DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    SUM(attends_inner.OnlyFitness)        AS TRENING ,
    SUM(attends_inner.OnlySwimming)       AS SVØMMING ,
    SUM(attends_inner.FitnessAndSwimming) AS TRENINGOGSVØMMING
FROM
    (
        SELECT
            att.center,
            att.PERSON_CENTER,
            att.person_id,
            TO_CHAR(longtodate(att.START_TIME), 'YYYY-MM-DD') AS AttendDate,
            CASE
                WHEN (REGEXP_COUNT(LISTAGG(br.NAME, '; ') WITHIN GROUP (ORDER BY br.NAME), 'Fitness', 1, 'i')>0
                        AND REGEXP_COUNT(LISTAGG(br.NAME, '; ') WITHIN GROUP (ORDER BY br.NAME), 'Svømming', 1, 'i')=0)
                THEN 1
                ELSE 0
            END AS OnlyFitness,
            CASE
                WHEN (REGEXP_COUNT(LISTAGG(br.NAME, '; ') WITHIN GROUP (ORDER BY br.NAME), 'Fitness', 1, 'i')=0
                        AND REGEXP_COUNT(LISTAGG(br.NAME, '; ') WITHIN GROUP (ORDER BY br.NAME), 'Svømming', 1, 'i')>0)
                THEN 1
                ELSE 0
            END AS OnlySwimming,
            CASE
                WHEN (REGEXP_COUNT(LISTAGG(br.NAME, '; ') WITHIN GROUP (ORDER BY br.NAME), 'Fitness', 1, 'i')>0
                        AND REGEXP_COUNT(LISTAGG(br.NAME, '; ') WITHIN GROUP (ORDER BY br.NAME), 'Svømming', 1, 'i')>0)
                THEN 1
                ELSE 0
            END AS FitnessAndSwimming
        FROM
            ATTENDS att
        JOIN
            BOOKING_RESOURCES br
        ON
            br.center = att.BOOKING_RESOURCE_CENTER
            AND br.id = att.BOOKING_RESOURCE_ID
        WHERE
            att.center IN ( :center )
            AND 
            att.START_TIME BETWEEN :from_date AND (
                :to_date + 86400 * 1000)
            AND att.STATE = 'ACTIVE'
        GROUP BY
            att.center,
            att.PERSON_CENTER,
            att.person_id,
            TO_CHAR(longtodate(att.START_TIME), 'YYYY-MM-DD') ) attends_inner
JOIN
    PERSONS p
ON
    p.CENTER= attends_inner.PERSON_CENTER
    AND p.id = attends_inner.person_id
GROUP BY
    attends_inner.center,
    p.CENTER,
    p.ID,
    p.PERSONTYPE,
    p.FULLNAME
ORDER BY
    attends_inner.center