SELECT
    centers.SHORTNAME centerName,
    dataset.*,
    longtodateTZ(:FromDate, 'Europe/London') fromDate,
    longtodateTZ(:ToDate, 'Europe/London') toDate
FROM
    (
        /* NEW SECTION  - UPFRONT PAYMENT FEES */
        SELECT
            center,
            name "text",
            SUM(QUANTITY) COUNT,
            SUM(PRICE) total,
            '1. Membership sales (including VAT)' reportgroup,
            subgroup
        FROM
            (
                SELECT
                    s.CENTER,
                    CASE
                        WHEN sect.id = 1
                        THEN sect.title
                        WHEN sect.id = 2
                            AND st.ST_TYPE = 1
                        THEN sect.title
                        ELSE '5. Cash Subscriptions'
                    END AS subgroup,
                    p.NAME AS NAME,
                    CASE
                        WHEN sect.id = 1
                        THEN ss.price_new
                        WHEN sect.id = 2
                            AND st.ST_TYPE = 1
                        THEN ss.price_initial
                        ELSE ss.price_period
                    END AS PRICE,
                    1 AS QUANTITY
                FROM
                    (
                        SELECT
                            rownum AS id,
                            DECODE(rownum, 1, '1. Induction/Joining fees', 2, '2. Pro-rata') AS title,
                            DECODE(rownum, 1, 'Induction/Joining ', 2, 'Pro-rata ') AS prefix
                        FROM
                            all_objects
                        WHERE
                            rownum <= 2
                    )
                    sect,
                    PULSE.SUBSCRIPTION_SALES ss
                JOIN PULSE.SUBSCRIPTIONS s
                ON
                    s.CENTER = ss.SUBSCRIPTION_CENTER
                    AND s.ID = ss.SUBSCRIPTION_ID
                JOIN PULSE.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND st.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN PERSONS persons
                ON
                    persons.center = s.OWNER_CENTER
                    AND persons.id = s.OWNER_ID
                JOIN PULSE.PRODUCTS p
                ON
                    p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND p.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN PULSE.INVOICES i
                ON
                    i.CENTER = s.INVOICELINE_CENTER
                    AND i.ID = s.INVOICELINE_ID
                WHERE
                    s.center IN (:Scope)
                    AND s.CREATION_TIME >= :FromDate
                    AND s.CREATION_TIME < :ToDate + 60*60*1000*24
                    AND persons.persontype NOT IN (2)
                    AND
                    (
                        ss.CANCELLATION_DATE IS NULL
                        OR ss.CANCELLATION_DATE > longtodateTZ(:ToDate, 'Europe/London')
                    )
                    AND persons.PERSONTYPE NOT IN (2)
                    AND i.PAYSESSIONID IS NOT NULL
                    AND NVL(
                        CASE
                            WHEN sect.id = 1
                            THEN ss.price_new
                            WHEN sect.id = 2
                                AND st.ST_TYPE = 1
                            THEN ss.price_initial
                            ELSE ss.price_period
                        END, 0) > 0
                UNION ALL
                SELECT
                    s.CENTER,
                    '4. 30 Day Notice' subgroup,
                    p.NAME AS NAME,
                    il.TOTAL_AMOUNT AS PRICE,
                    1 AS QUANTITY
                FROM
                    PULSE.SUBSCRIPTION_SALES ss
                JOIN PULSE.SUBSCRIPTIONS s
                ON
                    s.CENTER = ss.SUBSCRIPTION_CENTER
                    AND s.ID = ss.SUBSCRIPTION_ID
                JOIN PULSE.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND st.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN PERSONS persons
                ON
                    persons.center = s.OWNER_CENTER
                    AND persons.id = s.OWNER_ID
                JOIN PULSE.PRODUCTS p
                ON
                    p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND p.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN PULSE.INVOICES i
                ON
                    i.CENTER = s.INVOICELINE_CENTER
                    AND i.ID = s.INVOICELINE_ID
                JOIN PULSE.INVOICELINES il
                ON
                    il.CENTER = i.CENTER
                    AND il.ID = i.ID
                    --                    AND il.SUBID = s.INVOICELINE_SUBID
                JOIN PULSE.PRODUCTS spd
                ON
                    spd.CENTER = il.PRODUCTCENTER
                    AND spd.id = il.PRODUCTID
                    AND spd.GLOBALID = '30_DAY_NOTICE'
                WHERE
                    s.center IN (:Scope)
                    AND s.CREATION_TIME >= :FromDate
                    AND s.CREATION_TIME < :ToDate + 60*60*1000*24
                    AND persons.persontype NOT IN (2)
                    AND
                    (
                        ss.CANCELLATION_DATE IS NULL
                        OR ss.CANCELLATION_DATE > longtodateTZ(:ToDate, 'Europe/London')
                    )
                    AND persons.PERSONTYPE NOT IN (2)
                    AND il.total_amount > 0
                    AND i.PAYSESSIONID IS NOT NULL
                UNION ALL
                SELECT
                    s.center,
                    DECODE(st.ST_TYPE, 0, '6. Cash Add-ons', 1, '3. Pro-rata (Add-ons)') AS subgroup,
                    ao_pd.name,
                    SUM(il.TOTAL_AMOUNT) AS PRICE,
                    1 AS QUANTITY
                FROM
                    INVOICES i
                JOIN PULSE.INVOICELINES il
                ON
                    i.center = il.center
                    AND i.id = il.id
                JOIN PULSE.PRODUCTS ao_pd
                ON
                    ao_pd.CENTER = il.PRODUCTCENTER
                    AND ao_pd.ID = il.PRODUCTID
                    AND ao_pd.ptype = 13
                JOIN PULSE.SPP_INVOICELINES_LINK sil
                ON
                    sil.INVOICELINE_CENTER = il.center
                    AND sil.INVOICELINE_ID = il.id
                    AND sil.INVOICELINE_SUBID = il.subid
                JOIN PULSE.SUBSCRIPTIONPERIODPARTS spp
                ON
                    spp.center = sil.PERIOD_CENTER
                    AND spp.id = sil.PERIOD_ID
                    AND spp.SUBID = sil.PERIOD_SUBID
                JOIN PULSE.SUBSCRIPTIONS s
                ON
                    s.CENTER = spp.CENTER
                    AND s.ID = spp.ID
                JOIN PULSE.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND st.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN PERSONS persons
                ON
                    persons.center = s.OWNER_CENTER
                    AND persons.id = s.OWNER_ID
                WHERE
                    i.center IN (:Scope)
                    AND i.TRANS_TIME >= :FromDate
                    AND i.TRANS_TIME < :ToDate + 60*60*1000*24
                    AND persons.PERSONTYPE NOT IN (2)
                    AND il.total_amount > 0
                    AND i.PAYSESSIONID IS NOT NULL
                GROUP BY
                    s.center,
                    s.id,
                    st.st_type,
                    ao_pd.name
                UNION ALL
                SELECT
                    s.center,
                    DECODE(st.ST_TYPE, 0, '6. Cash Add-on Services', 1, '3. Pro-rated dues (Add-on Services)') AS
                    subgroup,
                    ao_pd.name,
                    -SUM(cnl.TOTAL_AMOUNT) AS PRICE,
                    -1
                FROM
                    PULSE.CREDIT_NOTES cn
                JOIN PULSE.CREDIT_NOTE_LINES cnl
                ON
                    cn.center = cnl.center
                    AND cn.id = cnl.id
                JOIN PULSE.PRODUCTS ao_pd
                ON
                    ao_pd.CENTER = cnl.PRODUCTCENTER
                    AND ao_pd.ID = cnl.PRODUCTID
                    AND ao_pd.ptype = 13
                JOIN PULSE.SPP_INVOICELINES_LINK sil
                ON
                    sil.INVOICELINE_CENTER = cnl.INVOICELINE_CENTER
                    AND sil.INVOICELINE_ID = cnl.INVOICELINE_id
                    AND sil.INVOICELINE_SUBID = cnl.INVOICELINE_subid
                JOIN PULSE.SUBSCRIPTIONPERIODPARTS spp
                ON
                    spp.center = sil.PERIOD_CENTER
                    AND spp.id = sil.PERIOD_ID
                    AND spp.SUBID = sil.PERIOD_SUBID
                JOIN PULSE.SUBSCRIPTIONS s
                ON
                    s.CENTER = spp.CENTER
                    AND s.ID = spp.ID
                JOIN PULSE.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND st.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN PERSONS persons
                ON
                    persons.center = s.OWNER_CENTER
                    AND persons.id = s.OWNER_ID
                WHERE
                    cn.center IN (:Scope)
                    AND cn.TRANS_TIME >= :FromDate
                    AND cn.TRANS_TIME < :ToDate + 60*60*1000*24
                    AND persons.PERSONTYPE NOT IN (2)
                    AND cnl.total_amount > 0
                    AND cn.PAYSESSIONID IS NOT NULL
                GROUP BY
                    s.center,
                    s.id,
                    st.st_type,
                    ao_pd.name
            )
        GROUP BY
            center,
            name,
            subgroup
        UNION ALL

SELECT
    sales_center,
    pgname text,
    SUM(QUANTITY) COUNT,
    SUM(total_amount) tot_amount,
    '2. Other sales (including VAT)' reportgroup,
    'Other Sales' subgroup
FROM
    (
        SELECT
            i.center sales_center,
            prod.NAME pname,
            pg.NAME pgname,
            il.QUANTITY,
            ROUND(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1-(1/(1+il.RATE)))),2) excluding_Vat,
            ROUND(il.TOTAL_AMOUNT * (1-(1/(1+il.RATE))),2) included_Vat,
            ROUND(il.TOTAL_AMOUNT, 2) total_Amount
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
        JOIN PULSE.PRODUCT_GROUP pg
        ON
            pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
        WHERE
            i.CENTER = :Scope
            AND i.TRANS_TIME >= :FromDate
            AND i.TRANS_TIME < :ToDate + 60*60*1000*24
            AND i.PAYSESSIONID IS NOT NULL
            AND il.total_amount > 0
            AND prod.PTYPE IN (1,2,4,6)
			AND prod.GLOBALID != '30_DAY_NOTICE'
            AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    AR_TRANS art
                JOIN ACCOUNT_RECEIVABLES ar
                ON
                    ar.center = art.center
                    AND ar.id = art.id
                WHERE
                    art.REF_CENTER = i.CENTER
                    AND art.REF_ID = i.ID
                    AND art.REF_TYPE = 'INVOICE'
                    AND ar.AR_TYPE = 4
            )
        UNION ALL
        SELECT
            c.center sales_center,
            prod.NAME pname,
            pg.NAME pgname,
            cl.QUANTITY,
            -ROUND(cl.TOTAL_AMOUNT - ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2), 2) excluding_Vat,
            -ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2) included_Vat,
            -ROUND(cl.TOTAL_AMOUNT, 2) total_Amount
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
        JOIN PULSE.PRODUCT_GROUP pg
        ON
            pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
        WHERE
            c.CENTER =  :Scope
            AND c.TRANS_TIME >= :FromDate
            AND c.TRANS_TIME < :ToDate + 60*60*1000*24
            AND c.PAYSESSIONID IS NOT NULL
            AND cl.total_amount > 0
            AND prod.PTYPE IN (1,2,4,6)
			AND prod.GLOBALID != '30_DAY_NOTICE'
            AND NOT EXISTS
            (
                SELECT
                    *
                FROM
                    AR_TRANS art
                JOIN ACCOUNT_RECEIVABLES ar
                ON
                    ar.center = art.center
                    AND ar.id = art.id
                WHERE
                    art.REF_CENTER = c.CENTER
                    AND art.REF_ID = c.ID
                    AND art.REF_TYPE = 'CREDIT_NOTE'
                    AND ar.AR_TYPE = 4
            )
    )
