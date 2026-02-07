WITH
    params AS materialized
    (
        SELECT
            /*+ materialize */
            dateToLongC(TO_CHAR(TRUNC(rp.START_DATE),'YYYY-MM-DD') || ' 00:00',$$Club$$)    FromDate ,
            dateToLongC(TO_CHAR(TRUNC(rp.END_DATE),'YYYY-MM-DD') || ' 00:00',$$Club$$)      ToDate ,
            $$Club$$                                                                     AS Club
        FROM
            REPORT_PERIODS rp
        JOIN
            CENTERS c
        ON
            c.COUNTRY = CASE rp.SCOPE_ID WHEN 28 THEN 'FI' WHEN 2 THEN 'SE' WHEN 4 THEN 'NO' WHEN 44 THEN 'DE' END
        WHERE
            rp.HARD_CLOSE_TIME IS NOT NULL
            AND c.id = $$Club$$
            AND rp.HARD_CLOSE_TIME IN
            (
                SELECT
                    MAX (rp2.HARD_CLOSE_TIME)
                FROM
                    REPORT_PERIODS rp2
                WHERE
                    rp2.SCOPE_TYPE = rp.SCOPE_TYPE
                    AND rp2.SCOPE_ID = rp.SCOPE_ID)
    )
SELECT
    /*+ NO_BIND_AWARE */
    clubs.NAME                  "SALESCENTER",
    per.center || 'p' || per.id "MEMBERID",
    per.FIRSTNAME "FIRSTNAME",
    per.LASTNAME "LASTNAME",
    SUM(sales.excluding_vat) "EXCL_VAT",
    SUM(sales.included_vat)  "INCL_VAT",
    SUM(sales.total_amount) "TOTAL",
    payments.payerid         "PAYERID",
    payments.amount          "PAIDAMOUNT",
    payments.type "TYPE",
    payments.paymentDate "PAYMENTDATE",
    community.LASTNAME "COMMUNITYNAME",
    community.ADDRESS1 "ADDRESS1",
    community.ADDRESS2 "ADDRESS2",
    community.ZIPCODE "ZIPCODE",
    community.CITY "CITY",
    CASE
        WHEN SUM(sales.total_amount) > 0
            AND adminfee1.TXTVALUE IS NOT NULL
        THEN to_number(adminfee1.TXTVALUE, '999999.99999')
        ELSE 0
    END "FEE_EFT" ,
    CASE
        WHEN SUM(sales.total_amount) > 0
            AND adminfee2.TXTVALUE IS NOT NULL
        THEN to_number(adminfee2.TXTVALUE, '999999.99999')
        ELSE 0
    END                  "FEE_ADMIN" ,
    comment1.TXTVALUE    "COMMENT1" ,
    paymenttext.TXTVALUE "PAYMENTTEXT" ,
    CASE
        WHEN SUM(sales.total_amount) > 0
        THEN SUM(sales.excluding_vat) - COALESCE(to_number(adminfee1.TXTVALUE, '999999.99999'), 0) - COALESCE(to_number(adminfee2.TXTVALUE, '999999.99999'), 0)
        WHEN SUM(sales.total_amount) < 0
        THEN SUM(sales.excluding_vat)
        ELSE 0
    END                                           "SPLITAMOUNT" ,
    to_number(splitrate.TXTVALUE, '999999.99999') "SPLITRATE" ,
    CASE
        WHEN SUM(sales.total_amount) > 0
        THEN to_number(splitrate.TXTVALUE, '999999.99999') / 100 * (SUM(sales.excluding_vat) - COALESCE(to_number( adminfee1.TXTVALUE, '999999.99999'), 0) - COALESCE(to_number(adminfee2.TXTVALUE, '999999.99999'), 0))
        WHEN SUM(sales.total_amount) < 0
        THEN to_number(splitrate.TXTVALUE, '999999.99999') / 100 * SUM(sales.excluding_vat)
        ELSE 0
    END "COMMUNITYPART" ,
    CASE
        WHEN SUM(sales.total_amount) > 0
        THEN CAST(1 AS NUMERIC)
        ELSE CAST(0 AS NUMERIC)
    END                                                "FEE_APPLIED" ,
    TO_CHAR(longtodate(:fromDate), 'dd.MM.yyyy') "PERIODSTART" ,
    TO_CHAR(longtodate(:toDate), 'dd.MM.yyyy')   "PERIODEND" ,
    clubs.SHORTNAME                                    "SALESCENTERSHORT"
FROM
    -- Get all payments received in period and find the ar transactions with invoices
    -- and credit notes linked to the paid payment requests
    params ,
    (
        SELECT
            $$Club$$ id
        ) center
