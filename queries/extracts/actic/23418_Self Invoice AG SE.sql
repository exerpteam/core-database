SELECT
    i2.SALESCENTER
  , i2.SALESID
  , i2.SUMEXCLVAT
  , i2.SUMVAT
  , i2.SUMTOTAL
  , i2.CENTER
  , i2.ID
  , i2.COMMUNITYNAME
  , i2.ADDRESS1
  , i2.ADDRESS2
  , i2.ZIPCODE
  , i2.CITY
  , i2.VAT
  , NVL(i2.ACCOUNT_NUMBER,' ') ACCOUNT_NUMBER
  , i2.SUMFEE1
  , i2.SUMFEE2
  , i2.COMMENT1
  , i2.PAYMENTTEXT
  , i2.SUMSPLITAMOUNT
  , i2.SPLITRATE
  , i2.SUMCOMMUNITYPART
  , i2.COUNT
  , i2.PERIODSTART
  , i2.PERIODEND
  , i2.SALESCENTERSHORT
  ,NVL(bn.TXTVALUE,' ')                                BILLING_NBR
  ,NVL(p.FULLNAME,' ')                                 CONTACT_PERSON
  ,NVL(ce.TXTVALUE ,' ')                               CONTACT_EMAIL
  , NVL(cp.TXTVALUE,' ')                               CONTACT_WORK_PHONE
  ,NVL(comp.SSN,' ')                                   ORG_NBR
  , TO_CHAR(TRUNC(add_months(exerpsysdate(),1)),'YYYY-MM-DD') DUE_DATE
  , TO_CHAR(TRUNC(exerpsysdate()),'YYYY-MM-DD')               TODAY
  , i2.SALESID || TO_CHAR(exerpsysdate(),'YYYYMM')            INV_ID