GROUP BY
    sales_center,
    pgname

UNION ALL
        SELECT
            crt.center,
            'Arrears Payments' AS text,
            COUNT(*),
            SUM(crt.amount),
            '3. Arrears payments, Refunds and DDIC' reportgroup,
            '1. Centre' subgroup
        FROM
            PULSE.CASHREGISTERTRANSACTIONS crt
        JOIN PULSE.AR_TRANS art
        ON
            art.CENTER = crt.ARTRANSCENTER
            AND art.ID = crt.ARTRANSID
            AND art.SUBID = crt.ARTRANSSUBID
        JOIN PULSE.ACCOUNT_RECEIVABLES ar
        ON
            ar.center = art.center
            AND ar.id = art.id
            AND ar.AR_TYPE = 4
        WHERE
            crt.center IN (:Scope)
            AND crt.TRANSTIME >= :FromDate
            AND crt.TRANSTIME < (:ToDate + 24 * 60 * 60 * 1000)
            AND crt.AMOUNT > 0
            AND crt.crttype NOT IN (4,18)
			AND art.TEXT = 'Payment into account'
        GROUP BY
            crt.center
        UNION ALL
        SELECT
            crt.center,
            'DD Member Refunds' AS text,
            -COUNT(*),
            -SUM(crt.amount),
            '3. Arrears payments, Refunds and DDIC' reportgroup,
            '1. Centre' subgroup
        FROM
            PULSE.CASHREGISTERTRANSACTIONS crt
        JOIN PULSE.AR_TRANS art
        ON
            art.CENTER = crt.ARTRANSCENTER
            AND art.ID = crt.ARTRANSID
            AND art.SUBID = crt.ARTRANSSUBID
        JOIN PULSE.ACCOUNT_RECEIVABLES ar
        ON
            ar.center = art.center
            AND ar.id = art.id
            AND ar.AR_TYPE = 4
        WHERE
            crt.center IN (:Scope)
            AND crt.TRANSTIME >= :FromDate
            AND crt.TRANSTIME < (:ToDate + 24 * 60 * 60 * 1000)
            AND crt.AMOUNT > 0
            AND crt.crttype IN (4,18)
        GROUP BY
            crt.center
        UNION ALL

        SELECT
            tr.center,
            case when debit.GLOBALID = 'AR_PAYMENT_PERSONS' then credit.NAME else debit.name end as text,
            sum(case when debit.GLOBALID = 'AR_PAYMENT_PERSONS' then -1 else 1 end),
