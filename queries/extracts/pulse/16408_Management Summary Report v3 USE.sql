WITH
    params AS materialized
    (
        SELECT
            id                                                                                                  AS centerid,
            datetolongc(TO_CHAR(to_date(:Fromdate,'YYYY-MM-DD'),'YYYY-MM-DD'),id)  ::bigint                     AS from_epoch,
            datetolongc(TO_CHAR(to_date(:Todate,'YYYY-MM-DD'),'YYYY-MM-DD'),id) ::bigint + 24*3600*1000         AS to_epoch,
            :Fromdate ::date                                                                                    AS from_date,
            :Todate ::date                                                                                      AS to_date,
            shortname                                                                                           AS shortname
        FROM 
                centers 
        WHERE 
                id in (:scope)
         
    )


SELECT
    params.SHORTNAME as "CENTERNAME",
    dataset.center as "CENTER",
    dataset.text as "TEXT",
    cast(dataset.count as DECIMAL) as "COUNT",
    dataset.total as "TOTAL",
    dataset.reportgroup as "REPORTGROUP",
    dataset.subgroup as "SUBGROUP",
    params.From_Date "FROMDATE",
    params.To_Date   "TODATE"
FROM
    (
    
/* 
UPFRONT PAYMENT FEES 
1. Membership sales (including VAT) 
*/
        SELECT
            center,
            name                                  "text",
            SUM(QUANTITY)                         COUNT,
            SUM(PRICE)                            total,
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
                    END    AS subgroup,
                    p.NAME AS NAME,
                    CASE
                        WHEN sect.id = 1
                        THEN ss.price_new
                        WHEN sect.id = 2
                        AND st.ST_TYPE = 1
                        THEN ss.price_initial
                        WHEN sect.id = 2
                        AND st.ST_TYPE = 0
                        AND ss.price_initial <> ss.price_period
                        THEN ss.price_initial
                        ELSE ss.price_period
                    END AS PRICE,
                    1   AS QUANTITY
                FROM
                    (
                        SELECT
                            1                           AS id,
                            '1. Induction/Joining fees' AS title,
                            'Induction/Joining '        AS prefix
                            
/* 
2. Pro-rata 
*/                            
                        UNION ALL
                SELECT
                            2             AS id,
                            '2. Pro-rata' AS title,
                            'Pro-rata'    AS prefix ) sect,
                    PULSE.SUBSCRIPTION_SALES ss
                JOIN
                    PULSE.SUBSCRIPTIONS s
                ON
                    s.CENTER = ss.SUBSCRIPTION_CENTER
                AND s.ID = ss.SUBSCRIPTION_ID
                JOIN
                    PULSE.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                AND st.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN
                    PERSONS PERSONS
                ON
                    PERSONS.center = s.OWNER_CENTER
                AND PERSONS.id = s.OWNER_ID
                JOIN
                    PULSE.PRODUCTS p
                ON
                    p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                AND p.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN
                    PULSE.INVOICES i
                ON
                    i.CENTER = s.INVOICELINE_CENTER
                AND i.ID = s.INVOICELINE_ID
                
                join params on s.center = params.centerid
                
                WHERE
                s.CREATION_TIME >= params.from_epoch
                AND s.CREATION_TIME < params.to_epoch
                AND (
                        ss.CANCELLATION_DATE IS NULL
                    OR  ss.CANCELLATION_DATE > params.to_date )
                AND COALESCE(
                        CASE
                            WHEN sect.id = 1
                            THEN ss.price_new
                            WHEN sect.id = 2
                            AND st.ST_TYPE = 1
                            THEN ss.price_initial
                            ELSE ss.price_period
                        END, 0) > 0
                        
/* 4. 30 Day Notice */                         
                        UNION ALL
                SELECT
                    s.CENTER,
                    '4. 30 Day Notice'    subgroup,
                    p.NAME             AS NAME,
                    il.TOTAL_AMOUNT    AS PRICE,
                    1                  AS QUANTITY
                FROM
                    PULSE.SUBSCRIPTION_SALES ss
                JOIN
                    PULSE.SUBSCRIPTIONS s
                ON
                    s.CENTER = ss.SUBSCRIPTION_CENTER
                AND s.ID = ss.SUBSCRIPTION_ID
                JOIN
                    PULSE.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                AND st.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN
                    PERSONS PERSONS
                ON
                    PERSONS.center = s.OWNER_CENTER
                AND PERSONS.id = s.OWNER_ID
                JOIN
                    PULSE.PRODUCTS p
                ON
                    p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                AND p.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN
                    PULSE.INVOICES i
                ON
                    i.CENTER = s.INVOICELINE_CENTER
                AND i.ID = s.INVOICELINE_ID
                JOIN
                invoice_lines_mt il 
                ON il.center = i.center
                AND il.id = i.id
                JOIN
                    PULSE.PRODUCTS spd
                ON
                    spd.CENTER = il.PRODUCTCENTER
                AND spd.id = il.PRODUCTID
                AND spd.GLOBALID = '30_DAY_NOTICE'
                
                join params on s.center = params.centerid
                    
                WHERE
                s.CREATION_TIME >= params.from_epoch
                AND s.CREATION_TIME < params.to_epoch
                AND (
                        ss.CANCELLATION_DATE IS NULL
                    OR  ss.CANCELLATION_DATE > params.to_date )    
                AND il.total_amount > 0
                
/* 6. Cash Add-ons */               
                        UNION ALL
                SELECT
                    s.center,
                    CASE st.ST_TYPE
                        WHEN 0
                        THEN '6. Cash Add-ons'
                        WHEN 1
                        THEN '3. Pro-rata (Add-ons)'
                    END AS subgroup,
                    ao_pd.name,
                    SUM(il.TOTAL_AMOUNT) AS PRICE,
                    1                    AS QUANTITY
                FROM
                    INVOICES i
                JOIN
                invoice_lines_mt il 
                ON il.center = i.center
                AND il.id = i.id
                JOIN
                    PULSE.PRODUCTS ao_pd
                ON
                    ao_pd.CENTER = il.PRODUCTCENTER
                AND ao_pd.ID = il.PRODUCTID
                AND ao_pd.ptype = 13
                JOIN
                    PULSE.SPP_INVOICELINES_LINK sil
                ON
                    sil.INVOICELINE_CENTER = il.center
                AND sil.INVOICELINE_ID = il.id
                AND sil.INVOICELINE_SUBID = il.subid
                JOIN
                    PULSE.SUBSCRIPTIONPERIODPARTS spp
                ON
                    spp.center = sil.PERIOD_CENTER
                AND spp.id = sil.PERIOD_ID
                AND spp.SUBID = sil.PERIOD_SUBID
                JOIN
                    PULSE.SUBSCRIPTIONS s
                ON
                    s.CENTER = spp.CENTER
                AND s.ID = spp.ID
                JOIN
                    PULSE.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                AND st.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN
                    PERSONS PERSONS
                ON
                    PERSONS.center = s.OWNER_CENTER
                AND PERSONS.id = s.OWNER_ID
                
                join params on i.center = params.centerid
                
                WHERE
                i.TRANS_TIME >= params.from_epoch
                AND i.TRANS_TIME < params.to_epoch
                AND il.total_amount > 0
                GROUP BY
                    s.center,
                    s.id,
                    st.st_type,
                    ao_pd.name
                    
/* 
6. Cash Add-on Services  
3. Pro-rated dues (Add-on Services) 
*/              
                        UNION ALL
                SELECT
                    s.center,
                    CASE st.ST_TYPE
                        WHEN 0
                        THEN '6. Cash Add-on Services'
                        WHEN 1
                        THEN '3. Pro-rated dues (Add-on Services)'
                    END AS subgroup,
                    ao_pd.name,
                    -SUM(cnl.TOTAL_AMOUNT) AS PRICE,
                    -1
                FROM
                    PULSE.CREDIT_NOTES cn
                JOIN
                    PULSE.CREDIT_NOTE_LINES cnl
                ON
                    cn.center = cnl.center
                AND cn.id = cnl.id
                JOIN
                    PULSE.PRODUCTS ao_pd
                ON
                    ao_pd.CENTER = cnl.PRODUCTCENTER
                AND ao_pd.ID = cnl.PRODUCTID
                AND ao_pd.ptype = 13
                JOIN
                    PULSE.SPP_INVOICELINES_LINK sil
                ON
                    sil.INVOICELINE_CENTER = cnl.INVOICELINE_CENTER
                AND sil.INVOICELINE_ID = cnl.INVOICELINE_id
                AND sil.INVOICELINE_SUBID = cnl.INVOICELINE_subid
                JOIN
                    PULSE.SUBSCRIPTIONPERIODPARTS spp
                ON
                    spp.center = sil.PERIOD_CENTER
                AND spp.id = sil.PERIOD_ID
                AND spp.SUBID = sil.PERIOD_SUBID
                JOIN
                    PULSE.SUBSCRIPTIONS s
                ON
                    s.CENTER = spp.CENTER
                AND s.ID = spp.ID
                JOIN
                    PULSE.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                AND st.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN
                    PERSONS PERSONS
                ON
                    PERSONS.center = s.OWNER_CENTER
                AND PERSONS.id = s.OWNER_ID
                
                join params on cn.center = params.centerid
                
                WHERE
                cn.TRANS_TIME >= params.from_epoch
                AND cn.TRANS_TIME < params.to_epoch
                AND cnl.total_amount > 0
                GROUP BY
                    s.center,
                    s.id,
                    st.st_type,
                    ao_pd.name ) t1
        GROUP BY
            center,
            name,
            subgroup
            