JOIN
    (
        SELECT
            /*+ INDEX(ACCOUNT_TRANS IDX_ACT_INFO_TIME) */
            p.CENTER || 'p' || p.id payerid,
            prs.ref,
            art.AMOUNT,
            TO_CHAR(longtodate(art.TRANS_TIME), 'YYYY-MM-DD') paymentDate,
            artSales.REF_CENTER,
            artSales.REF_ID,
            artSales.REF_TYPE,
            CASE
                WHEN p.SEX = 'C'
                THEN 'Corporate'
                ELSE 'AG/Faktura'
            END as type
        FROM
            params ,
            ACCOUNT_TRANS act
        JOIN
            AR_TRANS art
        ON
            art.REF_CENTER = act.center
            AND art.REF_ID = act.id
            AND art.REF_SUBID = act.subid
            AND art.REF_TYPE = 'ACCOUNT_TRANS'
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            art.center = ar.center
            AND art.id = ar.id
        JOIN
            PERSONS p
        ON
            p.center = ar.CUSTOMERCENTER
            AND p.id = ar.CUSTOMERID

        JOIN
            PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            prs.REF = art.INFO
            AND prs.REQUESTED_AMOUNT = art.AMOUNT
        LEFT JOIN
            AR_TRANS artSales
        ON
            artSales.PAYREQ_SPEC_CENTER = prs.center
            AND artSales.PAYREQ_SPEC_ID = prs.id
            AND artSales.PAYREQ_SPEC_SUBID = prs.subid
            AND artSales.REF_TYPE IN ('INVOICE',
                                      'CREDIT_NOTE')
        WHERE
            act.INFO_TYPE IN (3,
                              16)
            AND artSales.REF_CENTER = $$Club$$
            AND act.TRANS_TIME >= :fromDate
            AND act.TRANS_TIME < :toDate + 1000*60*60*24
            AND act.center IN
            (
                SELECT
                    id
                FROM
                    centers
                WHERE
                    country = 'NO')
        UNION ALL
        SELECT
            p.CENTER || 'p' || p.id payerid,
            prs.ref,
            art.AMOUNT,
            TO_CHAR(longtodate(art.TRANS_TIME), 'YYYY-MM-DD') paymentDate,
            artSales.REF_CENTER,
            artSales.REF_ID,
            artSales.REF_TYPE,
            'External' as type
        FROM
            params ,
            ACCOUNT_TRANS act
        JOIN
            AR_TRANS art
        ON
            art.REF_CENTER = act.center
            AND art.REF_ID = act.id
            AND art.REF_SUBID = act.subid
            AND art.REF_TYPE = 'ACCOUNT_TRANS'
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            art.center = ar.center
            AND art.id = ar.id
        JOIN
            PERSONS p
        ON
            p.center = ar.CUSTOMERCENTER
            AND p.id = ar.CUSTOMERID
        JOIN
            PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            prs.REF = art.INFO
            AND prs.REQUESTED_AMOUNT = art.AMOUNT
        LEFT JOIN
            AR_TRANS artSales
        ON
            artSales.PAYREQ_SPEC_CENTER = prs.center
            AND artSales.PAYREQ_SPEC_ID = prs.id
            AND artSales.PAYREQ_SPEC_SUBID = prs.subid
            AND artSales.REF_TYPE IN ('INVOICE',
                                      'CREDIT_NOTE')
        WHERE
            act.INFO_TYPE IN (4)
            AND artSales.REF_CENTER = $$Club$$
            AND act.TRANS_TIME >= :fromDate
            AND act.TRANS_TIME < :toDate + 1000*60*60*24 ) payments
ON
    payments.REF_CENTER = center.id
