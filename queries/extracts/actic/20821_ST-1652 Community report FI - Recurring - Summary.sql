-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            dateToLongC(TO_CHAR(trunc(rp.START_DATE),'YYYY-MM-DD') || ' 00:00',$$Club$$)   FromDate 
            ,dateToLongC(TO_CHAR(trunc(rp.END_DATE),'YYYY-MM-DD') || ' 00:00',$$Club$$)   ToDate             
        FROM
            REPORT_PERIODS rp
        JOIN
            CENTERS c
        ON
            c.COUNTRY = DECODE(rp.SCOPE_ID,28,'FI',2,'SE',4,'NO',44,'DE')
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
    
 SELECT  /*+ NO_BIND_AWARE */
    clubs.NAME salesCenter,
    per.center || 'p' || per.id memberId,
    per.FIRSTNAME,
    per.LASTNAME,
    SUM(sales.excluding_vat) excl_vat,
    SUM(sales.included_vat) incl_vat,
    SUM(sales.total_amount) total,
    payments.payerid payerId,
    payments.amount paidAmount,
    payments.type,
    payments.paymentDate,
    community.LASTNAME communityname,
    community.ADDRESS1,
    community.ADDRESS2,
    community.ZIPCODE,
    community.CITY,
    CASE
        WHEN SUM(sales.total_amount) > 0 AND adminfee1.TXTVALUE is not null
        THEN to_number(adminfee1.TXTVALUE, '999999.99')
        ELSE 0
    END fee_eft,
    CASE
        WHEN SUM(sales.total_amount) > 0 AND adminfee2.TXTVALUE is not null
        THEN to_number(adminfee2.TXTVALUE, '999999.99')
        ELSE 0
    END fee_admin,
    comment1.TXTVALUE comment1,
    paymenttext.TXTVALUE paymenttext,
    CASE
        WHEN SUM(sales.total_amount) > 0
        THEN SUM(sales.excluding_vat) - nvl(to_number(adminfee1.TXTVALUE, '999999.99'), 0) - nvl(to_number(adminfee2.TXTVALUE,
            '999999.99'), 0)
        WHEN SUM(sales.total_amount) < 0
        THEN SUM(sales.excluding_vat)
        ELSE 0
    END splitamount,
    to_number(splitrate.TXTVALUE, '999999.99') splitrate,
    CASE
        WHEN SUM(sales.total_amount) > 0
        THEN to_number(splitrate.TXTVALUE, '999999.99') / 100 * (SUM(sales.excluding_vat) - nvl(to_number(
            adminfee1.TXTVALUE, '999999.99'), 0) - nvl(to_number(adminfee2.TXTVALUE, '999999.99'), 0))
        WHEN SUM(sales.total_amount) < 0
        THEN to_number(splitrate.TXTVALUE, '999999.99') / 100 * SUM(sales.excluding_vat)
        ELSE 0
    END COMMUNITYPART,
    CASE
        WHEN SUM(sales.total_amount) > 0
        THEN 1
        ELSE 0
    END FEE_APPLIED,
    TO_CHAR(exerpro.longtodateTZ((params.FromDate ), 'Europe/Helsinki'), 'dd.MM.yyyy') PeriodStart,
    TO_CHAR(exerpro.longtodateTZ(params.ToDate, 'Europe/Helsinki'), 'dd.MM.yyyy') PeriodEnd,
  clubs.SHORTNAME salesCenterShort