/* 
Other Sales
*/           
                UNION ALL
        SELECT
            sales_center,
            pgname        "text",
            SUM(QUANTITY)                    COUNT,
            SUM(total_amount)                tot_amount,
            '2. Other sales (including VAT)' reportgroup,
            'Other Sales'                    subgroup
        FROM
            (
                SELECT
                    i.center  sales_center,
                    prod.NAME pname,
                    pg.NAME   pgname,
                    il.QUANTITY,
                                        ROUND(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1-(1/(1+ilv.RATE)))),2)
                                                                   excluding_Vat,
                    ROUND(il.TOTAL_AMOUNT * (1-(1/(1+ilv.RATE))),2) included_Vat,
                    ROUND(il.TOTAL_AMOUNT, 2)                      total_Amount
                FROM
                    INVOICES i                
                    
                JOIN
                invoice_lines_mt il 
                ON il.center = i.center
                AND il.id = i.id
                                
                left JOIN
                INVOICELINES_VAT_AT_LINK ilv
                ON
                il.CENTER = ilv.invoiceline_CENTER
                AND il.id = ilv.invoiceline_id
                AND il.subid = ilv.invoiceline_subid
                JOIN
                    PRODUCTS prod
                ON
                    prod.center = il.PRODUCTCENTER
                AND prod.id = il.PRODUCTID
                JOIN
                    PULSE.PRODUCT_GROUP pg
                ON
                    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
                join params on i.center = params.centerid
                
                WHERE
                i.TRANS_TIME >= params.from_epoch
                AND i.TRANS_TIME < params.to_epoch
                AND il.total_amount > 0
                AND prod.PTYPE IN (1, 2, 4, 6, 14)
                AND prod.GLOBALID != '30_DAY_NOTICE'
                AND NOT EXISTS
                    (
                        SELECT
                            *
                        FROM
                            AR_TRANS art
                        JOIN
                            ACCOUNT_RECEIVABLES ar
                        ON
                            ar.center = art.center
                        AND ar.id = art.id
                        WHERE
                            art.REF_CENTER = i.CENTER
                        AND art.REF_ID = i.ID
                        AND art.REF_TYPE = 'INVOICE'
                        AND ar.AR_TYPE = 4 )
                        
                UNION ALL
                SELECT
                    c.center  sales_center,
                    prod.NAME pname,
                    pg.NAME   pgname,
                    cl.QUANTITY,
                    -ROUND(cl.TOTAL_AMOUNT - ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2), 2)
                                                                     excluding_Vat,
                    -ROUND(cl.TOTAL_AMOUNT * (1-(1/(1+cl.RATE))), 2) included_Vat,
                    -ROUND(cl.TOTAL_AMOUNT, 2)                       total_Amount
                FROM
                    CREDIT_NOTES c
                JOIN
                    CREDIT_NOTE_LINES cl
                ON
                    cl.center = c.center
                AND cl.id = c.id
                JOIN
                    PRODUCTS prod
                ON
                    prod.center = cl.PRODUCTCENTER
                AND prod.id = cl.PRODUCTID
                JOIN
                    PULSE.PRODUCT_GROUP pg
                ON
                    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
                    
                join params on c.center = params.centerid    
                    
                WHERE
                c.TRANS_TIME >= params.from_epoch
                AND c.TRANS_TIME < params.to_epoch
                AND cl.total_amount > 0
                AND prod.PTYPE IN (1,2,4,6)
                AND prod.GLOBALID != '30_DAY_NOTICE'
                AND NOT EXISTS
                    (
                        SELECT
                            *
                        FROM
                            AR_TRANS art
                        JOIN
                            ACCOUNT_RECEIVABLES ar
                        ON
                            ar.center = art.center
                        AND ar.id = art.id
                        WHERE
                            art.REF_CENTER = c.CENTER
                        AND art.REF_ID = c.ID
                        AND art.REF_TYPE = 'CREDIT_NOTE'
                        AND ar.AR_TYPE = 4 ) ) t2
        GROUP BY
            sales_center,
            pgname
