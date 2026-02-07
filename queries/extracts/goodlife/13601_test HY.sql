WITH
    params AS materialized
    (
        SELECT
            id                                                                     AS center,
            cast(datetolongc(TO_CHAR(to_date(:From_Date,'YYYY-MM-DD'),'YYYY-MM-DD'),id) AS bigint)    AS from_Date,
            cast(datetolongc(TO_CHAR(to_date(:To_Date,'YYYY-MM-DD'),'YYYY-MM-DD'),id) AS BIGINT) + 24*3600*1000 AS
            to_date
        FROM
            centers
    )
SELECT DISTINCT
    s.center,
    s.id,
    p.firstname,
    p.lastname,
    TO_CHAR(longtodateC(je.creation_time, p.center),'YYYY-MM-DD')  AS "Contract Created Date",
    TO_CHAR(longtodateC(si.creation_time, si.center),'YYYY-MM-DD') AS "Signature Date"
FROM
    params,
    journalentries je
JOIN
    journalentry_signatures jes
ON
    je.id = jes.journalentry_id
JOIN
    signatures si
ON
    jes.signature_center = si.center
AND jes.signature_id = si.ID
JOIN
    subscriptions s
ON
    je.ref_center = s.center
AND je.ref_id = s.id
JOIN
    persons p
ON
    s.owner_center = p.center
AND s.owner_id = p.id
WHERE
    je.jetype = 1 -- Contracts
AND LENGTH(si.signature_image_data) < 650
AND s.CENTER IN (:Scope)
AND je.creatorcenter = params.center
AND je.creation_time >= params.from_date
AND je.creation_time < params.to_date