WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )
SELECT 
    p.center ||'p'|| p.id AS "Person ID",
    p.external_id AS "External ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    referrer_ext_id.txtvalue AS "Referrer External ID",
    COALESCE(referrer_person.firstname || ' ' || referrer_person.lastname, '') AS "Referred by",
    prod.name AS "Subscription Name",
    CAST(longtodateC(s.creation_time, s.center) AS DATE) AS "Subscription Sale Date",
    CASE
        WHEN p.status=0 THEN 'Lead'
        WHEN p.status=1 THEN 'Active'
        WHEN p.status=2 THEN 'Inactive'
        WHEN p.status=3 THEN 'Temporary Inactive'
        WHEN p.status=6 THEN 'Prospect'
        ELSE 'Other'
    END AS "Person Status"
FROM 
    persons p
JOIN
    params 
    ON params.CENTER_ID = p.center
-- MUST have Referrer External ID
JOIN 
    person_ext_attrs referrer_ext_id
    ON referrer_ext_id.personcenter = p.center
    AND referrer_ext_id.personid = p.id
    AND referrer_ext_id.name = 'ReferrersExternalID'
    AND referrer_ext_id.txtvalue IS NOT NULL
    AND referrer_ext_id.txtvalue != ''
-- Find the referrer person
LEFT JOIN 
    persons referrer_person
    ON referrer_person.external_id = referrer_ext_id.txtvalue
    AND referrer_person.center = p.center
-- Join to subscriptions (this ensures they converted)
JOIN
    subscriptions s
    ON s.owner_center = p.center
    AND s.owner_id = p.id
    AND s.creation_time BETWEEN params.FromDate AND params.ToDate
    AND s.state NOT IN (5, 7, 8) -- Exclude deleted, window, created
-- Join to product to get subscription name
JOIN
    products prod
    ON prod.center = s.subscriptiontype_center
    AND prod.id = s.subscriptiontype_id
WHERE 
    p.center IN (:Scope)
    -- Exclude trial and free products
    AND NOT (LOWER(prod.name) LIKE '%trial%' 
             OR LOWER(prod.name) LIKE '%comp%'
             OR LOWER(prod.name) LIKE '%free%')
    -- Exclude Squad Goals Referral Day Pass
    AND prod.name != 'Squad Goals Referral Day Pass'
ORDER BY 
    s.creation_time DESC, p.lastname, p.firstname