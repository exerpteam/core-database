-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    aar,
    maaned, maanavn,
    salescenter center,
	persontype,
    COUNT(DISTINCT personId) persons,
    SUM(joining) joining,
    SUM(kontant) cash,
    SUM(prorata) prorata,
    SUM(monthly) monthly
FROM
    (
        SELECT
            case WHEN p.SEX!='C' then i.PERSON_CENTER || 'p' || i.PERSON_ID else null end personId,
            TO_CHAR(longtodate(i.TRANS_TIME), 'YYYY') aar,
            TO_CHAR(longtodate(i.TRANS_TIME), 'MM') maaned,
            TO_CHAR(longtodate(i.TRANS_TIME), 'MONTH') maanavn,
            i.center salescenter,
            prod.PTYPE,
            CASE
                WHEN p.PERSONTYPE = 4
                THEN 'COMPANY'
                ELSE 'PRIVATE'
            END AS persontype,
            CASE
                WHEN PTYPE = 5
                THEN il.TOTAL_AMOUNT
                ELSE 0
            END AS joining,
            CASE
                WHEN ST_TYPE = 0
                THEN il.TOTAL_AMOUNT
                ELSE 0
            END AS kontant,
            CASE
                WHEN PTYPE = 12
                THEN il.TOTAL_AMOUNT
                ELSE 0
            END AS prorata,
            CASE
                WHEN PTYPE = 10
                THEN il.TOTAL_AMOUNT
                ELSE 0
            END AS monthly
        FROM
            INVOICES i
        JOIN INVOICELINES il
        ON
            il.center = i.center
            AND il.id = i.id
        JOIN PRODUCTS prod
        ON
            prod.center = il.PRODUCTCENTER
            AND prod.id = il.PRODUCTID
        JOIN PERSONS p
        ON
            p.center = i.PERSON_CENTER
            AND p.id = i.PERSON_ID
        LEFT JOIN FW.SUBSCRIPTIONTYPES st
        ON
            prod.CENTER = st.CENTER
            AND prod.ID = st.ID
        WHERE
            prod.PTYPE IN (5,10,12)
            AND il.TOTAL_AMOUNT <> 0
            AND i.TRANS_TIME >= :FromDate
            AND i.TRANS_TIME < :ToDate + 1000*60*60*24
        UNION ALL
        SELECT
            case WHEN p.SEX!='C' then c.PERSON_CENTER || 'p' || c.PERSON_ID else null end personId,
            TO_CHAR(longtodate(c.TRANS_TIME), 'YYYY') aar,
            TO_CHAR(longtodate(c.TRANS_TIME), 'MM') maaned,
            TO_CHAR(longtodate(c.TRANS_TIME), 'MONTH') maanavn,
            c.center salescenter,
            prod.PTYPE,
            CASE
                WHEN p.PERSONTYPE = 4
                THEN 'COMPANY'
                ELSE 'PRIVATE'
            END AS persontype,
            CASE
                WHEN PTYPE = 5
                THEN cl.TOTAL_AMOUNT
                ELSE 0
            END AS joining,
            CASE
                WHEN ST_TYPE = 0
                THEN cl.TOTAL_AMOUNT
                ELSE 0
            END AS kontant,
            CASE
                WHEN PTYPE = 12
                THEN cl.TOTAL_AMOUNT
                ELSE 0
            END AS prorata,
            CASE
                WHEN PTYPE = 10
                THEN cl.TOTAL_AMOUNT
                ELSE 0
            END AS monthly
        FROM
            CREDIT_NOTES c
        JOIN CREDIT_NOTE_LINES cl
        ON
            cl.center = c.center
            AND cl.id = c.id
        JOIN PRODUCTS prod
        ON
            prod.center = cl.PRODUCTCENTER
            AND prod.id = cl.PRODUCTID
        JOIN PERSONS p
        ON
            p.center = c.PERSON_CENTER
            AND p.id = c.PERSON_ID
        LEFT JOIN FW.SUBSCRIPTIONTYPES st
        ON
            prod.CENTER = st.CENTER
            AND prod.ID = st.ID
        WHERE
            prod.PTYPE IN (5,10,12)
            AND cl.TOTAL_AMOUNT <> 0
            AND c.TRANS_TIME >= :FromDate
            AND c.TRANS_TIME < :ToDate + 1000*60*60*24
    )
WHERE
    salescenter in (:scope)
GROUP BY
    aar,
    maaned, maanavn,
    salescenter,
	persontype