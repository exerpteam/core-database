WITH params AS MATERIALIZED
(
        SELECT
            c.id AS CENTERID,
            
            datetolongc(TO_CHAR(to_date($$start_date$$, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) AS fromDate,
            datetolongc(TO_CHAR(to_date($$to_date$$, 'YYYY-MM-DD HH24:MI:SS'),
            'YYYY-MM-DD HH24:MI:SS'), c.id) + (24*3600*1000) - 1 AS toDate
        FROM
            centers c
)
SELECT
    p.external_id                                                                          AS "External Id",
    p.center || 'p' || p.id                                                                AS "Person Id",
    s.CENTER || 'ss' || s.ID                                                               AS "Subscription Id",
    prod.name                                                                              AS "Product Name",
    s.subscription_price                                                                   AS "Subscription Price",
    TO_CHAR(s.end_date, 'YYYY-MM-DD')                                                      AS "Subscription End Date",
    TO_CHAR(longtodatec(je.creation_time, je.person_center), 'YYYY-MM-DD HH24:MI')         AS "Created Date",
    p.center                                                                               AS "Center Id",
    p.FULLNAME                                                                             AS "Person Name",
CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE,
    'Direct Debit subscription termination'                                                AS "Subject",
    staff.fullname                                                                        AS "Created By"
FROM persons p
JOIN params
    ON params.centerid = p.center
JOIN subscriptions s
        ON s.owner_center = p.center
        AND s.owner_id = p.id
JOIN products prod
        ON prod.center = s.subscriptiontype_center
        AND prod.id = s.subscriptiontype_id
JOIN journalentries je
        ON je.person_center = p.center
        AND je.person_id = p.id
        AND je.ref_center = s.center
        AND je.ref_id = s.id
        AND je.name = 'EFT subscription termination'
LEFT JOIN employees emp
        ON je.creatorcenter = emp.center
        AND je.creatorid = emp.id
LEFT JOIN persons staff
        ON staff.center = emp.personcenter
        AND staff.id = emp.personid
WHERE
    p.center IN ($$Scope$$)
    AND je.creation_time BETWEEN params.fromDate AND params.toDate