--            -COUNT(*),
            sum(case when debit.GLOBALID = 'AR_PAYMENT_PERSONS' then -tr.AMOUNT else tr.AMOUNT end),
--            -SUM(tr.amount),
            '3. Arrears payments, Refunds and DDIC' reportgroup,
--            case when debit.GLOBALID = 'AR_PAYMENT_PERSONS' then credit.NAME else debit.name end as subgroup,
            '2. Head office' subgroup
        FROM
            PULSE.ACCOUNT_TRANS tr
        JOIN PULSE.ACCOUNTS credit on tr.CREDIT_ACCOUNTCENTER = credit.center and tr.CREDIT_ACCOUNTID = credit.id
        JOIN PULSE.ACCOUNTS debit on tr.DEBIT_ACCOUNTCENTER = debit.center and tr.DEBIT_ACCOUNTID = debit.id
        JOIN PULSE.AR_TRANS art
        ON
            art.REF_TYPE = 'ACCOUNT_TRANS'
            and art.REF_CENTER = tr.CENTER
            and art.REF_ID = tr.ID
            and art.REF_SUBID = tr.SUBID
        JOIN PULSE.ACCOUNT_RECEIVABLES ar
        ON
            ar.center = art.center
            AND ar.id = art.id
            AND ar.AR_TYPE = 4
        WHERE
            tr.center IN (:Scope)
            AND tr.TRANS_TIME >= :FromDate
            AND tr.TRANS_TIME < (:ToDate + 24 * 60 * 60 * 1000)
