-- The extract is extracted from Exerp on 2026-02-08
--  
WITH LIST_CENTERS AS Materialized
(
	SELECT 
		c.ID AS CENTERID,
		CAST(:OpeningDate AS DATE) AS Opening
	FROM CENTERS c
	WHERE
		CAST(c.ID AS VARCHAR) IN (:Scope)
)
SELECT
    c.id                                                        AS CenterId,
    c.shortname                                                 AS CenterName,
    p.center || 'p' || p.id                                     AS MembershipNumber,
    p.external_id                                               AS MemberExternalId,
    s.center || 'ss' || s.id                                    AS SubscriptionId,
    prod.name                                                   AS SubscriptionName,
    s.start_date                                                AS SubscriptionStartDate,
    s.end_date                                                  AS SubscriptionEndDate,
    CASE st.ST_TYPE WHEN 0 THEN 'Cash' WHEN 1 THEN 'EFT' WHEN 2 THEN 'Clipcard' WHEN 3 THEN 'Course' END AS SubscriptionType,
    srd.start_date                                              AS "Start date free period",
    srd.end_date                                                AS "End date free perod",
    srd.text                                                    AS "Free reason",
    s.billed_until_date                                         AS "Billed until date",
    CASE
        WHEN spa.id IS NOT NULL
        THEN spa.individual_deduction_day
        WHEN rpa.id IS NOT NULL
        THEN rpa.individual_deduction_day
        WHEN pag.id IS NOT NULL
        THEN pag.individual_deduction_day
    END             AS "Deduction day",
    pehome.txtvalue AS PGT,
    s.CENTER,
    s.ID,
    srd.ID AS FP_KEY,
    TO_CHAR(lc.Opening - 1,'YYYY-MM-DD') AS NEW_FREE_STOP_DATE
FROM
    persons p
JOIN LIST_CENTERS lc ON p.CENTER = lc.CENTERID
JOIN
    centers c
ON
    c.id = p.center
JOIN
    subscriptions s
ON
    s.owner_center = p.center
    AND s.owner_id = p.id
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
	AND st.st_type > 0 -- Except CASH
JOIN
    products prod
ON
    prod.center = st.center
    AND prod.id = st.id
JOIN
    subscription_reduced_period srd
ON
    srd.subscription_center = s.center
    AND srd.subscription_id = s.id
    AND srd.state = 'ACTIVE'
    AND srd.type = 'FREE_ASSIGNMENT'
    AND srd.end_date >= lc.Opening
LEFT JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
    AND ar.customerid = p.id
    AND ar.ar_type = 4
LEFT JOIN
    PAYMENT_ACCOUNTS pa
ON
    pa.center = ar.center
    AND pa.id = ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pag
ON
    pag.CENTER = pa.ACTIVE_AGR_center
    AND pag.ID = pa.ACTIVE_AGR_id
    AND pag.SUBID = pa.ACTIVE_AGR_SUBID
LEFT JOIN
    relatives r
ON
    r.relativecenter = s.owner_center
    AND r.relativeid = s.owner_id
    AND r.rtype = 12
    AND r.status = 1
LEFT JOIN
    account_receivables rar
ON
    rar.customercenter = r.center
    AND rar.customerid = r.id
    AND rar.ar_type = 4
LEFT JOIN
    payment_accounts rpac
ON
    rpac.center = rar.center
    AND rpac.id = rar.id
LEFT JOIN
    payment_agreements rpa
ON
    rpa.center = rpac.active_agr_center
    AND rpa.id = rpac.active_agr_id
    AND rpa.subid = rpac.active_agr_subid
LEFT JOIN
    payment_agreements spa
ON
    spa.center = s.payment_agreement_center
    AND spa.id = s.payment_agreement_id
    AND spa.subid = s.payment_agreement_subid
LEFT JOIN
    person_ext_attrs pehome
ON
    pehome.personcenter = p.center
    AND pehome.personid = p.id
    AND pehome.name = 'PUREGYMATHOME'
WHERE
    p.persontype = 2  -- exclude staff
	AND 
    (
		:skipCommentList = True
		OR
	    srd.TEXT IN (:CommentList)
     )