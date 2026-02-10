-- The extract is extracted from Exerp on 2026-02-08
-- EC-7863
WITH
    params AS
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-dd')-interval '5 days', 'YYYY-MM-dd'), c.id) AS
            BIGINT) AS from_date,
            CAST(datetolongC(TO_CHAR(TO_DATE(getcentertime(c.id), 'YYYY-MM-dd'), 'YYYY-MM-dd'), c.id) AS
            BIGINT) AS to_date,
            c.id    AS center_id
        FROM
            centers c
    )
SELECT
je.id AS journalid,
curr_p.external_id AS person_id,
p.center ||'p'|| p.id AS member_id,
s.center ||'ss'|| s.id AS subscriptionID,
s.subscriptiontype_center ||'prod'|| s.subscriptiontype_id AS productid,
TO_CHAR(longtodate(je.creation_time), 'YYYY-MM-DD HH24:MI:SS') AS Termination_Cancellation_Date_Time,
s.center AS centre_id
FROM
persons p
JOIN
params pa
ON
pa.center_id = p.center
JOIN
persons curr_p
ON
curr_p.center = p.current_person_center
AND curr_p.id = p.current_person_id
JOIN
journalentries je
ON
je.person_center = p.center
AND je.person_id = p.id
AND je.jetype = 19
JOIN
subscriptions s
ON
s.center = je.ref_center
AND s.id = je.ref_id
WHERE
je.creation_time BETWEEN pa.from_date AND pa.to_date
AND p.center IN (:scope)
ORDER BY
je.creation_time