--            AND tr.AMOUNT > 0
            and ((credit.GLOBALID in ('DDIC', 'DD_ARREARS_HO', 'DD_MEMBER_REFUNDS') and debit.GLOBALID = 'AR_PAYMENT_PERSONS') or (debit.GLOBALID in ('DDIC', 'DD_ARREARS_HO', 'DD_MEMBER_REFUNDS') and credit.GLOBALID = 'AR_PAYMENT_PERSONS')) 
            --and tr.text = 'DDIC'

        GROUP BY
            tr.center, case when debit.GLOBALID = 'AR_PAYMENT_PERSONS' then credit.NAME else debit.name end
        UNION ALL
        
        /* NEW SECTION  - NEW SUBSCRIPTIONS */
        SELECT
            center,
            name AS text,
            COUNT(*),
            SUM(SUBSCRIPTION_PRICE),
            DECODE(st_type, 0, '5. Evolution Cash Subscriptions (excl. staff)', 1,
            '4. Evolution Direct Debit Subscriptions (excl. staff)') reportgroup,
            subgroup
        FROM
            (
                SELECT
                    s.CENTER,
                    p.NAME,
                    s.SUBSCRIPTION_PRICE,
                    s.STATE,
                    CASE
                        WHEN st.ST_TYPE = 1
                            AND st.IS_ADDON_SUBSCRIPTION = 1
                        THEN '2. New DD Add-on Subscriptions'
                        WHEN st.ST_TYPE = 0
                            AND st.IS_ADDON_SUBSCRIPTION = 1
                        THEN '2. New Cash Add-on Subscriptions'
                        WHEN st.ST_TYPE = 1
                        THEN '1. New DD Subscriptions'
                        WHEN st.ST_TYPE = 0
                        THEN '1. New Cash Subscriptions'
                        ELSE 'Error'
                    END subgroup,
                    st.st_type
                FROM
                    PULSE.SUBSCRIPTIONS s
                JOIN PULSE.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND st.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN PERSONS persons
                ON
                    persons.center = s.OWNER_CENTER
                    AND persons.id = s.OWNER_ID
                JOIN PULSE.PRODUCTS p
                ON
                    p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND p.ID = s.SUBSCRIPTIONTYPE_ID
                WHERE
                    s.center IN (:Scope)
                    AND s.start_DATE >= longtodateTZ(:FromDate, 'Europe/London')
                    AND s.start_date <= longtodateTZ(:ToDate, 'Europe/London')
                    AND
                    (
                        s.end_date IS NULL
                        OR s.end_date > longtodateTZ(:ToDate, 'Europe/London')
                    )
                    AND persons.persontype NOT IN (2)
                    --AND st.st_type = 1
            )
        GROUP BY
            center,
            name,
            subgroup,
            st_type
        UNION ALL
        SELECT
            center,
            name AS text,
            -COUNT(*),
            -SUM(SUBSCRIPTION_PRICE),
            DECODE(st_type, 0, '5. Evolution Cash Subscriptions (excl. staff)', 1,
            '4. Evolution Direct Debit Subscriptions (excl. staff)') reportgroup,
            subgroup
        FROM
            (
                SELECT
                    s.CENTER,
                    p.NAME,
                    s.SUBSCRIPTION_PRICE,
                    CASE
                        WHEN st.ST_TYPE = 1
                            AND st.IS_ADDON_SUBSCRIPTION = 1
                        THEN '5. Ended DD Add-on Subscriptions'
                        WHEN st.ST_TYPE = 0
                            AND st.IS_ADDON_SUBSCRIPTION = 1
                        THEN '5. Ended Cash Add-on Subscriptions'
                        WHEN st.ST_TYPE = 1
                        THEN '4. Ended DD Subscriptions'
                        WHEN st.ST_TYPE = 0
                        THEN '4. Ended Cash Subscriptions'
                        ELSE 'Error'
                    END subgroup,
                    st.st_type
                FROM
                    PULSE.SUBSCRIPTIONS s
                JOIN PULSE.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND st.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN PERSONS persons
                ON
                    persons.center = s.OWNER_CENTER
                    AND persons.id = s.OWNER_ID
                JOIN PULSE.PRODUCTS p
                ON
                    p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND p.ID = s.SUBSCRIPTIONTYPE_ID
                WHERE
                    s.center IN (:Scope)
                    AND s.END_DATE >= longtodateTZ(:FromDate, 'Europe/London')
                    AND s.END_DATE <= longtodateTZ(:ToDate, 'Europe/London')
                    AND persons.persontype NOT IN (2)
                    AND s.end_date >= s.start_date
                    --                AND s.START_DATE < longtodateTZ(:FromDate, 'Europe/London')
            )
        GROUP BY
            center,
            name,
            subgroup,
            st_type
        UNION ALL
        
        /* NEW SECTION  - NEW SUBSCRIPTION ADD_ONS */
        SELECT
            center,
            name AS text,
            COUNT(*),
            SUM(price),
            DECODE(st_type, 0, '5. Evolution Cash Subscriptions (excl. staff)', 1,
            '4. Evolution Direct Debit Subscriptions (excl. staff)') reportgroup,
            DECODE(st_type, 0, '3. New Cash Add-on Services', 1, '3. New DD Add-on Services') subgroup
        FROM
            (
                SELECT
                    addons.SUBSCRIPTION_CENTER center,
                    p.CACHED_PRODUCTNAME name,
                    p.CACHED_PRODUCTPRICE price,
                    st.st_type
                FROM
                    PULSE.SUBSCRIPTION_ADDON addons
                JOIN SUBSCRIPTIONS s
                ON
                    s.center = addons.SUBSCRIPTION_CENTER
                    AND s.id = addons.SUBSCRIPTION_ID
                JOIN PULSE.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND st.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN PERSONS persons
                ON
                    persons.center = s.OWNER_CENTER
                    AND persons.id = s.OWNER_ID
                JOIN PULSE.MASTERPRODUCTREGISTER p
                ON
                    p.ID = addons.ADDON_PRODUCT_ID
                WHERE
                    addons.SUBSCRIPTION_CENTER IN (:Scope)
                    AND addons.START_DATE >= longtodateTZ(:FromDate, 'Europe/London')
                    AND addons.START_DATE <= longtodateTZ(:ToDate, 'Europe/London')
                    AND
                    (
                        addons.END_DATE IS NULL
                        OR addons.END_DATE > longtodateTZ(:ToDate, 'Europe/London')
                    )
                    AND persons.persontype NOT IN (2)
                    AND addons.CANCELLED = 0
            )
        GROUP BY
            center,
            name,
            st_type
        UNION ALL
        
        /* NEW SECTION  - ENDED SUBSCRIPTION ADD_ONS */
        SELECT
            center,
            name AS text,
            -COUNT(*),
            -SUM(price),
            DECODE(st_type, 0, '5. Evolution Cash Subscriptions (excl. staff)', 1,
            '4. Evolution Direct Debit Subscriptions (excl. staff)') reportgroup,
            DECODE(st_type, 0, '6. Ended Cash Add-on Services', 1, '6. Ended DD Add-on Services') subgroup
        FROM
            (
                SELECT
                    addons.SUBSCRIPTION_CENTER center,
                    p.CACHED_PRODUCTNAME name,
                    p.CACHED_PRODUCTPRICE price,
                    st.st_type
                FROM
                    PULSE.SUBSCRIPTION_ADDON addons
                JOIN SUBSCRIPTIONS s
                ON
                    s.center = addons.SUBSCRIPTION_CENTER
                    AND s.id = addons.SUBSCRIPTION_ID
                JOIN PULSE.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND st.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN PERSONS persons
                ON
                    persons.center = s.OWNER_CENTER
                    AND persons.id = s.OWNER_ID
                JOIN PULSE.MASTERPRODUCTREGISTER p
                ON
                    p.ID = addons.ADDON_PRODUCT_ID
                WHERE
                    addons.SUBSCRIPTION_CENTER IN (:Scope)
                    AND addons.END_DATE >= longtodateTZ(:FromDate, 'Europe/London')
                    AND addons.END_DATE <= longtodateTZ(:ToDate, 'Europe/London')
                    AND addons.START_DATE < longtodateTZ(:FromDate, 'Europe/London')
                    AND addons.cancelled = 0
                    AND persons.persontype NOT IN (2)
            )
        GROUP BY
            center,
            name,
            st_type
        UNION ALL
        
        /* NEW SECTION  - PAYMENT REQUESTS SENT*/
        SELECT
            pr.center,
            TO_CHAR(pr.REQ_DATE, 'yyyy-mm-dd') text,
            -COUNT(*) COUNT,
            -SUM(pr.REQ_AMOUNT) total,
            '6.1 Direct Debit Summary' reportgroup,
            '1. Sent' subgroup
        FROM
            PULSE.PAYMENT_REQUESTS pr
        WHERE
            pr.REQ_DATE >= (longtodateTZ(:FromDate, 'Europe/London'))
            AND pr.REQ_DATE <= longtodateTZ(:ToDate, 'Europe/London')
            --AND pr.STATE NOT IN (8,12)
            AND pr.center IN (:Scope)
        GROUP BY
            pr.center,
            pr.REQ_DATE
        UNION ALL
        
        /* NEW SECTION  - PAYMENT REQUESTS STATUS*/
        SELECT
            pr.center,
            TO_CHAR(pr.REQ_DATE, 'yyyy-mm-dd') text,
            COUNT(*) COUNT,
            SUM(pr.REQ_AMOUNT) total,
            '6.1 Direct Debit Summary' reportgroup,
            CASE
                WHEN pr.state IN (3,4,18)
                THEN '2. Paid'
                WHEN pr.state IN (5,6,7,17)
                THEN '3. Unpaid'
                ELSE 'Error'
            END subgroup
        FROM
            PULSE.PAYMENT_REQUESTS pr
        WHERE
            pr.REQ_DATE >= longtodateTZ(:FromDate, 'Europe/London')
            AND pr.REQ_DATE <= longtodateTZ(:ToDate, 'Europe/London')
            AND pr.STATE NOT IN (8,10,11,12,14)
            AND pr.center IN (:Scope)
        GROUP BY
            pr.center,
            pr.REQ_DATE,
            pr.state
        UNION ALL
        
        /* NEW SECTION  - UNPAID REASON CODES */
        SELECT
            pr.center,
            pr.XFR_INFO text,
            COUNT(*) COUNT,
            SUM(pr.REQ_AMOUNT) total,
            '6.2 Direct Debit Unpaid' reportgroup,
            'Unpaid reason codes' subgroup
        FROM
            PULSE.PAYMENT_REQUESTS pr
        WHERE
            pr.REQ_DATE >= longtodateTZ(:FromDate, 'Europe/London')
            AND pr.REQ_DATE <= longtodateTZ(:ToDate, 'Europe/London')
            AND pr.state IN (5,6,7,17)
            AND pr.center IN (:Scope)
        GROUP BY
            pr.center,
            pr.XFR_INFO
    )
    dataset
JOIN PULSE.CENTERS centers
ON
    centers.ID = dataset.center
ORDER BY
    6,7,3