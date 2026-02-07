 SELECT
     cen.SHORTNAME,
     SS.SALES_DATE,
     p.CENTER || 'p' || p.ID                              personId,
     SS.SUBSCRIPTION_CENTER || 'ss' || SS.SUBSCRIPTION_ID subId,
     p.FULLNAME,
     pr.NAME  "subscription",
     prg.NAME productGroup,
     CASE
         WHEN MAX(ex_pg.EXCLUDE_FROM_MEMBER_COUNT) = 1
             AND ss.TYPE = 2 -- extended and FROM COMP
             and type4.CURRENT_PERSON_CENTER is null -- Did not have previous normal membership
         THEN 'SALE' -- count as SALE
         WHEN MAX(ex_pg.EXCLUDE_FROM_MEMBER_COUNT) = 1
             AND ss.TYPE = 2 -- extended and FROM COMP
             and type4.CURRENT_PERSON_CENTER is not null -- Did have previous normal membership
         THEN 'Previous Normal Membership End' -- count as type4
         WHEN MAX(ex_pg.EXCLUDE_FROM_MEMBER_COUNT) = 0
             AND ss.TYPE = 2 -- extended and FROM NORMAL
         THEN 'Extension' -- Extended from Full membership, count as Extension
         WHEN type4.CURRENT_PERSON_CENTER IS NOT NULL
         THEN 'Previous Normal Membership End'
         ELSE CASE SS.TYPE  WHEN 1 THEN  'Sale'  WHEN 2 THEN  'Extension'  WHEN 3 THEN  'Change'  WHEN 4 THEN  'Previous Membership Ended' END
     END                                      AS saleType,
     ex_pr.name                               AS extended_From,
     type4.name                               AS "ended sub",
     longtodateC(SU.CREATION_TIME, SU.CENTER) AS created,
 CASE WHEN ss.EMPLOYEE_CENTER = 100 AND ss.EMPLOYEE_ID = 3202 THEN 1 ELSE 0 END as apiGamma
 FROM
     SUBSCRIPTION_SALES SS
 JOIN
     SUBSCRIPTIONS SU
 ON
     SUBSCRIPTION_CENTER = SU.CENTER
     AND SUBSCRIPTION_ID = SU.ID
 INNER JOIN
     SUBSCRIPTIONTYPES ST
 ON
     (
         SS.SUBSCRIPTION_TYPE_CENTER = ST.CENTER
         AND SS.SUBSCRIPTION_TYPE_ID = ST.ID)
 INNER JOIN
     PRODUCTS PR
 ON
     (
         SS.SUBSCRIPTION_TYPE_CENTER = PR.CENTER
         AND SS.SUBSCRIPTION_TYPE_ID = PR.ID)
 INNER JOIN
     PERSONS p
 ON
     p.center = SS.OWNER_CENTER
     AND p.ID = ss.OWNER_ID
 INNER JOIN
     CENTERS cen
 ON
     cen.ID = p.CENTER
 LEFT JOIN
     PRODUCT_GROUP prg
 ON
     prg.ID = pr.PRIMARY_PRODUCT_GROUP_ID
 LEFT JOIN
     SUBSCRIPTION_CHANGE sc
 ON
     sc.NEW_SUBSCRIPTION_CENTER = su.center
     AND sc.NEW_SUBSCRIPTION_ID = su.id
     AND sc.TYPE = 'EXTENSION'
 LEFT JOIN
     SUBSCRIPTIONS ex_s
 ON
     ex_s.center = sc.OLD_SUBSCRIPTION_CENTER
     AND ex_s.id = sc.OLD_SUBSCRIPTION_ID
 LEFT JOIN
     PRODUCTS ex_pr
 ON
     ex_pr.CENTER = ex_s.SUBSCRIPTIONTYPE_CENTER
     AND ex_pr.ID = ex_s.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK ex_ppgl
 ON
     ex_ppgl.PRODUCT_CENTER = ex_s.SUBSCRIPTIONTYPE_CENTER
     AND ex_ppgl.PRODUCT_ID = ex_s.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     PRODUCT_GROUP ex_pg
 ON
     ex_pg.id = ex_ppgl.PRODUCT_GROUP_ID
 LEFT JOIN
     (
         SELECT
             re_p.CURRENT_PERSON_CENTER,
             re_p.CURRENT_PERSON_ID,
             scl.ENTRY_START_TIME,
             re_pr.name
         FROM
             subscriptions re_s
         JOIN
             STATE_CHANGE_LOG scl
         ON
             scl.center = re_s.center
             AND scl.id = re_s.id
         JOIN
             products re_pr
         ON
             re_pr.CENTER = re_s.SUBSCRIPTIONTYPE_CENTER
             AND re_pr.ID = re_s.SUBSCRIPTIONTYPE_ID
         JOIN
             PRODUCT_AND_PRODUCT_GROUP_LINK re_ppgl
         ON
             re_ppgl.PRODUCT_CENTER = re_s.SUBSCRIPTIONTYPE_CENTER
             AND re_ppgl.PRODUCT_ID = re_s.SUBSCRIPTIONTYPE_ID
         JOIN
             PRODUCT_GROUP re_pg
         ON
             re_pg.id = re_ppgl.PRODUCT_GROUP_ID
         JOIN
             persons re_p
         ON
             re_p.center = re_s.OWNER_CENTER
             AND re_p.id = re_s.OWNER_ID
         WHERE
             scl.ENTRY_TYPE = 2
             -- no subscription cancelled / regretted in the last 30 days
             AND scl.STATEID IN (2,3)
             AND scl.SUB_STATE IN (7,8)
             --AND re_s.CREATION_TIME +1000*60*60*24 < scl.ENTRY_START_TIME
             AND TRUNC(longtodate(re_s.CREATION_TIME)) < (longtodate(scl.ENTRY_START_TIME))
         GROUP BY
             re_p.CURRENT_PERSON_CENTER,
             re_p.CURRENT_PERSON_ID,
             scl.ENTRY_START_TIME,
             re_pr.name
         HAVING
             MAX(re_pg.EXCLUDE_FROM_MEMBER_COUNT) = 0 ) type4
 ON
     type4.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
     AND type4.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
     AND type4.ENTRY_START_TIME BETWEEN su.CREATION_TIME - 1000*60*60*24*30 AND su.CREATION_TIME
 WHERE
         SS.SUBSCRIPTION_CENTER IN ($$Scope$$)
         AND LongToDate(SU.CREATION_TIME) >= trunc(current_timestamp) - (CAST(to_char(current_timestamp,'DD') AS INT) - 1)
     /*p.center = 104
     AND p.id = 31801*/
     --Exludung comps, operating x 2 & juniors
     AND PRG.ID NOT IN (5405,5611,5613,5406,5407,5615)
 AND pr.NAME NOT LIKE 'Corporate%'
     -- excludes subscription sales after a regrest/cancellation unless the regretted/cancelled subscription is an 'Exlucde from mem.count'
 GROUP BY
     cen.ID,
     cen.SHORTNAME,
     SS.SALES_DATE,
     p.CENTER,
     p.ID ,
     SS.SUBSCRIPTION_CENTER,
     SS.SUBSCRIPTION_ID ,
     p.FULLNAME,
     pr.NAME ,
     prg.NAME ,
     SS.TYPE ,
     ex_pr.name,
     longtodateC(SU.CREATION_TIME, SU.CENTER),
     type4.CURRENT_PERSON_CENTER,
     type4.name,
 CASE WHEN ss.EMPLOYEE_CENTER = 100 AND ss.EMPLOYEE_ID = 3202 THEN 1 ELSE 0 END
 ORDER BY
     cen.ID,
     SS.SALES_DATE