/*
Arrears Payments
3. Arrears payments, Refunds and DDIC
1. Centre
*/            
                UNION ALL
        SELECT
            crt.center,
            'Arrears Payments' AS "text",
            COUNT(*),
            SUM(crt.amount),
            '3. Arrears payments, Refunds and DDIC' reportgroup,
            '1. Centre'                             subgroup
        FROM
            PULSE.CASHREGISTERTRANSACTIONS crt
        JOIN
            PULSE.AR_TRANS art
        ON
            art.CENTER = crt.ARTRANSCENTER
        AND art.ID = crt.ARTRANSID
        AND art.SUBID = crt.ARTRANSSUBID
        JOIN
            PULSE.ACCOUNT_RECEIVABLES ar
        ON
            ar.center = art.center
        AND ar.id = art.id
        AND ar.AR_TYPE = 4
        
        join params on crt.center = params.centerid

        WHERE
        crt.TRANSTIME >= params.from_epoch
        AND crt.TRANSTIME < params.to_epoch
        AND crt.AMOUNT > 0
        AND crt.crttype NOT IN (4,18,2)
        AND art.TEXT = 'Payment into account'
        GROUP BY
            crt.center
            
/*
DD Member Refunds
3. Arrears payments, Refunds and DDIC
1. Centre
*/            
                UNION ALL
        SELECT
            crt.center,
            'DD Member Refunds' AS "text",
            -COUNT(*),
            -SUM(crt.amount),
            '3. Arrears payments, Refunds and DDIC' reportgroup,
            '1. Centre'                             subgroup
        FROM
            PULSE.CASHREGISTERTRANSACTIONS crt
        JOIN
            PULSE.AR_TRANS art
        ON
            art.CENTER = crt.ARTRANSCENTER
        AND art.ID = crt.ARTRANSID
        AND art.SUBID = crt.ARTRANSSUBID
        JOIN
            PULSE.ACCOUNT_RECEIVABLES ar
        ON
            ar.center = art.center
        AND ar.id = art.id
        AND ar.AR_TYPE = 4
        
        join params on crt.center = params.centerid   
             
        WHERE
        crt.TRANSTIME >= params.from_epoch
        AND crt.TRANSTIME < params.to_epoch
        AND crt.AMOUNT > 0
        AND crt.crttype IN (4,18)
        GROUP BY
            crt.center