FROM params,
   ( SELECT $$Club$$ id from dual) center JOIN

    -- Get all payments received in period and find the ar transactions with invoices
    -- and credit notes linked to the paid payment requests
    (
		SELECT
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
		    END type
		FROM params, 
		    ACCOUNT_TRANS act
		JOIN AR_TRANS art
		ON
		    art.REF_CENTER = act.center
		    AND art.REF_ID = act.id
		    AND art.REF_SUBID = act.subid
		    AND art.REF_TYPE = 'ACCOUNT_TRANS'
		JOIN ACCOUNT_RECEIVABLES ar
		ON
		    art.center = ar.center
		    AND art.id = ar.id
		JOIN PERSONS p
		ON
		    p.center = ar.CUSTOMERCENTER
		    AND p.id = ar.CUSTOMERID
		JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
		ON
		    prs.REF = art.INFO
		    AND prs.REQUESTED_AMOUNT = art.AMOUNT
		LEFT JOIN AR_TRANS artSales
		ON
		    artSales.PAYREQ_SPEC_CENTER = prs.center
		    AND artSales.PAYREQ_SPEC_ID = prs.id
		    AND artSales.PAYREQ_SPEC_SUBID = prs.subid
		    AND artSales.REF_TYPE IN ('INVOICE', 'CREDIT_NOTE')
		WHERE
		    act.INFO_TYPE IN (3, 16)
		    AND artSales.REF_CENTER = $$Club$$
		    AND act.TRANS_TIME >= params.FromDate
		    AND act.TRANS_TIME < params.ToDate + 1000*60*60*24
		UNION ALL
		SELECT
		    p.CENTER || 'p' || p.id payerid,
		    prs.ref,
		    art.AMOUNT,
		    TO_CHAR(longtodate(art.TRANS_TIME), 'YYYY-MM-DD') paymentDate,
		    artSales.REF_CENTER,
		    artSales.REF_ID,
		    artSales.REF_TYPE,
		    'External' type
		FROM params,
		    ACCOUNT_TRANS act
		JOIN AR_TRANS art
		ON
		    art.REF_CENTER = act.center
		    AND art.REF_ID = act.id
		    AND art.REF_SUBID = act.subid
		    AND art.REF_TYPE = 'ACCOUNT_TRANS'
		JOIN ACCOUNT_RECEIVABLES ar
		ON
		    art.center = ar.center
		    AND art.id = ar.id
		JOIN PERSONS p
		ON
		    p.center = ar.CUSTOMERCENTER
		    AND p.id = ar.CUSTOMERID
		JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
		ON
		    prs.REF = art.INFO
		    AND prs.REQUESTED_AMOUNT = art.AMOUNT
		LEFT JOIN AR_TRANS artSales
		ON
		    artSales.PAYREQ_SPEC_CENTER = prs.center
		    AND artSales.PAYREQ_SPEC_ID = prs.id
		    AND artSales.PAYREQ_SPEC_SUBID = prs.subid
		    AND artSales.REF_TYPE IN ('INVOICE', 'CREDIT_NOTE')
		WHERE
		    act.INFO_TYPE IN (4)
		    AND artSales.REF_CENTER = $$Club$$            
		    AND act.TRANS_TIME >= params.FromDate
		    AND act.TRANS_TIME < params.ToDate + 1000*60*60*24
    )
    payments
    ON payments.REF_CENTER = center.id


