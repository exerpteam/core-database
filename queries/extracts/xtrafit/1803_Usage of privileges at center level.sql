-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-11707  
part 1
WITH
    PARAMS AS
    (
        SELECT
            /*+ materialize */
            c.id,
            CAST (dateToLongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS BIGINT)                  AS fromDate,
            CAST((dateToLongC(TO_CHAR(CAST(:ToDate AS DATE), 'YYYY-MM-dd HH24:MI'), c.id)+ 86400 * 1000)-1 AS BIGINT) AS toDate
        FROM
            centers c
    )




SELECT
   "Date of visits",
   "Center ID of resource",
   "Center name",
   "Resource key",
   "Resource Name",
   CAST(SUM(AllVisit) AS INTEGER) AS  "Number of visits per day",
   CAST(SUM(Basic) AS INTEGER) AS  "Nr. of visits BASIC",
   CAST(SUM(Plus) AS INTEGER) AS  "Nr. of visits PLUS",
   CAST(SUM(AllVisit-Basic-Plus) AS INTEGER) AS "Nr. of visits Other"
--   "sname",
--   "sgroup"
FROM
(
SELECT   
   TO_CHAR(longtodateTZ(a.start_TIME, 'Europe/Berlin'),'dd/MM/YYYY') AS "Date of visits",
   br.Center as "Center ID of resource",
   c.name as "Center name",
   br.center || 'br' || br.id AS "Resource key",
   br.name  AS "Resource Name",
   CASE WHEN EXISTS (SELECT 1  FROM product_and_product_group_link ppl WHERE ppl.product_center = pr.center AND ppl.product_id = pr.id AND ppl.product_group_id = 203) -- BASIC
       THEN 1 
       when exists (SELECT 1  FROM products pr3  WHERE  pr3.center = s2.subscriptiontype_center
    AND pr3.id = s2.subscriptiontype_id and s2.state = 2 and pr3.primary_product_group_id = 203 )
    THEN 1
       ELSE 0
   END AS Basic,
   CASE WHEN EXISTS (SELECT 1  FROM product_and_product_group_link ppl WHERE ppl.product_center = pr.center AND ppl.product_id = pr.id AND ppl.product_group_id = 204) -- PLUS+
       THEN 1 
       when exists (SELECT 1  FROM products pr3  WHERE  pr3.center = s2.subscriptiontype_center
    AND pr3.id = s2.subscriptiontype_id and s2.state = 2 and pr3.primary_product_group_id = 204 )
    THEN 1
    ELSE 0
  END AS Plus,
  1 AllVisit
--  pr2.name as sname,
--  pr2.primary_product_group_id as sgroup 
FROM
    PRIVILEGE_USAGES pu
JOIN
    attends a
ON
    a.center = pu.target_center
    AND a.id = pu.target_id
JOIN
            PARAMS param
        ON
            param.id = a.center

left JOIN
    subscriptions s
ON
    s.center = pu.SOUrce_center
    AND s.id = pu.source_id
left JOIN
    products pr
ON
    pr.center = s.subscriptiontype_center
    AND pr.id = s.subscriptiontype_id
left JOIN
    BOOKING_RESOURCES BR
ON
    a.BOOKING_RESOURCE_CENTER = BR.CENTER
   AND a.BOOKING_RESOURCE_ID = BR.ID
left JOIN
    centers c
ON
    c.id =br.center
LEFT JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
left JOIN
    subscriptions s2
ON
    s2.owner_center = a.PERSON_CENTER
    AND s2.owner_id = a.PERSON_ID
left JOIN
    products pr2
ON
    pr2.center = s2.subscriptiontype_center
    AND pr2.id = s2.subscriptiontype_id
    and s2.state = 2
WHERE
   pu.TARGET_SERVICE = 'Attend'
--AND pg.GRANTER_SERVICE = 'GlobalSubscription'
   AND pu.state = 'USED'
and   br.center IN (:centers)
 and ((pr2.name is not null) or (pr.name = 'Probetraining'))
   AND a.START_TIME > param.fromDate
   AND a.START_TIME < param.toDate 
	AND NOT EXISTS (SELECT 1 FROM  product_and_product_group_link ppl WHERE  ppl.product_center = pr.center AND  ppl.product_id = pr.id AND ppl.product_group_id = 605)  -- Product group MITARBEITER = 605
) t	
GROUP BY
    "Date of visits",
    "Center ID of resource",
    "Center name",
    "Resource key",
    "Resource Name"