/*
3. Arrears payments, Refunds and DDIC
2. Head office
*/            
                UNION ALL
        SELECT
            tr.center,
            CASE
                WHEN debit.GLOBALID in ('AR_PAYMENT_PERSONS','AR_CASH')
                THEN credit.NAME
                ELSE debit.name
            END AS "text",
            SUM(
                CASE
                    WHEN debit.GLOBALID in ('AR_PAYMENT_PERSONS','AR_CASH')
                    THEN -1
                    ELSE 1
                END),
            SUM(
                CASE
                    WHEN debit.GLOBALID in ('AR_PAYMENT_PERSONS','AR_CASH')
                    THEN -tr.AMOUNT
                    ELSE tr.AMOUNT
                END),
            '3. Arrears payments, Refunds and DDIC' reportgroup,
            '2. Head office' subgroup
        FROM
            PULSE.ACCOUNT_TRANS tr
        JOIN
            PULSE.ACCOUNTS credit
        ON
            tr.CREDIT_ACCOUNTCENTER = credit.center
        AND tr.CREDIT_ACCOUNTID = credit.id
        JOIN
            PULSE.ACCOUNTS debit
        ON
            tr.DEBIT_ACCOUNTCENTER = debit.center
        AND tr.DEBIT_ACCOUNTID = debit.id
        JOIN
            PULSE.AR_TRANS art
        ON
            art.REF_TYPE = 'ACCOUNT_TRANS'
        AND art.REF_CENTER = tr.CENTER
        AND art.REF_ID = tr.ID
        AND art.REF_SUBID = tr.SUBID
        JOIN
            PULSE.ACCOUNT_RECEIVABLES ar
        ON
            ar.center = art.center
        AND ar.id = art.id
        AND ar.AR_TYPE in (1,4)
        
        join params on tr.center = params.centerid
                
        WHERE
        tr.TRANS_TIME >= params.from_epoch
        AND tr.TRANS_TIME < params.to_epoch
		AND (ar.AR_TYPE = 4 OR (ar.AR_TYPE = 1 AND art.employeecenter = 100))
        AND ((
                    credit.GLOBALID IN ('DDIC',
                                        'DD_ARREARS_HO',
                                        'DD_MEMBER_REFUNDS')
                AND debit.GLOBALID in ('AR_PAYMENT_PERSONS','AR_CASH'))
            OR  (
                    debit.GLOBALID IN ('DDIC',
                                       'DD_ARREARS_HO',
                                       'DD_MEMBER_REFUNDS')
                AND credit.GLOBALID IN ('AR_PAYMENT_PERSONS','AR_CASH')))
        GROUP BY
            tr.center,
            CASE
                WHEN debit.GLOBALID in ('AR_PAYMENT_PERSONS','AR_CASH')
                THEN credit.NAME
                ELSE debit.name
            END

