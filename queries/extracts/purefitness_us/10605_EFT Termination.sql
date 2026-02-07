SELECT
    p.center || 'p' || p.id AS "Member ID",
    p.external_id AS "External ID",
    p.fullname AS "Member Name",
    s.center || 'ss' || s.id AS "Subscription ID",
    prod.name AS "Product Name",
    s.subscription_price AS "Subscription Price",
    TO_CHAR(s.end_date, 'YYYY-MM-DD') AS "Subscription End Date",
    TO_CHAR(TO_TIMESTAMP(je.creation_time / 1000), 'YYYY-MM-DD HH24:MI') AS "Journal Created",
    je.text AS "Journal Text",
    'EFT subscription termination' AS "Subject",
    jrnCreator.fullname AS "Created By",
    je.creatorcenter || 'emp' || je.creatorid AS "Staff ID",
    p.center AS "Center ID",
    CASE s.state
        WHEN 2 THEN 'ACTIVE'
        WHEN 3 THEN 'ENDED'
        WHEN 4 THEN 'FROZEN'
        WHEN 7 THEN 'WINDOW'
        WHEN 8 THEN 'CREATED'
        ELSE 'Undefined'
    END AS "Subscription State"
FROM persons p
JOIN journalentries je
    ON je.person_center = p.center
   AND je.person_id = p.id
   AND je.name = 'EFT subscription termination'
   AND je.creatorcenter = 6999
   AND je.creatorid = 1
LEFT JOIN subscriptions s
    ON s.center = je.ref_center AND s.id = je.ref_id
LEFT JOIN products prod
    ON prod.center = s.subscriptiontype_center AND prod.id = s.subscriptiontype_id
LEFT JOIN employees emp
    ON emp.center = je.creatorcenter AND emp.id = je.creatorid
LEFT JOIN persons jrnCreator
    ON jrnCreator.center = emp.personcenter AND jrnCreator.id = emp.personid
WHERE p.center IN (:Scope)
  AND s.end_date >= TO_TIMESTAMP(:fromDate / 1000)::DATE
  AND s.end_date < (TO_TIMESTAMP(:toDate / 1000)::DATE + INTERVAL '1 day')
