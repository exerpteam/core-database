-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
         t2.MEMBER_CENTER AS CENTER,
         t2.MEMBER_ID AS ID,
         t2.MEMBER_CENTER || 'p' || t2.MEMBER_ID AS PERSONKEY
 FROM
 (
         WITH PARAMS AS
         (
                 SELECT
                         extract(DAY FROM TO_DATE(GETCENTERTIME(100), 'YYYY-MM-DD HH24:MI')) AS edate
                 
         )
         SELECT
                 t1.MEMBER_CENTER,
                 t1.MEMBER_ID
         FROM
         (
                 SELECT
                         p.CENTER AS MEMBER_CENTER,
                         p.ID AS MEMBER_ID
                 FROM
                         SUBSCRIPTIONS ss
                 JOIN CENTERS cs
                 ON
                         cs.ID = ss.CENTER AND cs.COUNTRY = 'IT'
                 JOIN
                         PRODUCTS pr
                 ON
                         ss.SUBSCRIPTIONTYPE_CENTER = pr.CENTER AND ss.SUBSCRIPTIONTYPE_ID = pr.ID
                 JOIN
                         PRODUCT_AND_PRODUCT_GROUP_LINK pgl
                 ON
                         pr.ID = pgl.PRODUCT_ID AND pr.CENTER = pgl.PRODUCT_CENTER
                 JOIN
                         PERSONS p
                 ON
                         ss.OWNER_ID = p.ID AND ss.OWNER_CENTER = p.CENTER
                 WHERE
                         pgl.PRODUCT_GROUP_ID = 25601
                         AND ss.STATE = 2
                         AND p.CENTER IN (:Scope)
         )t1
         CROSS JOIN PARAMS
         WHERE
                 PARAMS.edate = 13
 )t2
