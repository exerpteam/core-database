-- This is the version from 2026-02-05
--  
SELECT
    *
FROM
    (
        SELECT
            t.*,
            rank() over (partition BY mem,SOURCE_ID, TRUNC(CAST (longtodate (ENTRY_TIME) AS DATE))
            ORDER BY ENTRY_TIME ASC) AS rnk
        FROM
            (
                SELECT
                    il.PERSON_CENTER||'p'||il.PERSON_ID AS mem,
                    ABS(inv.ENTRY_TIME - lead(inv.ENTRY_TIME) over (partition BY il.PERSON_CENTER,
                    il.PERSON_ID,SOURCE_ID, TRUNC(CAST(longtodate (inv.ENTRY_TIME) AS DATE))
                    ORDER BY inv.ENTRY_TIME ASC)) AS entry_time_diff,
                    pu.SOURCE_ID,
                    longtodate(inv.ENTRY_TIME),
                    TRUNC(CAST(longtodate (inv.ENTRY_TIME) AS DATE)) AS sales_date,
                    il.*,
                    inv.ENTRY_TIME
                FROM
                    INVOICE_LINES_MT il
                JOIN
                    INVOICES inv
                ON
                    inv.center = il.center
                AND inv.id = il.id
                JOIN
                    PERSONS p
                ON
                    p.center = il.PERSON_CENTER
                AND p.id = il.PERSON_ID
                JOIN
                    PRIVILEGE_USAGES pu
                ON
                    pu.TARGET_CENTER = il.center
                AND pu.TARGET_ID = il.id
                AND pu.TARGET_SUBID = il.subid
                AND pu.TARGET_SERVICE = 'InvoiceLine'
                AND pu.state = 'USED'
                JOIN
                    PRIVILEGE_GRANTS pg
                ON
                    pg.id = pu.GRANT_ID
                AND pg.GRANTER_SERVICE = 'Addon'
                WHERE
                    il.PERSON_CENTER = 231 and il.PERSON_ID = 80839 and
                    p.PERSONTYPE != 2
                AND il.TOTAL_AMOUNT = 0
                AND il.PRODUCT_NORMAL_PRICE != 0
                AND inv.ENTRY_TIME BETWEEN 1677637920000 AND 1679365920000
                --AND inv.ENTRY_TIME BETWEEN 1677637920000 AND 1677810720000
                AND EXISTS
                    (
                        SELECT
                            1
                        FROM
                            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
                        WHERE
                            ppgl.PRODUCT_CENTER = il.PRODUCTCENTER
                        AND ppgl.PRODUCT_ID = il.PRODUCTID
                        AND ppgl.PRODUCT_GROUP_ID = 5801) ) t
        WHERE
            ENTRY_TIME_DIFF IS NULL
        OR  ENTRY_TIME_DIFF > 1000) t2
/*WHERE
    rnk = 2*/