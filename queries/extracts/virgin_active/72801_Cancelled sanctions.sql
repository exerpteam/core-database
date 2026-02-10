-- The extract is extracted from Exerp on 2026-02-08
-- EC-7653
SELECT
    TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'dd-MM-YYYY') AS From_date,
    TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD'), 'dd-MM-YYYY')   AS To_date,
    pu.misuse_state                                           AS sanction_state,
    bo.name                                                   AS class_name,
    boc.id                                                    AS class_center_id,
    boc.name                                                  AS class_center,
    longtodate(pu.target_start_time)                          AS start_time,
    p.center ||'p'|| p.id                                     AS person_id,
    p.fullname                                                AS fullname,
	ce.shortname											  AS person_center,
    pp.name                                                   AS sanction
FROM
    virginactive.privilege_usages pu
JOIN
    persons p
ON
    p.center = pu.person_center
AND p.id = pu.person_id
JOIN
    centers ce
ON
    ce.id = p.center
JOIN
    participations par
ON
    par.center = pu.target_center
AND par.id = pu.target_id
JOIN
    bookings bo
ON
    bo.center = par.booking_center
AND bo.id = par.booking_id
JOIN
    centers boc
ON
    boc.id = bo.center
JOIN
    virginactive.privilege_grants pg
ON
    pg.id = pu.grant_id
JOIN
    virginactive.privilege_punishments pp
ON
    pp.id = pg.punishment
WHERE
    pu.misuse_state = 'CANCELLED'
AND pu.state = 'CANCELLED'
AND pu.person_center IS NOT NULL
AND pu.target_start_time BETWEEN (CAST(datetolong(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'),
    'YYYY-MM-DD')) AS BIGINT)) AND (
        CAST(datetolong(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT)
        +86400000)
AND ce.id IN (:scope)