/*
PAYMENT REQUESTS SENT  
4.1 Direct Debit Summary   
1. Sent
*/       
                UNION ALL
        SELECT
            pr.center,
            TO_CHAR(pr.REQ_DATE, 'yyyy-mm-dd') "text",
            -COUNT(*)                                           COUNT,
            -SUM(pr.REQ_AMOUNT)                                 total,
            '4.1 Direct Debit Summary'                          reportgroup,
            '1. Sent'                                           subgroup
        FROM
            PULSE.PAYMENT_REQUESTS pr
        
        join params on pr.center = params.centerid    
            
        WHERE
            pr.REQ_DATE >= params.from_date
        AND pr.REQ_DATE <= params.to_date
        AND pr.REQUEST_TYPE = 1
        AND pr.STATE NOT IN (8,10,11,12,13,14)
	AND pr.clearinghouse_id IN (1406,1402,3207,2607,201,604,3808,802,1002,602,603,2207,202,2008,3407,1607,1403,1407,1202,2009,2407,1,1003,2807,402,1203,1404,4207,4208,1405,3007)
        GROUP BY
            pr.center,
            pr.REQ_DATE
            
/*
PAYMENT REQUESTS STATUS
4.1 Direct Debit Summary
2. Paid + 3. Unpaid + Error
*/            
                UNION ALL
        SELECT
            pr.center,
            TO_CHAR(pr.REQ_DATE, 'yyyy-mm-dd') "text",
            COUNT(*)                                             COUNT,
            SUM(pr.REQ_AMOUNT)                                   total,
            '4.1 Direct Debit Summary'                           reportgroup,
            CASE
                WHEN pr.state IN (3,4,18)
                THEN '2. Paid'
                WHEN pr.state IN (5,6,7,17)
                THEN '3. Unpaid'
                ELSE 'Error'
            END subgroup
        FROM
            PULSE.PAYMENT_REQUESTS pr
            
        join params on pr.center = params.centerid    
            
        WHERE
            pr.REQ_DATE >= params.from_date
        AND pr.REQ_DATE <= params.to_date
        AND pr.REQUEST_TYPE = 1
        AND pr.STATE NOT IN (8,10,11,12,13,14)
	AND pr.clearinghouse_id IN (1406,1402,3207,2607,201,604,3808,802,1002,602,603,2207,202,2008,3407,1607,1403,1407,1202,2009,2407,1,1003,2807,402,1203,1404,4207,4208,1405,3007)
        GROUP BY
            pr.center,
            pr.REQ_DATE,
            pr.state
            
