WITH params AS
        (       
                SELECT 
                        /*+ materialize  */
                        dateToLongTZ(to_char(trunc(sysdate-60),'YYYY-MM-DD') || ' 00:00','Europe/London') AS CutDate
                FROM DUAL 
        )
SELECT
        p.*
FROM PERSONS p
CROSS JOIN params
JOIN CENTERS c ON p.CENTER = c.ID
JOIN STATE_CHANGE_LOG scl ON p.CENTER = scl.CENTER AND p.ID = scl.ID AND scl.ENTRY_TYPE = 1 AND scl.STATEID IN (0,2,6) AND scl.ENTRY_END_TIME IS NOT NULL
JOIN STATE_CHANGE_LOG scl2 ON p.CENTER = scl2.CENTER AND p.ID = scl2.ID AND scl2.ENTRY_TYPE = 1 AND scl2.STATEID = 1 AND scl2.ENTRY_END_TIME IS NULL

WHERE
        p.STATUS = 1 
        AND c.COUNTRY = 'GB'
        --AND p.CENTER = 4
        AND scl.ENTRY_END_TIME > params.CutDate
        AND scl.ENTRY_END_TIME = scl2.ENTRY_START_TIME
        AND NOT EXISTS
        (
                SELECT
                        1
                FROM
                        CLIPCARDS c 
                        JOIN INVOICE_LINES_MT il ON c.INVOICELINE_CENTER = il.CENTER AND c.INVOICELINE_ID = il.ID AND c.INVOICELINE_SUBID = il.SUBID
                        JOIN VA.INVOICES i ON il.CENTER = i.CENTER AND il.ID = i.ID
                        JOIN CLIPCARDTYPES ct ON ct.center = c.CENTER AND ct.ID = c.ID
                        JOIN PRODUCTS pd ON pd.CENTER = ct.CENTER AND pd.ID = ct.ID
                        JOIN PRODUCT_AND_PRODUCT_GROUP_LINK pgl ON pgl.PRODUCT_CENTER = pd.CENTER AND pgl.PRODUCT_ID = pd.ID
                        JOIN PRODUCT_GROUP pr ON pgl.PRODUCT_GROUP_ID = pr.ID AND pr.ID IN (18617) --12001
                WHERE
                        p.CENTER = c.OWNER_CENTER
                        AND p.ID = c.OWNER_ID
                        AND i.ENTRY_TIME > params.CutDate        
        )