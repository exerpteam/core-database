 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$from_date$$                               AS from_time,
             $$to_date$$                               AS to_time,
             longtodatetz($$from_date$$,'Europe/London') AS from_date,
             longtodatetz($$to_date$$,'Europe/London') AS to_date
         
     ),
  V_EXCLUDED_SUBSCRIPTIONS AS Materialized
    (
        SELECT
            ppgl.PRODUCT_CENTER as center,
            ppgl.PRODUCT_ID as id
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = ppgl.PRODUCT_GROUP_ID
        WHERE
            pg.EXCLUDE_FROM_MEMBER_COUNT = True
    )
 SELECT
     ss.CREATOR_CENTER||'emp'||ss.CREATOR_ID                AS EMP_ID,
     staff.FIRSTNAME                                        AS EMP_FIRSTNAME ,
     staff.LASTNAME                                         AS EMP_LASTNAME ,
     ss.OWNER_CENTER                                        AS CENTER,
     cp.EXTERNAL_ID                                         AS ID,
     ss.SALES_DATE                                          AS "Sale date",
     ss.START_DATE                                          AS "Start date",
     pr.GLOBALID                                            AS "Product GlobalID",
     pr.NAME                                                AS "Product Name",
     pr.PRICE                                               AS "Price",
     CASE dms.change WHEN 8 THEN 'Transfer' ELSE 'Join' END AS "Type"
 FROM
     params,
     DAILY_MEMBER_STATUS_CHANGES dms
 JOIN
     PERSONS p1
 ON
     p1.center=dms.PERSON_CENTER
     AND p1.id = dms.PERSON_ID
 JOIN
     PERSONS cp
 ON
     p1.TRANSFERS_CURRENT_PRS_CENTER=cp.center
     AND p1.TRANSFERS_CURRENT_PRS_ID = cp.id
 LEFT JOIN
     (
         SELECT
             *
         FROM
             (
                 SELECT DISTINCT
                     p2.TRANSFERS_CURRENT_PRS_CENTER,
                     p2.TRANSFERS_CURRENT_PRS_ID,
                     s.OWNER_ID,
                     s.OWNER_CENTER,
                     s.SUBSCRIPTIONTYPE_CENTER,
                     s.SUBSCRIPTIONTYPE_ID,
                     TRUNC(longtodateC(scl.ENTRY_START_TIME,s.center)) AS SALES_DATE,
                     s.START_DATE,
                     scl.EMPLOYEE_CENTER                                                                                           AS CREATOR_CENTER,
                     scl.EMPLOYEE_ID                                                                                               AS CREATOR_ID,
                     rank() over(partition BY p2.TRANSFERS_CURRENT_PRS_CENTER, p2.TRANSFERS_CURRENT_PRS_ID,TRUNC(longtodateC(scl.ENTRY_START_TIME,s.center)) ORDER BY scl.ENTRY_START_TIME ASC) AS rnk
                 FROM
                     params,
                     SUBSCRIPTIONS s
                 JOIN
                     PERSONS p2
                 ON
                     s.OWNER_CENTER = p2.center
                     AND s.OWNER_ID = p2.id
                 JOIN
                     STATE_CHANGE_LOG scl
                 ON
                     scl.center = s.center
                     AND scl.id = s.id
                     AND scl.ENTRY_TYPE =2
                     AND scl.STATEID IN(8)
                 JOIN
                     SUBSCRIPTIONTYPES ST
                 ON
                     (
                         S.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                         AND S.SUBSCRIPTIONTYPE_ID = ST.ID
                         AND (
                             ST.CENTER, ST.ID) NOT IN
                         (
                             SELECT
                                 /*+ materialize */
                                 center,
                                 id
                             FROM
                                 V_EXCLUDED_SUBSCRIPTIONS ) )
                 WHERE
                     scl.ENTRY_START_TIME BETWEEN params.from_time AND params.to_time + 1000*60*60*24
                     AND NOT EXISTS
                     (
                         SELECT
                             1
                         FROM
                             STATE_CHANGE_LOG scl2
                         WHERE
                             scl2.ENTRY_TYPE=2
                             AND scl2.SUB_STATE IN (8,10,6)
                             AND scl2.STATEID=3
                             AND scl2.center = s.center
                             AND scl2.id = s.id
                             AND scl2.ENTRY_START_TIME BETWEEN params.from_time AND params.to_time +1000*60*60*24
                             AND TRUNC(longtodateC(scl2.ENTRY_START_TIME,scl.center))=TRUNC(longtodateC(s.CREATION_TIME,s.center)))) t1
         WHERE
             rnk=1 ) ss
 ON
     ss.TRANSFERS_CURRENT_PRS_CENTER = p1.TRANSFERS_CURRENT_PRS_CENTER
     AND ss.TRANSFERS_CURRENT_PRS_ID=p1.TRANSFERS_CURRENT_PRS_ID
     AND ss.SALES_DATE=dms.CHANGE_DATE
 LEFT JOIN
     PRODUCTS pr
 ON
     pr.center = ss.SUBSCRIPTIONTYPE_CENTER
     AND pr.id = ss.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     EMPLOYEES emp
 ON
     emp.center = ss.CREATOR_CENTER
     AND emp.id = ss.CREATOR_ID
 LEFT JOIN
     PERSONS staff
 ON
     staff.center = emp.PERSONCENTER
     AND staff.id = emp.PERSONID
 WHERE
     dms.MEMBER_NUMBER_DELTA = 1
     AND dms.ENTRY_STOP_TIME IS NULL
     AND dms.CHANGE_DATE BETWEEN params.from_date AND params.to_date
     AND dms.PERSON_CENTER IN ($$scope$$)
   --  AND cp.EXTERNAL_ID = '3361155'
