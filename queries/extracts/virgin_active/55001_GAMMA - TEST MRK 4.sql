SELECT
        'TOTALE' as Club,
        t2.*
FROM
(
         SELECT
                
                 SUM(VENDITE_TOTALI.venditeTotali) as VenditeTotali,
                 SUM(VENDITE_TOTALI.Web) as VenditeWeb,
                 SUM(VENDITE_TOTALI.NonWeb) as VenditeNonWeb
         FROM
         (
                 SELECT
                         cen.SHORTNAME,
                         1 as VenditeTotali,
                         CASE WHEN SS.EMPLOYEE_CENTER= 100 AND SS.EMPLOYEE_ID = 26801 THEN 1 else 0 END as Web,
                         CASE WHEN SS.EMPLOYEE_CENTER= 100 AND SS.EMPLOYEE_ID = 26801 THEN 0 else 1 END as NonWeb
                 FROM
                         SUBSCRIPTION_SALES SS
                 JOIN
                         SUBSCRIPTIONS SU ON SUBSCRIPTION_CENTER = SU.CENTER AND SUBSCRIPTION_ID = SU.ID
                 INNER JOIN
                         SUBSCRIPTIONTYPES ST ON SS.SUBSCRIPTION_TYPE_CENTER = ST.CENTER AND SS.SUBSCRIPTION_TYPE_ID = ST.ID
                 INNER JOIN
                         PRODUCTS PR ON SS.SUBSCRIPTION_TYPE_CENTER = PR.CENTER AND SS.SUBSCRIPTION_TYPE_ID = PR.ID
                 INNER JOIN
                         PERSONS p ON p.center = SS.OWNER_CENTER AND p.ID = ss.OWNER_ID
                 INNER JOIN
                         CENTERS cen ON cen.ID = p.CENTER AND cen.COUNTRY='IT'
                 LEFT JOIN
                         PRODUCT_GROUP prg ON prg.ID = pr.PRIMARY_PRODUCT_GROUP_ID
                 LEFT JOIN
                         SUBSCRIPTION_CHANGE sc ON sc.NEW_SUBSCRIPTION_CENTER = su.center AND sc.NEW_SUBSCRIPTION_ID = su.id AND sc.TYPE = 'EXTENSION'
                 LEFT JOIN
                         SUBSCRIPTIONS ex_s ON ex_s.center = sc.OLD_SUBSCRIPTION_CENTER AND ex_s.id = sc.OLD_SUBSCRIPTION_ID
                 LEFT JOIN
                         PRODUCTS ex_pr ON ex_pr.CENTER = ex_s.SUBSCRIPTIONTYPE_CENTER AND ex_pr.ID = ex_s.SUBSCRIPTIONTYPE_ID
                 LEFT JOIN
                         PRODUCT_AND_PRODUCT_GROUP_LINK ex_ppgl ON ex_ppgl.PRODUCT_CENTER = ex_s.SUBSCRIPTIONTYPE_CENTER AND ex_ppgl.PRODUCT_ID = ex_s.SUBSCRIPTIONTYPE_ID
                 LEFT JOIN
                         PRODUCT_GROUP ex_pg ON ex_pg.id = ex_ppgl.PRODUCT_GROUP_ID
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
                                 STATE_CHANGE_LOG scl ON scl.center = re_s.center AND scl.id = re_s.id
                         JOIN
                                 products re_pr ON re_pr.CENTER = re_s.SUBSCRIPTIONTYPE_CENTER AND re_pr.ID = re_s.SUBSCRIPTIONTYPE_ID
                         JOIN
                                 PRODUCT_AND_PRODUCT_GROUP_LINK re_ppgl ON re_ppgl.PRODUCT_CENTER = re_s.SUBSCRIPTIONTYPE_CENTER AND re_ppgl.PRODUCT_ID = re_s.SUBSCRIPTIONTYPE_ID
                         JOIN
                                 PRODUCT_GROUP re_pg ON re_pg.id = re_ppgl.PRODUCT_GROUP_ID
                         JOIN
                                 persons re_p ON re_p.center = re_s.OWNER_CENTER AND re_p.id = re_s.OWNER_ID
                         WHERE
                                 scl.ENTRY_TYPE = 2
                                 -- no subscription cancelled / regretted in the last 30 days
                                 AND scl.STATEID IN (2,3)
                                 AND scl.SUB_STATE IN (7,8)
                                 AND TRUNC(longtodate(re_s.CREATION_TIME)) < (longtodate(scl.ENTRY_START_TIME))
                         GROUP BY
                                 re_p.CURRENT_PERSON_CENTER,
                                 re_p.CURRENT_PERSON_ID,
                                 scl.ENTRY_START_TIME,
                                 re_pr.name
                         HAVING
                                 MAX(re_pg.EXCLUDE_FROM_MEMBER_COUNT) = 0
                 ) type4
                         ON type4.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
                         AND type4.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
                         AND type4.ENTRY_START_TIME BETWEEN su.CREATION_TIME - (CAST((1000*60*60) AS BIGINT)*24*30) AND su.CREATION_TIME
                 LEFT OUTER JOIN
                 (
                         SELECT
                                 s.CENTER, s.ID
                         FROM
                                 SUBSCRIPTIONS s
                         INNER JOIN
                                 CENTERS c ON c.ID = s.CENTER
                         JOIN
                                 PRODUCT_AND_PRODUCT_GROUP_LINK ppgl ON PRODUCT_CENTER = s.SUBSCRIPTIONTYPE_CENTER AND PRODUCT_ID = s.SUBSCRIPTIONTYPE_ID
                         JOIN
                                 PRODUCT_GROUP pg ON pg.id = ppgl.PRODUCT_GROUP_ID
                         WHERE
                                 pg.ID IN (4001, 4601, 5208) AND  c.COUNTRY ='IT'
                         GROUP BY
                                 s.CENTER, s.ID
                 ) spg ON SS.SUBSCRIPTION_CENTER = spg.CENTER AND SS.SUBSCRIPTION_ID = spg.ID
                 WHERE
                         SS.SALES_DATE >= trunc(current_timestamp)
                         AND ss.TYPE IN(1,2)
                         AND
                         (
                                 spg.CENTER IS NULL OR prg.id IN (5413,5414,6802)
                         )
                         --Exludung comps, operating x 2 & juniors
                         AND PRG.ID NOT IN (5405,5611,5613,5406,5407,5615)
                         -- excludes subscription sales after a regrest/cancellation unless the regretted/cancelled
                         -- subscription is an 'Exlucde from mem.count'
                         AND type4.CURRENT_PERSON_CENTER IS NULL
                         AND pr.NAME NOT LIKE 'Corporate%'
                         AND NOT EXISTS
                         (
                                 SELECT 1
                                 FROM SUBSCRIPTIONS sw
                                 JOIN STATE_CHANGE_LOG scl
                                         ON
                                           scl.ENTRY_TYPE = 2
                                           AND scl.CENTER = sw.CENTER
                                           AND scl.id = sw.ID
                                           AND scl.STATEID = 7
                                 WHERE
                                         sw.OWNER_CENTER = su.OWNER_CENTER
                                         AND sw.OWNER_ID = su.OWNER_ID
                                         AND sw.ID <> su.ID
                                         AND scl.ENTRY_START_TIME >= su.CREATION_TIME - (CAST((1000*60*60) AS BIGINT)*24*30)
                                         AND NOT EXISTS
                                         (
                                                 SELECT 1 FROM PRODUCT_AND_PRODUCT_GROUP_LINK pl
                                                 WHERE pl.PRODUCT_CENTER = sw.SUBSCRIPTIONTYPE_CENTER AND pl.PRODUCT_ID = sw.SUBSCRIPTIONTYPE_ID AND pl.PRODUCT_GROUP_ID = 4601
                                         )
                         )
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
                         ss.EMPLOYEE_CENTER,
                         ss.EMPLOYEE_ID
         ) VENDITE_TOTALI
) t2
