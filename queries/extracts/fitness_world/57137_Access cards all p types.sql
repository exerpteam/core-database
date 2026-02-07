-- This is the version from 2026-02-05
--  
WITH eligibles AS
(
        SELECT
                p.CENTER, p.ID
        FROM 
                PERSONS p
        WHERE
                p.STATUS in (1,3)
                AND p.CENTER IN (:Scope)
                AND p.PERSONTYPE IN (0,1,2,3,4,5,6,7,8,9,10)
        UNION
        SELECT
                DISTINCT p.CENTER, p.ID
        FROM
                PERSONS p
        JOIN SUBSCRIPTIONS s ON p.CENTER = s.OWNER_CENTER AND p.ID = s.OWNER_ID AND s.STATE = 2
        JOIN PRODUCTS pr ON s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER AND s.SUBSCRIPTIONTYPE_ID = pr.ID
        JOIN PRODUCT_AND_PRODUCT_GROUP_LINK plink ON plink.PRODUCT_CENTER = pr.CENTER AND plink.PRODUCT_ID = pr.ID AND plink.PRODUCT_GROUP_ID = 22801
        WHERE
                p.STATUS IN (1,3)
                AND p.PERSONTYPE IN (0,1,2,3,4,5,6,7,8,9,10)
                AND p.CENTER IN (:Scope)
)
SELECT
        e.IDENTITY AS "Card number",
        TO_CHAR(longtodateC(e.START_TIME, e.REF_CENTER), 'YYYY-MM-DD') AS "Start date",
        t2.END_DATE AS "End date",
        eligibles.CENTER || 'p' || eligibles.ID AS "Exerp ID",
        DECODE(e.ENTITYSTATUS, 1, 'OK', 2, 'STOLEN', 3, 'MISSING', 4, 'BLOCKED', 5, 'BROKEN', 6, 'RETURNED', 7, 'EXPIRED', 
                               8, 'DELETED', 9, 'COMPROMISED', 10, 'FORGOTTEN', 11, 'BANNED', 'UNKNOWN') AS "Status",
        DECODE(p.PERSONTYPE,2,'Staff',10,'External staff','Unknown') AS "Staff type"
FROM eligibles
JOIN FW.PERSONS p ON eligibles.CENTER = p.CENTER AND eligibles.ID = p.ID
JOIN ENTITYIDENTIFIERS e ON eligibles.CENTER = e.REF_CENTER AND eligibles.ID = e.REF_ID AND e.IDMETHOD = 4 AND e.ENTITYSTATUS = 1
LEFT JOIN
(
        SELECT
                t3.OWNER_CENTER,
                t3.OWNER_ID,
                TO_CHAR(t3.END_DATE, 'YYYY-MM-DD') as END_DATE
        FROM
        (
                SELECT
                        s.OWNER_CENTER,
                        s.OWNER_ID,
                        s.END_DATE,
                        rank() over (partition by t1.CENTER, t1.ID ORDER BY s.END_dATE,s.CREATION_TIME DESC) ranking
                FROM
                (
                        SELECT
                                p.CENTER, p.ID
                        FROM 
                                PERSONS p
                        WHERE
                                p.STATUS = 1
                                AND p.PERSONTYPE IN (2,10)
                                AND p.CENTER IN (:Scope)         
                        UNION
                        SELECT
                                DISTINCT p.CENTER, p.ID
                        FROM
                                PERSONS p
                        JOIN SUBSCRIPTIONS s ON p.CENTER = s.OWNER_CENTER AND p.ID = s.OWNER_ID AND s.STATE = 2
                        JOIN PRODUCTS pr ON s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER AND s.SUBSCRIPTIONTYPE_ID = pr.ID
                        JOIN PRODUCT_AND_PRODUCT_GROUP_LINK plink ON plink.PRODUCT_CENTER = pr.CENTER AND plink.PRODUCT_ID = pr.ID AND plink.PRODUCT_GROUP_ID = 22801
                        WHERE
                                p.STATUS = 1
                                AND p.PERSONTYPE IN (2,10)
                                AND p.CENTER IN (:Scope)
                ) t1
                JOIN SUBSCRIPTIONS s ON t1.CENTER = s.OWNER_CENTER AND t1.ID = s.OWNER_ID AND s.STATE IN (2,4,8)
        ) t3 WHERE t3.ranking = 1
) t2 ON eligibles.CENTER = t2.OWNER_CENTER AND eligibles.ID = t2.OWNER_ID