JOIN
    -- Invoices and credit notes with member id and sales club
    (
        SELECT
            i.center,
            i.id,
            il.PERSON_CENTER,
            il.PERSON_ID,
            prod.NAME pname,
            ROUND(SUM(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1-(1/(1+il.RATE))))),2) excluding_vat,
            ROUND(SUM(il.TOTAL_AMOUNT * (1-(1/(1+il.RATE)))),2) included_vat,
            ROUND(SUM(il.TOTAL_AMOUNT), 2) total_amount,
            il.RATE vat_rate,
            ROUND((1-(1/(1+il.RATE))),7) included_vat_rate,
            'INVOICE' type
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
        WHERE
            i.CENTER = $$Club$$
            AND il.TOTAL_AMOUNT <> 0
            AND prod.PTYPE IN (5,10,12)
            AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK pgl
                JOIN PRODUCT_GROUP pg
                ON
                    pgl.PRODUCT_GROUP_ID = pg.ID
                WHERE
                    prod.CENTER = pgl.PRODUCT_CENTER
                    AND prod.ID = pgl.PRODUCT_ID
                    AND pg.NAME = 'Excluded subscriptions'
            )
        GROUP BY
            i.center,
            i.id,
            il.PERSON_CENTER,
            il.PERSON_ID,
            prod.CENTER,
            prod.NAME,
            il.RATE
        UNION
        SELECT
            c.center,
            c.id,
            cl.PERSON_CENTER,
            cl.PERSON_ID,
            prod.NAME pname,
            -ROUND(SUM(cl.TOTAL_AMOUNT - ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2)), 2) excluding_vat,
            -ROUND(SUM(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE)))), 2) included_vat,
            -ROUND(SUM(cl.TOTAL_AMOUNT), 2) total_amount,
            cl.RATE vat_rate,
            ROUND((1-(1/(1+cl.RATE))),7) included_vat_rate,
            'CREDIT_NOTE' type
        FROM
            CREDIT_NOTES c
        LEFT JOIN CREDIT_NOTE_LINES cl
        ON
            cl.center = c.center
            AND cl.id = c.id
        JOIN PRODUCTS prod
        ON
            prod.center = cl.PRODUCTCENTER
            AND prod.id = cl.PRODUCTID
        WHERE
            c.CENTER = $$Club$$
            AND cl.TOTAL_AMOUNT <> 0
            AND prod.PTYPE IN (5,10,12)
            AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK pgl
                JOIN PRODUCT_GROUP pg
                ON
                    pgl.PRODUCT_GROUP_ID = pg.ID
                WHERE
                    prod.CENTER = pgl.PRODUCT_CENTER
                    AND prod.ID = pgl.PRODUCT_ID
                    AND pg.NAME = 'Excluded subscriptions'
            )
        GROUP BY
            c.center,
            c.id,
            cl.PERSON_CENTER,
            cl.PERSON_ID,
            prod.CENTER,
            prod.NAME,
            longtodate(c.TRANS_TIME),
            cl.RATE
    )
    sales
ON
    -- Join the ar sales transactions to invoices and credit notes to find amount
    payments.REF_CENTER = sales.center
    AND payments.REF_ID = sales.id
    AND payments.REF_TYPE = sales.TYPE
JOIN persons per
ON
    -- Persons linked to invoices and credit notes - eg. the members paid for
    per.CENTER = sales.person_center
    AND per.id = sales.person_id
JOIN CENTERS clubs
ON
    -- Sales clubs from invoices and credit notes
    sales.center = clubs.id
LEFT JOIN PERSONS community
ON
    clubs.ORG_CODE2 = community.center || 'p' || community.id
    AND community.SEX = 'C'
LEFT JOIN PERSON_EXT_ATTRS adminfee1
ON
    community.center = adminfee1.PERSONCENTER
    AND community.id = adminfee1.PERSONID
    AND adminfee1.NAME = 'ADMIN_FEE_EFT_1'
LEFT JOIN PERSON_EXT_ATTRS adminfee2
ON
    community.center = adminfee2.PERSONCENTER
    AND community.id = adminfee2.PERSONID
    AND adminfee2.NAME = 'ADMIN_FEE_EFT_2'
LEFT JOIN PERSON_EXT_ATTRS comment1
ON
    community.center = comment1.PERSONCENTER
    AND community.id = comment1.PERSONID
    AND comment1.NAME = 'COMMUNITY_COMMENT_1'
LEFT JOIN PERSON_EXT_ATTRS paymenttext
ON
    community.center = paymenttext.PERSONCENTER
    AND community.id = paymenttext.PERSONID
    AND paymenttext.NAME = 'PAYMENT_TEXT'
LEFT JOIN PERSON_EXT_ATTRS splitrate
ON
    community.center = splitrate.PERSONCENTER
    AND community.id = splitrate.PERSONID
    AND splitrate.NAME = 'SPLIT_RATE_COMMUNITY'
WHERE payments.REF_CENTER = $$Club$$
GROUP BY
    -- Grouping should ensure we get one amount per member per membership type per sales type
    clubs.NAME ,
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
    params.fromdate,
    params.todate
ORDER BY
    1,
    10,
    4,
    3