JOIN
    -- Invoices and credit notes with member id and sales club
    (
        SELECT
            i.center,
            i.id,
            il.PERSON_CENTER,
            il.PERSON_ID,
            prod.NAME                                                                      pname,
            ROUND(SUM(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1-(1/(1+COALESCE(il.RATE,0)))))),2) excluding_vat,
            ROUND(SUM(il.TOTAL_AMOUNT * (1-(1/(1+COALESCE(il.RATE,0))))),2)                     included_vat,
            ROUND(SUM(il.TOTAL_AMOUNT), 2)                                                 total_amount,
            COALESCE(il.RATE,0)                                                                 vat_rate,
            ROUND((1-(1/(1+COALESCE(il.RATE,0)))),7)                                            included_vat_rate,
            'INVOICE'                                                                      as type
        FROM
            INVOICES i
        JOIN
            INVOICELINES il
        ON
            il.center = i.center
            AND il.id = i.id
        JOIN
            PRODUCTS prod
        ON
            prod.center = il.PRODUCTCENTER
            AND prod.id = il.PRODUCTID
 
        WHERE
            i.CENTER = $$Club$$
            AND il.TOTAL_AMOUNT <> 0
            AND prod.PTYPE IN (5,10,12)
            AND prod.GLOBALID  NOT IN(
                                'ONLINE_DIGITAL_MEMBERSHIP',
                                'CROSSFIT_0_MAN_')
            AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK pgl
                JOIN
                    PRODUCT_GROUP pg
                ON
                    pgl.PRODUCT_GROUP_ID = pg.ID
                WHERE
                    prod.CENTER = pgl.PRODUCT_CENTER
                    AND prod.ID = pgl.PRODUCT_ID
                    AND pg.NAME = 'Excluded subscriptions' )
        GROUP BY
            i.center,
            i.id,
            il.PERSON_CENTER,
            il.PERSON_ID,
            prod.CENTER,
            prod.NAME,
            COALESCE(il.RATE,0)
        UNION
        SELECT
            c.center,
            c.id,
            cl.PERSON_CENTER,
            cl.PERSON_ID,
            prod.NAME                                                                                pname,
            -ROUND(SUM(cl.TOTAL_AMOUNT - ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+COALESCE(cl.RATE,0)))), 2)), 2) excluding_vat,
            -ROUND(SUM(cl.TOTAL_AMOUNT * (1-(1/(1+COALESCE(cl.RATE,0))))), 2)                             included_vat,
            -ROUND(SUM(cl.TOTAL_AMOUNT), 2)                                                          total_amount,
            COALESCE(cl.RATE,0)                                                                           vat_rate,
            ROUND((1-(1/(1+COALESCE(cl.RATE,0)))),7)                                                      included_vat_rate,
            'CREDIT_NOTE'                                                                            as type
        FROM
            params ,
            CREDIT_NOTES c
        LEFT JOIN
            CREDIT_NOTE_LINES cl
        ON
            cl.center = c.center
            AND cl.id = c.id
        JOIN
            PRODUCTS prod
        ON
            prod.center = cl.PRODUCTCENTER
            AND prod.id = cl.PRODUCTID
        WHERE
            c.CENTER = $$Club$$
            AND cl.TOTAL_AMOUNT <> 0
            AND prod.PTYPE IN (5,10,12)
            AND prod.GLOBALID  NOT IN(
                                'ONLINE_DIGITAL_MEMBERSHIP',
                                'CROSSFIT_0_MAN_')
            AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK pgl
                JOIN
                    PRODUCT_GROUP pg
                ON
                    pgl.PRODUCT_GROUP_ID = pg.ID
                WHERE
                    prod.CENTER = pgl.PRODUCT_CENTER
                    AND prod.ID = pgl.PRODUCT_ID
                    AND pg.NAME = 'Excluded subscriptions' )
        GROUP BY
            c.center,
            c.id,
            cl.PERSON_CENTER,
            cl.PERSON_ID,
            prod.CENTER,
            prod.NAME,
            longtodate(c.TRANS_TIME),
            COALESCE(cl.RATE,0) ) sales
ON
    -- Join the ar sales transactions to invoices and credit notes to find amount
    payments.REF_CENTER = sales.center
    AND payments.REF_ID = sales.id
    AND payments.REF_TYPE = sales.TYPE
JOIN
    persons per
ON
    -- Persons linked to invoices and credit notes - eg. the members paid for
    per.CENTER = sales.person_center
    AND per.id = sales.person_id
JOIN
    CENTERS clubs
ON
    -- Sales clubs from invoices and credit notes
    sales.center = clubs.id
LEFT JOIN
    PERSONS community
ON
    clubs.ORG_CODE2 = community.center || 'p' || community.id
    AND community.SEX = 'C'
LEFT JOIN
    PERSON_EXT_ATTRS adminfee1
ON
    community.center = adminfee1.PERSONCENTER
    AND community.id = adminfee1.PERSONID
    AND adminfee1.NAME = 'ADMIN_FEE_EFT_1'
LEFT JOIN
    PERSON_EXT_ATTRS adminfee2
ON
    community.center = adminfee2.PERSONCENTER
    AND community.id = adminfee2.PERSONID
    AND adminfee2.NAME = 'ADMIN_FEE_EFT_2'
LEFT JOIN
    PERSON_EXT_ATTRS comment1
ON
    community.center = comment1.PERSONCENTER
    AND community.id = comment1.PERSONID
    AND comment1.NAME = 'COMMUNITY_COMMENT_1'
LEFT JOIN
    PERSON_EXT_ATTRS paymenttext
ON
    community.center = paymenttext.PERSONCENTER
    AND community.id = paymenttext.PERSONID
    AND paymenttext.NAME = 'PAYMENT_TEXT'
LEFT JOIN
    PERSON_EXT_ATTRS splitrate
ON
    community.center = splitrate.PERSONCENTER
    AND community.id = splitrate.PERSONID
    AND splitrate.NAME = 'SPLIT_RATE_COMMUNITY'
WHERE
    payments.REF_CENTER = $$Club$$
GROUP BY
    -- Grouping should ensure we get one amount per member per membership type per sales type
    clubs.NAME,
    clubs.SHORTNAME,
    per.center || 'p' || per.id,
    per.FIRSTNAME,
    per.LASTNAME,
    --sales.pname,
    --sales.type,
    payments.payerid,
    payments.amount,
    payments.type,
    payments.paymentDate,
    community.LASTNAME,
    community.ADDRESS1,
    community.ADDRESS2,
    community.ZIPCODE,
    community.CITY,
    adminfee1.TXTVALUE,
    adminfee2.TXTVALUE,
    comment1.TXTVALUE,
    paymenttext.TXTVALUE,
    splitrate.TXTVALUE,
    :fromDate,
    :toDate
ORDER BY
    1,
    10,
    4,
    3