FROM
    (
        SELECT
            i1.SALESCENTER
          ,i1.SALESID
          , SUM(i1.EXCL_VAT) SumExclVat
          , SUM(i1.INCL_VAT) SumVat
          , SUM(i1.TOTAL)    SumTotal
          ,i1.center
          ,i1.id
          , i1.COMMUNITYNAME
          , i1.ADDRESS1
          , i1.ADDRESS2
          , i1.ZIPCODE
          , i1.CITY
          , i1.VAT
          , i1.ACCOUNT_NUMBER
          , SUM(i1.FEE_EFT)   SumFee1
          , SUM(i1.FEE_ADMIN) SumFee2
          , i1.COMMENT1
          , i1.PAYMENTTEXT
          , SUM(i1.SPLITAMOUNT) SumSplitAmount
          , i1.SPLITRATE
          , SUM(i1.COMMUNITYPART) SumCommunityPart
          , COUNT(i1.FEE_APPLIED) COUNT
          , i1.PERIODSTART
          , i1.PERIODEND
          , i1.SALESCENTERSHORT
        FROM
            (
                WITH
                    params AS
                    (
                        SELECT
                            dateToLongC(TO_CHAR(TRUNC(rp.START_DATE),'YYYY-MM-DD') || ' 00:00',$$Club$$) FromDate
                          ,dateToLongC(TO_CHAR(TRUNC(rp.END_DATE),'YYYY-MM-DD') || ' 00:00',$$Club$$)    ToDate
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
                SELECT
                    /*+ NO_BIND_AWARE */
                    clubs.NAME                  salesCenter
                  ,clubs.ID                     SALESID
                  , per.center || 'p' || per.id memberId
                  , per.FIRSTNAME
                  , per.LASTNAME
                  , SUM(sales.excluding_vat) excl_vat
                  , SUM(sales.included_vat)  incl_vat
                  , SUM(sales.total_amount)  total
                  , payments.payerid         payerId
                  , payments.amount          paidAmount
                  , payments.type
                  , payments.paymentDate
                  , community.LASTNAME communityname
                  , community.ADDRESS1
                  , community.ADDRESS2
                  , community.ZIPCODE
                  , community.CITY
                  ,community.center
                  ,community.id
                  ,EXT_ACCOUNT_NUMBER.TXTVALUE ACCOUNT_NUMBER
                  ,EXT_VAT.TXTVALUE            VAT
                  , CASE
                        WHEN SUM(sales.total_amount) > 0
                            AND adminfee1.TXTVALUE IS NOT NULL
                        THEN to_number(adminfee1.TXTVALUE, '999999.99999')
                        ELSE 0
                    END fee_eft
                  , CASE
                        WHEN SUM(sales.total_amount) > 0
                            AND adminfee2.TXTVALUE IS NOT NULL
                        THEN to_number(adminfee2.TXTVALUE, '999999.99999')
                        ELSE 0
                    END                  fee_admin
                  , comment1.TXTVALUE    comment1
                  , paymenttext.TXTVALUE paymenttext
                  , CASE
                        WHEN SUM(sales.total_amount) > 0
                        THEN SUM(sales.excluding_vat) - NVL(to_number(adminfee1.TXTVALUE, '999999.99999'), 0) - NVL(to_number(adminfee2.TXTVALUE, '999999.99999'), 0)
                        WHEN SUM(sales.total_amount) < 0
                        THEN SUM(sales.excluding_vat)
                        ELSE 0
                    END                                           splitamount
                  , to_number(splitrate.TXTVALUE, '999999.99999') splitrate
                  , CASE
                        WHEN SUM(sales.total_amount) > 0
                        THEN to_number(splitrate.TXTVALUE, '999999.99999') / 100 * (SUM(sales.excluding_vat) - NVL(to_number( adminfee1.TXTVALUE, '999999.99999'), 0) - NVL(to_number(adminfee2.TXTVALUE, '999999.99999'), 0))
                        WHEN SUM(sales.total_amount) < 0
                        THEN to_number(splitrate.TXTVALUE, '999999.99999') / 100 * SUM(sales.excluding_vat)
                        ELSE 0
                    END COMMUNITYPART
                  , CASE
                        WHEN SUM(sales.total_amount) > 0
                        THEN 1
                        ELSE 0
                    END                                                FEE_APPLIED
                  , TO_CHAR(longtodate(params.FromDate), 'dd.MM.yyyy') PeriodStart
                  , TO_CHAR(longtodate(params.ToDate), 'dd.MM.yyyy')   PeriodEnd
                  , clubs.SHORTNAME                                    salesCenterShort
                FROM
                    params
                  , (
                        SELECT
                            $$Club$$ id
                        FROM
                            dual) center
                JOIN
                    -- Get all payments received in period and find the ar transactions with invoices
                    -- and credit notes linked to the paid payment requests
                    (
                        SELECT
                            /*+ INDEX(ACCOUNT_TRANS IDX_ACT_INFO_TIME) */
                            p.CENTER || 'p' || p.id payerid
                          , prs.ref
                          , art.AMOUNT
                          , TO_CHAR(longtodate(art.TRANS_TIME), 'YYYY-MM-DD') paymentDate
                          , artSales.REF_CENTER
                          , artSales.REF_ID
                          , artSales.REF_TYPE
                          , CASE
                                WHEN p.SEX = 'C'
                                THEN 'Corporate'
                                ELSE 'AG/Faktura'
                            END type
                        FROM
                            params
                          , ACCOUNT_TRANS act
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
                            AND (
                                prs.REQUESTED_AMOUNT = art.AMOUNT
                                OR prs.TOTAL_INVOICE_AMOUNT = art.AMOUNT)
                        LEFT JOIN
                            AR_TRANS artSales
                        ON
                            artSales.PAYREQ_SPEC_CENTER = prs.center
                            AND artSales.PAYREQ_SPEC_ID = prs.id
                            AND artSales.PAYREQ_SPEC_SUBID = prs.subid
                            AND artSales.REF_TYPE IN ('INVOICE'
                                                    , 'CREDIT_NOTE')
                        WHERE
                            act.INFO_TYPE IN (3
                                            , 16)
                            AND artSales.REF_CENTER = $$Club$$
                            AND act.TRANS_TIME >= params.FromDate
                            AND act.TRANS_TIME < params.ToDate + 1000 * 60 * 60 * 24
                            AND act.CENTER IN
                            (
                                SELECT
                                    id
                                FROM
                                    centers
                                WHERE
                                    id <= 200)
                        UNION ALL
                        SELECT
                            p.CENTER || 'p' || p.id payerid
                          , prs.ref
                          , art.AMOUNT
                          , TO_CHAR(longtodate(art.TRANS_TIME), 'YYYY-MM-DD') paymentDate
                          , artSales.REF_CENTER
                          , artSales.REF_ID
                          , artSales.REF_TYPE
                          , 'External' type
                        FROM
                            params
                          , ACCOUNT_TRANS act
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
                            AND artSales.REF_TYPE IN ('INVOICE'
                                                    , 'CREDIT_NOTE')
                        WHERE
                            act.INFO_TYPE IN (4)
                            AND artSales.REF_CENTER = $$Club$$
                            AND act.TRANS_TIME >= params.FromDate
                            AND act.TRANS_TIME < params.ToDate + 1000 * 60 * 60 * 24 ) payments
                ON
                    payments.REF_CENTER = center.id
                JOIN
                    -- Invoices and credit notes with member id and sales club
                    (
                        SELECT
                            i.center
                          , i.id
                          , il.PERSON_CENTER
                          , il.PERSON_ID
                          , prod.NAME                                                                            pname
                          , ROUND(SUM(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1 - (1 / (1 + NVL(il.RATE,0)))))),2) excluding_vat
                          , ROUND(SUM(il.TOTAL_AMOUNT * (1 - (1 / (1 + NVL(il.RATE,0))))),2)                     included_vat
                          , ROUND(SUM(il.TOTAL_AMOUNT), 2)                                                       total_amount
                          , NVL(il.RATE,0)                                                                       vat_rate
                          , ROUND((1 - (1 / (1 + NVL(il.RATE,0)))),7)                                            included_vat_rate
                          , 'INVOICE'                                                                            type
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
                            i.center
                          , i.id
                          , il.PERSON_CENTER
                          , il.PERSON_ID
                          , prod.CENTER
                          , prod.NAME
                          , NVL(il.RATE,0)
                        UNION
                        SELECT
                            c.center
                          , c.id
                          , cl.PERSON_CENTER
                          , cl.PERSON_ID
                          , prod.NAME                                                                                       pname
                          , - ROUND(SUM(cl.TOTAL_AMOUNT - ROUND(cl.TOTAL_AMOUNT * (1 - (1 / (1 + NVL(cl.RATE,0)))), 2)), 2) excluding_vat
                          , - ROUND(SUM(cl.TOTAL_AMOUNT * (1 - (1 / (1 + NVL(cl.RATE,0))))), 2)                             included_vat
                          , - ROUND(SUM(cl.TOTAL_AMOUNT), 2)                                                                total_amount
                          , NVL(cl.RATE,0)                                                                                  vat_rate
                          , ROUND((1 - (1 / (1 + NVL(cl.RATE,0)))),7)                                                       included_vat_rate
                          , 'CREDIT_NOTE'                                                                                   type
                        FROM
                            params
                          , CREDIT_NOTES c
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
                            c.center
                          , c.id
                          , cl.PERSON_CENTER
                          , cl.PERSON_ID
                          , prod.CENTER
                          , prod.NAME
                          , longtodate(c.TRANS_TIME)
                          , NVL(cl.RATE,0) ) sales
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
                    PERSON_EXT_ATTRS EXT_VAT
                ON
                    community.center = EXT_VAT.PERSONCENTER
                    AND community.id = EXT_VAT.PERSONID
                    AND EXT_VAT.NAME = 'VAT'
                LEFT JOIN
                    PERSON_EXT_ATTRS EXT_ACCOUNT_NUMBER
                ON
                    community.center = EXT_ACCOUNT_NUMBER.PERSONCENTER
                    AND community.id = EXT_ACCOUNT_NUMBER.PERSONID
                    AND EXT_ACCOUNT_NUMBER.NAME = 'AccountNumber'
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
                    params.FromDate
                  , params.ToDate
                  , clubs.NAME
                  ,clubs.ID
                  , clubs.SHORTNAME
                  , per.center || 'p' || per.id
                  , per.FIRSTNAME
                  , per.LASTNAME
                  ,
                    --sales.pname,
                    --sales.type,
                    payments.payerid
                  , payments.amount
                  , payments.type
                  , payments.paymentDate
                  , community.LASTNAME
                  , community.ADDRESS1
                  , community.ADDRESS2
                  , community.ZIPCODE
                  , community.CITY
                  ,community.center
                  ,community.id
                  ,EXT_ACCOUNT_NUMBER.TXTVALUE
                  ,EXT_VAT.TXTVALUE
                  , adminfee1.TXTVALUE
                  , adminfee2.TXTVALUE
                  , comment1.TXTVALUE
                  , paymenttext.TXTVALUE
                  , splitrate.TXTVALUE
                ORDER BY
                    1
                  , 10
                  , 4
                  , 3 ) i1
        GROUP BY
            i1.SALESCENTER
          ,i1.SALESID
          , i1.COMMUNITYNAME
          , i1.ADDRESS1
          , i1.ADDRESS2
          , i1.ZIPCODE
          , i1.CITY
          , i1.VAT
          ,i1.center
          ,i1.id
          , i1.ACCOUNT_NUMBER
          , i1.COMMENT1
          , i1.PAYMENTTEXT
          , i1.SPLITRATE
          , i1.PERIODSTART
          , i1.PERIODEND
          , i1.SALESCENTERSHORT ) i2
JOIN
    PERSONS comp
ON
    comp.center = i2.center
    AND comp.id = i2.id
LEFT JOIN
    PERSON_EXT_ATTRS bn
ON
    bn.PERSONCENTER = comp.CENTER
    AND bn.PERSONID = comp.ID
    AND bn.NAME = '_eClub_BillingNumber'
LEFT JOIN
    RELATIVES rel
ON
    rel.CENTER = comp.CENTER
    AND rel.ID = comp.ID
    AND rel.status = 1
    and rel.RTYPE = 7
	
LEFT JOIN
    PERSONS p
ON
    p.CENTER = rel.RELATIVECENTER
    AND p.id = rel.RELATIVEID
LEFT JOIN
    PERSON_EXT_ATTRS ce
ON
    ce.PERSONCENTER = p.CENTER
    AND ce.PERSONID = p.id
    AND ce.NAME = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS cp
ON
    cp.PERSONCENTER = p.CENTER
    AND cp.PERSONID = p.id
    AND cp.NAME = '_eClub_PhoneWork'