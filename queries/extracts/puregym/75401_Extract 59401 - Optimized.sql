-- The extract is extracted from Exerp on 2026-02-08
-- 		
 WITH
     params AS MATERIALIZED
     (
         SELECT
             $$FromDate$$                                                                                 AS FromDate,
             $$ToDate$$                                                                                 AS ToDate,
             datetolongTZ(TO_CHAR($$FromDate$$, 'YYYY-MM-dd HH24:MI'), 'Europe/London')                   AS FromDateLong,
             (datetolongTZ(TO_CHAR($$ToDate$$, 'YYYY-MM-dd HH24:MI'), 'Europe/London')+ 86400 * 1000)-1 AS ToDateLong
         
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
     CASE  s.state  WHEN 2 THEN 'Active'  WHEN 3 THEN 'Ended'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'Window'  WHEN 8 THEN 'Created' ELSE 'Unknown' END AS "Subscription State" ,
     'Direct Debit subscription termination'                                                AS "Subject",
     'API Southampton'                                                                      AS "Created By"
 FROM
     persons p
 CROSS JOIN
     params
 JOIN
     subscriptions s
 ON
     s.OWNER_CENTER = p.CENTER
     AND s.OWNER_ID = p.ID
     AND p.center IN ($$Scope$$)
 JOIN
     products prod
 ON
     prod.center = s.subscriptiontype_center
     AND prod.id = s.subscriptiontype_id
 JOIN
     journalentries je
 ON
     je.person_center = p.center
     AND je.person_id = p.id
     AND je.ref_center = s.center
     AND je.ref_id = s.id
     AND je.creatorcenter = 100
     AND je.creatorid = 17401
     AND je.name = 'Direct Debit subscription termination'
     AND je.last_modified >= params.FromDateLong
     AND je.jetype = 18