/*
UNPAID REASON CODES
4.2 Direct Debit Unpaid
Unpaid reason codes
*/            
                UNION ALL
        SELECT
            pr.center,
            pr.XFR_INFO "text",
            COUNT(*)                     COUNT,
            SUM(pr.REQ_AMOUNT)           total,
            '4.2 Direct Debit Unpaid'    reportgroup,
            'Unpaid reason codes'        subgroup
        FROM
            PULSE.PAYMENT_REQUESTS pr

        join params on pr.center = params.centerid    
            
        WHERE
            pr.REQ_DATE >= params.from_date
        AND pr.REQ_DATE <= params.to_date
        AND pr.REQUEST_TYPE IN (1,6)
        AND pr.state IN (5,6,7,17)
	AND pr.clearinghouse_id IN (1406,1402,3207,2607,201,604,3808,802,1002,602,603,2207,202,2008,3407,1607,1403,1407,1202,2009,2407,1,1003,2807,402,1203,1404,4207,4208,1405,3007)
        GROUP BY
            pr.center,
            pr.XFR_INFO
            
/*
REPRESENTATIONS SENT   
4.1 Direct Debit Summary
1. Sent
*/         
                UNION ALL
        SELECT
            pr.center,
            TO_CHAR(pr.REQ_DATE, 'yyyy-mm-dd') "text",
            -COUNT(*)                                           COUNT,
            -SUM(pr.REQ_AMOUNT)                                 total,
            '4.1 Direct Debit Summary'                          reportgroup,
            '1. Sent'                                           subgroup
        FROM
            PULSE.PAYMENT_REQUESTS pr
            
        join params on pr.center = params.centerid    
            
        WHERE
            pr.REQ_DATE >= params.from_date
        AND pr.REQ_DATE <= params.to_date
        AND pr.REQUEST_TYPE = 6
        AND pr.STATE NOT IN (8,10,11,12,13,14)
	AND pr.clearinghouse_id IN (1406,1402,3207,2607,201,604,3808,802,1002,602,603,2207,202,2008,3407,1607,1403,1407,1202,2009,2407,1,1003,2807,402,1203,1404,4207,4208,1405,3007)
        GROUP BY
            pr.center,
            pr.REQ_DATE
            
/*
REPRESENTATIONS STATUS  
4.1 Direct Debit Summary
2. Paid + 3. Unpaid + Error
*/          
                UNION ALL
        SELECT
            pr.center,
            TO_CHAR(pr.REQ_DATE, 'yyyy-mm-dd') "text",
            COUNT(*)                                             COUNT,
            SUM(pr.REQ_AMOUNT)                                   total,
            '4.1 Direct Debit Summary'                           reportgroup,
            CASE
                WHEN pr.state IN (3,4,18)
                THEN '2. Paid'
                WHEN pr.state IN (5,6,7,17)
                THEN '3. Unpaid'
                ELSE 'Error'
            END subgroup
        FROM
            PULSE.PAYMENT_REQUESTS pr
            
        join params on pr.center = params.centerid    
            
        WHERE
            pr.REQ_DATE >= params.from_date
        AND pr.REQ_DATE <= params.to_date
        AND pr.REQUEST_TYPE = 6
        AND pr.STATE NOT IN (8,10,11,12,13,14)
	AND pr.clearinghouse_id IN (1406,1402,3207,2607,201,604,3808,802,1002,602,603,2207,202,2008,3407,1607,1403,1407,1202,2009,2407,1,1003,2807,402,1203,1404,4207,4208,1405,3007)
        GROUP BY
            pr.center,
            pr.REQ_DATE,
            pr.state
            
/*
ADYEN PAYMENT REQUESTS SENT
5.1 Adyen Summary
1. Sent
*/            
                UNION ALL
        SELECT
            pr.center,
            TO_CHAR(pr.REQ_DATE, 'yyyy-mm-dd') "text",
            -COUNT(*)                                           COUNT,
            -SUM(pr.REQ_AMOUNT)                                 total,
            '5.1 Adyen Summary'                                 reportgroup,
            '1. Sent'                                           subgroup
        FROM
            PULSE.PAYMENT_REQUESTS pr
            
        join params on pr.center = params.centerid    
            
        WHERE
            pr.REQ_DATE >= params.from_date
        AND pr.REQ_DATE <= params.to_date
        AND pr.REQUEST_TYPE = 1
        AND pr.STATE NOT IN (8,10,11,12,13,14)
		AND pr.clearinghouse_id IN (4608,4808,4607,4807,4007,4809,4609,5007,5408,5409,5410,5607)
        GROUP BY
            pr.center,
            pr.REQ_DATE
            
