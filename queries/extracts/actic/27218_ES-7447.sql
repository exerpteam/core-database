-- The extract is extracted from Exerp on 2026-02-08
-- Find debt collection cases with no companyID
SELECT
    p.center||'p'||p.id            AS company_id,
    ccs.NAME                       AS agency_name,
    longtodatec(ccc.START_DATETIME,ccc.center) AS debt_collect_start_date,
    ccc.AMOUNT                     AS debt_amount,
    ccc.CC_AGENCY_AMOUNT           AS debt_at_agency
FROM
    PERSONS p
JOIN
    CASHCOLLECTIONCASES ccc
ON
    ccc.PERSONCENTER = p.center
    AND ccc.PERSONID = p.id
    AND ccc.CURRENTSTEP_TYPE = 4
    AND ccc.CLOSED = 0
JOIN
    CASHCOLLECTIONSERVICES ccs
ON
    ccs.ID = ccc.CASHCOLLECTIONSERVICE
JOIN
    CASHCOLLECTION_REQUESTS ccr
ON
    ccr.center = ccc.CENTER
    AND ccr.id = ccc.id
    AND ccr.STATE = 0
WHERE
    p.ssn IS NULL
    AND ccc.CASHCOLLECTIONSERVICE IN (:cash_collection_agency)