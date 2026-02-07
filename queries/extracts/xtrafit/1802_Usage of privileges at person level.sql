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
   a.PERSON_CENTER ||'p'||a.PERSON_ID               AS "Member Id",
   a.PERSON_CENTER as "Center ID of member",
   TO_CHAR(longtodateTZ(a.start_TIME, 'Europe/Berlin'),'dd/MM/YYYY HH24:MI')  as "Time of visit" ,
   TO_CHAR(longtodateTZ(a.stop_time, 'Europe/Berlin'),'dd/MM/YYYY HH24:MI')  AS "End of the visit",
   br.center "Resource center",
   br.center || 'br' || br.id AS "Resource key",
   br.name  AS "Resource Name",
   case
   when pr.name is not null
   then pr.name
   Else pr2.name END AS "Membership type"
 
FROM
    PRIVILEGE_USAGES pu
JOIN
    attends a
ON
    a.center = pu.target_center
    AND a.id = pu.target_id
left JOIN
    subscriptions s
ON
    s.center = pu.SOURCE_CENTER
    AND s.id = pu.SOURCE_ID
left JOIN
            PARAMS param
        ON
            param.id = a.center    
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
--	AND pg.GRANTER_SERVICE = 'GlobalSubscription'
   AND pu.state = 'USED' and
   br.center IN (:centers)
-- a.PERSON_CENTER = 230 and a.PERSON_ID  = 1896
    AND a.START_TIME >= param.fromdate
    AND a.START_TIME <param.todate
    and ((pr2.name is not null) or (pr.name = 'Probetraining'))
    AND NOT EXISTS (SELECT 1 FROM  product_and_product_group_link ppl WHERE  ppl.product_center = pr.center AND  ppl.product_id = pr.id AND ppl.product_group_id = 605)  -- Product group MITARBEITER = 605