/*
ADYEN PAYMENT REQUESTS STATUS
5.1 Adyen Summary
2. Paid + 3. Unpaid + Error
*/            
                UNION ALL
        SELECT
            pr.center,
            TO_CHAR(pr.REQ_DATE, 'yyyy-mm-dd') "text",
            COUNT(*)                                             COUNT,
            SUM(pr.REQ_AMOUNT)                                   total,
            '5.1 Adyen Summary'                                  reportgroup,
            CASE
                WHEN pr.state IN (3,4,18)
                THEN '2. Paid'
                WHEN pr.state IN (5,6,7,17)
                THEN '3. Unpaid'
                ELSE 'Error'
            END subgroup
        FROM
            PULSE.PAYMENT_REQUESTS pr
            
        join params on pr.center = params.centerid    
            
        WHERE
            pr.REQ_DATE >= params.from_date
        AND pr.REQ_DATE <= params.to_date
        AND pr.REQUEST_TYPE = 1
        AND pr.STATE NOT IN (8,10,11,12,13,14)
	AND pr.clearinghouse_id IN (4608,4808,4607,4807,4007,4809,4609,5007,5408,5409,5410,5607)
        GROUP BY
            pr.center,
            pr.REQ_DATE,
            pr.state
            
/*
ADYEN UNPAID REASON CODES
5.2 Adyen Unpaid
Unpaid reason codes
*/            
                UNION ALL
        SELECT
            pr.center,
            pr.XFR_INFO "text",
            COUNT(*)                     COUNT,
            SUM(pr.REQ_AMOUNT)           total,
            '5.2 Adyen Unpaid'    reportgroup,
            'Unpaid reason codes'        subgroup
        FROM
            PULSE.PAYMENT_REQUESTS pr
            
        join params on pr.center = params.centerid    
            
        WHERE
            pr.REQ_DATE >= params.from_date
        AND pr.REQ_DATE <= params.to_date
        AND pr.REQUEST_TYPE IN (1,6)
        AND pr.state IN (5,6,7,17)
		AND pr.clearinghouse_id IN (4608,4808,4607,4807,4007,4809,4609,5007,5408,5409,5410,5607)
        GROUP BY
            pr.center,
            pr.XFR_INFO
            
/*
ADYEN REPRESENTATIONS SENT  
5.1 Adyen Summary    
1. Sent
*/      
                UNION ALL
        SELECT
            pr.center,
            TO_CHAR(pr.REQ_DATE, 'yyyy-mm-dd')                  "text",
            -COUNT(*)                                           COUNT,
            -SUM(pr.REQ_AMOUNT)                                 total,
            '5.1 Adyen Summary'                                 reportgroup,
            '1. Sent'                                           subgroup
        FROM
            PULSE.PAYMENT_REQUESTS pr
            
        join params on pr.center = params.centerid
            
        WHERE
            pr.REQ_DATE >= params.from_date
        AND pr.REQ_DATE <= params.to_date
        AND pr.REQUEST_TYPE = 6
        AND pr.STATE NOT IN (8,10,11,12,13,14)
		AND pr.clearinghouse_id IN (4608,4808,4607,4807,4007,4809,4609,5007,5408,5409,5410,5607)
        GROUP BY
            pr.center,
            pr.REQ_DATE
            
/*
ADYEN REPRESENTATIONS STATUS  
5.1 Adyen Summary
2. Paid + 3. Unpaid + Error
*/          
		UNION ALL
        SELECT
            pr.center,
            TO_CHAR(pr.REQ_DATE, 'yyyy-mm-dd') "text",
            COUNT(*)                                             COUNT,
            SUM(pr.REQ_AMOUNT)                                   total,
            '5.1 Adyen Summary'                           reportgroup,
            CASE
                WHEN pr.state IN (3,4,18)
                THEN '2. Paid'
                WHEN pr.state IN (5,6,7,17)
                THEN '3. Unpaid'
                ELSE 'Error'
            END subgroup
        FROM
            PULSE.PAYMENT_REQUESTS pr
            
        join params on pr.center = params.centerid   
            
        WHERE
            pr.REQ_DATE >= params.from_date
        AND pr.REQ_DATE <= params.to_date
        AND pr.REQUEST_TYPE = 6
        AND pr.STATE NOT IN (8,10,11,12,13,14)		
        AND pr.clearinghouse_id IN (4608,4808,4607,4807,4007,4809,4609,5007,5408,5409,5410,5607)
        GROUP BY
            pr.center,
            pr.REQ_DATE,
            pr.state
            
    ) dataset
    
join params on dataset.center = params.centerid    
    
ORDER BY
    6, 7, 3
