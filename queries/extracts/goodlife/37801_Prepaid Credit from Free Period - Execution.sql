-- The extract is extracted from Exerp on 2026-02-08
--  
select 
    case 
when t.payer_center in (5,7,8,11,14,15,17,27,29,30,32,36,41,42,44,47,48,49,50,52,54,55,57) then 1
when t.payer_center in (58,60,63,65,66,69,70,74,75,78,79,80,81,84,85,104,105,106,107,108,109,110,111) then 2
when t.payer_center in (112,118,125,128,129,131,132,135,137,138,145,146,147,149,151,154,155,160,161,163,164,165,166) then 3
when t.payer_center in (167,168,169,170,171,172,173,174,175,177,178,179,180,181,182,183,184,185,186,187,188,189,190) then 4
when t.payer_center in (192,193,194,195,196,197,201,202,204,206,207,208,209,212,213,215,216,217,219,220,223,224,225) then 5
when t.payer_center in (226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248) then 6
when t.payer_center in (249,250,251,252,253,255,256,257,258,260,261,262,264,265,266,267,268,269,270,271,273,274,276) then 7
when t.payer_center in (277,278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,294,296,297,299,302,303) then 8
when t.payer_center in (306,308,309,310,311,312,313,314,315,317,318,319,321,323,324,331,332,333,334,335,336,337,338) then 9
when t.payer_center in (345,346,347,349,351,353,356,870) then 10
else 1000 end as threadgroup,
    cast(t."Subscription Id" as text) as subid,
    cast(CEIL(sum(t."Days Owed")) as text) as daysowed,
    cast(ex.external_id as text),
    cast(t.payer_center as text),
    cast(t.payer_id as text),
    cast(prd.center as text),
    cast(prd.id as text),
    cast(sum(t."Credit Amount") as text) as creditamount
    

  from (WITH
    params AS
    (
        SELECT
            /*+ materialize */
            CAST($$Start_Date$$ AS DATE)                                                                                            AS StartDate,
            CAST($$End_Date$$ AS DATE)                                                                                              AS EndDate,
            CAST(datetolongC(TO_CHAR(CAST($$Start_Date$$ AS DATE) , 'YYYY-MM-dd HH24:MI'),c.id) AS BIGINT)                            AS StartDateLong,
            CAST((datetolongC(TO_CHAR((CAST($$End_Date$$ AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS EndDateLong,
            --CAST('2020-03-16' AS DATE)                                                                                            AS StartDate,
            --CAST('2021-04-07' AS DATE)                                                                                              AS EndDate,
            --CAST(datetolongC(TO_CHAR(CAST('2020-03-16' AS DATE) , 'YYYY-MM-dd HH24:MI'),c.id) AS BIGINT)                            AS StartDateLong,
            --CAST((datetolongC(TO_CHAR((CAST('2021-04-07' AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS EndDateLong,
            c.id                                                                                                   AS CENTER_ID
        FROM
            centers AS c
        WHERE
            CAST(c.ID AS VARCHAR) IN ($$Scope$$)
            --c.id in (55)
    )
    ,
    TRANS_VIEW AS
    (
        SELECT DISTINCT
            CASE
                WHEN il.center IS NULL
                THEN ar.CENTER
                ELSE il.CENTER
            END                                                           AS SALES_CENTER,
            ar.CUSTOMERCENTER                                             AS PERSON_CENTER,
            ar.CUSTOMERID                                                 AS PERSON_ID,
            TO_CHAR(longtodatec(art.trans_time, art.center),'YYYY-MM-DD') AS BOOK_DATE,
            art.due_date                                                  AS DUE_DATE,
            TO_CHAR(longtodatec(art.entry_time, art.center),'YYYY-MM-DD') AS ENTRY_TIME,
            CASE
                WHEN art.REF_TYPE = 'CREDIT_NOTE'
                THEN art.ref_center || 'cred' || art.ref_id || 'sub' || art.subid
                WHEN art.REF_TYPE = 'INVOICE'
                THEN il.center || 'inv' || il.id || 'sub' || il.subid
                ELSE art.center || 'pay'|| art.id || 'subid'||art.subid
            END AS temp_inv_id,
            CASE
                WHEN art.REF_TYPE = 'CREDIT_NOTE'
                THEN art.ref_center || 'cred' || art.ref_id
                WHEN art.REF_TYPE = 'INVOICE'
                THEN il.center || 'inv' || il.id
                WHEN art.REF_TYPE = 'ACCOUNT_TRANS'
                THEN art.ref_center || 'acc' || art.ref_id || 'tr' || art.subid
            END                                                        AS INV_ID,
            COALESCE(il.center, clinvl.center)                         AS INVOICE_CENTER,
            COALESCE(il.id, clinvl.id)                                 AS INVOICE_ID,
            COALESCE(il.subid, clinvl.subid)                           AS INVOICE_SUBID,
            art.text                                                   AS AR_TEXT,
            COALESCE(prod.name, 'Account Transaction (ACCOUNT_TRANS)') AS PROD_NAME,
            CASE
                WHEN cracc.name IS NOT NULL
                THEN cracc.name
                WHEN dbacc.name IS NOT NULL
                THEN dbacc.name
                    -- Credit note is transfered from other payer to member.
                WHEN prod.name IS NULL
                THEN 'Accounts Receivable: Members'
            END AS ACC_NAME,
            CASE
                WHEN cracc.EXTERNAL_ID IS NOT NULL
                THEN cracc.EXTERNAL_ID
                WHEN dbacc.EXTERNAL_ID IS NOT NULL
                THEN dbacc.EXTERNAL_ID
                    -- Credit note is transfered from other payer to member.
                WHEN prod.name IS NULL
                THEN '12700-000'
            END                                                                AS EXTERNAL_ID,
            rank() over (partition BY cl.center, cl.id ORDER BY cl.subid DESC) AS rnk1,
            rank() over (partition BY il.center, il.id ORDER BY il.subid DESC) AS rnk2,
            rank() over (partition BY ivat.invoiceline_center, ivat.invoiceline_id, ivat.invoiceline_subid ORDER BY ivat.id DESC) AS rnk3,          
            -- Proportion of the open amount according to the partial credit notes
            ROUND((
                    CASE
                        WHEN cl.TOTAL_AMOUNT IS NOT NULL
                            AND art.unsettled_amount != 0
                        THEN LEAST(SUM(cl.TOTAL_AMOUNT) over (partition BY cl.center, cl.id ORDER BY cl.subid), art.unsettled_amount)
                        WHEN cl.TOTAL_AMOUNT IS NOT NULL
                            AND art.unsettled_amount = 0
                        THEN SUM(cl.TOTAL_AMOUNT) over (partition BY cl.center, cl.id ORDER BY cl.subid)
                        WHEN il.TOTAL_AMOUNT IS NULL
                            AND orgart.AMOUNT IS NULL
                            -- No invoice line, no transfer between accounts
                        THEN art.unsettled_amount
                        WHEN il.TOTAL_AMOUNT IS NOT NULL
                            AND art.unsettled_amount != 0
                        THEN LEAST(SUM(il.TOTAL_AMOUNT) over (partition BY il.center, il.id ORDER BY il.subid), art.unsettled_amount)
                    END), 4) AS OPEN_AMOUNT_1,
            -- Proportion of the open amount according to the invoice line
            ROUND((
                    CASE
                        WHEN il.TOTAL_AMOUNT IS NULL
                            AND org2art.AMOUNT IS NULL
                            -- No invoice line, no transfer between accounts
                        THEN (orgart.AMOUNT * tst.AMOUNT/orgart.AMOUNT)*-1
                        WHEN il.TOTAL_AMOUNT IS NULL
                            AND org2art.AMOUNT IS NOT NULL
                            -- No invoice line but transfer between accounts twice
                        THEN org2art.AMOUNT * t2st.AMOUNT/org2art.AMOUNT* tst.AMOUNT/orgart.AMOUNT
                        WHEN tst.AMOUNT IS NULL
                            -- Invoice line on account
                        THEN IL.TOTAL_AMOUNT*-1
                        WHEN t2st.AMOUNT IS NULL
                            -- Invoice line that has been transferred between accounts
                        THEN IL.TOTAL_AMOUNT* tst.AMOUNT/orgart.AMOUNT
                            -- Invoice line that has been transferred twice between accounts
                        ELSE IL.TOTAL_AMOUNT* t2st.AMOUNT/org2art.AMOUNT* tst.AMOUNT/ orgart.AMOUNT
                    END) *
                -- How much is open (percentage)
                COALESCE(
                           (
                           SELECT
                               1+ SUM(st.AMOUNT) /art.AMOUNT
                           FROM
                               ART_MATCH st ,
                               AR_TRANS arts
                           WHERE
                               st.ART_PAID_CENTER = art.CENTER
                               AND st.ART_PAID_ID = art.ID
                               AND st.ART_PAID_SUBID = art.SUBID
                               AND st.ENTRY_TIME > params.StartDateLong
                               AND st.ENTRY_TIME < params.EndDateLong
                               AND st.CANCELLED_TIME IS NULL
                               AND arts.CENTER = st.ART_PAYING_CENTER
                               AND arts.ID = st.ART_PAYING_ID
                               AND arts.SUBID = st.ART_PAYING_SUBID
                               AND arts.ENTRY_TIME > params.StartDateLong
                               AND arts.ENTRY_TIME < params.EndDateLong),1) , 4) AS OPEN_AMOUNT_2,
            SUM(ivat.rate) over (partition BY ivat.invoiceline_center, ivat.invoiceline_id, ivat.invoiceline_subid ORDER BY ivat.id) AS rate
        FROM
            params
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = params.CENTER_ID
        JOIN
            persons per
        ON
            per.center = ar.CUSTOMERCENTER
            AND per.id = ar.CUSTOMERID
            --and per.center=55 and per.id=2602
        JOIN
            ar_trans art
        ON
            ar.CENTER = art.CENTER
            AND ar.ID = art.ID
            -- We want the GL codes
        LEFT JOIN
            -- transaction transfered from another account.
            AR_TRANS tart
        ON
            tart.REF_TYPE = art.ref_TYPE
            AND tart.ref_center = art.ref_center
            AND tart.ref_id = art.ref_id
            AND tart.ref_subid = art.ref_subid
            AND tart.center <> art.center
            AND tart.id <> art.id
            AND tart.subid <> art.subid
            AND tart.ENTRY_TIME > params.StartDateLong
            AND tart.ENTRY_TIME < params.EndDateLong
        LEFT JOIN
            ( params AS params1
        CROSS JOIN
            ART_MATCH tst
        JOIN
            AR_TRANS orgart
        ON
            orgart.CENTER = tst.ART_PAID_CENTER
            AND orgart.ID = tst.ART_PAID_ID
            AND orgart.SUBID = tst.ART_PAID_SUBID
            AND orgart.ENTRY_TIME > params1.StartDateLong
            AND orgart.ENTRY_TIME < params1.EndDateLong )
        ON
            tst.ART_PAYING_CENTER = tart.CENTER
            AND tst.ART_PAYING_ID = tart.ID
            AND tst.ART_PAYING_SUBID = tart.SUBID
            AND tst.ENTRY_TIME > params.StartDateLong
            AND tst.ENTRY_TIME < params.EndDateLong
            AND (
                tst.CANCELLED_TIME IS NULL
                OR tst.CANCELLED_TIME > params.EndDateLong)
        LEFT JOIN
            -- transaction transfered from another account.
            AR_TRANS t2art
        ON
            t2art.REF_TYPE = orgart.ref_TYPE
            AND t2art.ref_center = orgart.ref_center
            AND t2art.ref_id = orgart.ref_id
            AND t2art.ref_subid = orgart.ref_subid
            AND t2art.center <> orgart.center
            AND t2art.id <> orgart.id
            AND t2art.subid <> orgart.subid
            AND t2art.ENTRY_TIME > params.StartDateLong
            AND t2art.ENTRY_TIME < params.EndDateLong
        LEFT JOIN
            ( params AS params2
        CROSS JOIN
            ART_MATCH t2st
        JOIN
            AR_TRANS org2art
        ON
            org2art.CENTER = t2st.ART_PAID_CENTER
            AND org2art.ID = t2st.ART_PAID_ID
            AND org2art.SUBID = t2st.ART_PAID_SUBID
            AND org2art.ENTRY_TIME > params2.StartDateLong
            AND org2art.ENTRY_TIME < params2.EndDateLong )
        ON
            t2st.ART_PAYING_CENTER = t2art.CENTER
            AND t2st.ART_PAYING_ID = t2art.ID
            AND t2st.ART_PAYING_SUBID = t2art.SUBID
            AND t2st.ENTRY_TIME > params.StartDateLong
            AND t2st.ENTRY_TIME < params.EndDateLong
            AND (
                t2st.CANCELLED_TIME IS NULL
                OR t2st.CANCELLED_TIME > params.EndDateLong)
        LEFT JOIN
            invoice_lines_mt il
        ON
            il.total_amount <> 0
            AND ( (
                    orgart.center IS NULL
                    AND art.REF_TYPE = 'INVOICE'
                    AND art.REF_CENTER = il.center
                    AND art.REF_ID = il.id )
                OR (
                    orgart.center IS NOT NULL
                    AND orgart.REF_TYPE = 'INVOICE'
                    AND orgart.REF_CENTER = il.center
                    AND orgart.REF_ID = il.id )
                OR (
                    org2art.center IS NOT NULL
                    AND org2art.REF_TYPE = 'INVOICE'
                    AND org2art.REF_CENTER = il.center
                    AND org2art.REF_ID = il.id ))
        LEFT JOIN
            credit_note_lines_mt cl
        ON
            cl.total_amount > 0
            AND((
                orgart.center IS NULL
                AND art.REF_TYPE IN ( 'CREDIT_NOTE')
                AND art.REF_CENTER = cl.center
                AND art.REF_ID = cl.id )
            OR (
                orgart.center IS NOT NULL
                AND orgart.REF_TYPE = 'CREDIT_NOTE'
                AND orgart.REF_CENTER = cl.center
                AND orgart.REF_ID = cl.id )
            OR (
                org2art.center IS NOT NULL
                AND org2art.REF_TYPE = 'CREDIT_NOTE'
                AND org2art.REF_CENTER = cl.center
                AND org2art.REF_ID = cl.id ))
        LEFT JOIN
            invoice_lines_mt clinvl
        ON
            clinvl.center = cl.invoiceline_center
            AND clinvl.id = cl.invoiceline_id
            AND clinvl.subid = cl.invoiceline_subid
            AND clinvl.total_amount > 0
        LEFT JOIN
            ACCOUNT_TRANS gltrans
        ON
            (
                il.ACCOUNT_TRANS_CENTER IS NOT NULL
                AND gltrans.center = il.ACCOUNT_TRANS_CENTER
                AND gltrans.id = il.ACCOUNT_TRANS_ID
                AND gltrans.subid = il.ACCOUNT_TRANS_SUBID )
            OR (
                il.ACCOUNT_TRANS_CENTER IS NULL
                AND org2art.REF_TYPE = 'ACCOUNT_TRANS'
                AND org2art.REF_CENTER = gltrans.center
                AND org2art.REF_ID = gltrans.id
                AND org2art.REF_SUBID = gltrans.subid)
            OR (
                il.ACCOUNT_TRANS_CENTER IS NULL
                AND org2art.REF_TYPE IS NULL
                AND orgart.REF_TYPE = 'ACCOUNT_TRANS'
                AND orgart.REF_CENTER = gltrans.center
                AND orgart.REF_ID = gltrans.id
                AND orgart.REF_SUBID = gltrans.subid)
            OR (
                il.ACCOUNT_TRANS_CENTER IS NULL
                AND orgart.REF_TYPE IS NULL
                AND art.REF_TYPE = 'ACCOUNT_TRANS'
                AND art.REF_CENTER = gltrans.center
                AND art.REF_ID = gltrans.id
                AND art.REF_SUBID = gltrans.subid )
            OR (
                cl.ACCOUNT_TRANS_CENTER IS NOT NULL
                AND gltrans.center = clinvl.ACCOUNT_TRANS_CENTER
                AND gltrans.id = clinvl.ACCOUNT_TRANS_ID
                AND gltrans.subid = clinvl.ACCOUNT_TRANS_SUBID )
        LEFT JOIN
            ACCOUNTS cracc
        ON
            cracc.EXTERNAL_ID != '0023-99995-000'
            AND gltrans.CREDIT_ACCOUNTCENTER = cracc.CENTER
            AND gltrans.CREDIT_ACCOUNTID = cracc.ID
        LEFT JOIN
            ACCOUNTS dbacc
        ON
            dbacc.EXTERNAL_ID != '0023-99995-000'
            AND gltrans.debit_ACCOUNTCENTER = dbacc.CENTER
            AND gltrans.debit_ACCOUNTID = dbacc.ID
        LEFT JOIN
            INVOICELINES_VAT_AT_LINK ivat
        ON
            (ivat.INVOICELINE_CENTER=il.CENTER
            AND ivat.INVOICELINE_ID=il.ID
            AND ivat.INVOICELINE_SUBID=il.SUBID)
            OR
            (ivat.INVOICELINE_CENTER=clinvl.CENTER
            AND ivat.INVOICELINE_ID=clinvl.ID
            AND ivat.INVOICELINE_SUBID=clinvl.SUBID)            
        LEFT JOIN
            products prod
        ON
            (
                prod.center = il.productcenter
                AND prod.id = il.productid)
            OR (
                prod.center = cl.productcenter
                AND prod.id = cl.productid)
        WHERE
            /* Exclude companies */
            per.sex != 'C'
            /* Only PAYMENT transaction  */
            AND ar.AR_TYPE =4
            AND art.AMOUNT <> 0
            AND ART.STATUS != 'CLOSED'
            AND art.ENTRY_TIME > params.StartDateLong
            AND art.ENTRY_TIME < params.EndDateLong
            /* ONLY postive balance */
            AND ar.BALANCE > 0
    )
    ,
    TRANS_AGG_VIEW AS
    (
        SELECT
            tv.sales_center,
            tv.person_center,
            tv.person_id,
            tv.BOOK_DATE,
            tv.DUE_DATE,
            tv.ENTRY_TIME,
            tv.INV_ID,
            tv.INVOICE_CENTER,
            tv.INVOICE_ID,
            tv.INVOICE_SUBID,           
            tv.AR_TEXT,
            tv.PROD_NAME,
            tv.ACC_NAME,
            tv.EXTERNAL_ID,
            tv.rate,
            SUM(COALESCE(tv.OPEN_AMOUNT_1, tv.OPEN_AMOUNT_2)) AS OPEN_AMOUNT
        FROM
            TRANS_VIEW tv
        WHERE
            tv.rnk1 = 1
            AND tv.rnk2 = 1
            AND tv.rnk3 = 1
        GROUP BY
            tv.sales_center,
            tv.person_center,
            tv.person_center,
            tv.person_id,
            tv.BOOK_DATE,
            tv.DUE_DATE,
            tv.ENTRY_TIME,
            tv.INV_ID,
            tv.INVOICE_CENTER,
            tv.INVOICE_ID,
            tv.INVOICE_SUBID,           
            tv.AR_TEXT,
            tv.PROD_NAME,
            tv.ACC_NAME,
            tv.EXTERNAL_ID,
            tv.rate
    )
SELECT
    per.external_id                                                                                                AS "External ID",
    t.sales_center                                                                                                 AS "Invoice Center",
    salescenter.name                                                                                               AS "Sales Center Name",
    t.person_center                                                                                                AS "Person Center",
    percenter.name                                                                                                 AS "Person Center Name",
    t.person_center || 'p' || t.person_id                                                                          AS "Person Id",
    per.fullname                                                                                                   AS "Person Name",
    t.BOOK_DATE                                                                                                    AS "Book Date",
    t.DUE_DATE                                                                                                     AS "Due date",
    t.ENTRY_TIME                                                                                                   AS "Entry Time",
    t.INV_ID                                                                                                       AS "Invoice Id",
    t.INVOICE_CENTER || 'inv'|| t.INVOICE_ID ||'sub' || t.INVOICE_SUBID                                            AS "Invoice Id2",
    t.AR_TEXT                                                                                                      AS "AR Transaction Text",
    t.PROD_NAME                                                                                                    AS "Product Name",
    t.ACC_NAME                                                                                                     AS "Account Name",
    t.EXTERNAL_ID                                                                                                  AS "Account Id",
    t.OPEN_AMOUNT                                                                                                  AS "Open Amount",
    ROUND(t.OPEN_AMOUNT/COALESCE((1+t.rate),1), 2)                                                                 AS "Open Revenue Amount",
    t.OPEN_AMOUNT - ROUND(t.OPEN_AMOUNT/COALESCE((1+t.rate),1), 2)                                                 AS "Open VAT Amount",
    'PAYMENT'                                                                                                      AS "Account Type",
    sub.center || 'ss' || sub.id                                                                                   AS "Subscription Id",
    sub.center as ss_center,sub.id as ss_id,    
    sub.owner_center || 'p' || sub.owner_id                                                                        AS "Subscription Person Id", 
    spp.from_date                                                                                                  AS "Subscription Period Start",
    spp.to_date                                                                                                    AS "Subscription Period End",
    params.StartDate                                                                                               AS "Close Start Date",
    params.EndDate                                                                                                 AS "Close End Date",
    spp.subscription_price                                                                                         AS "Sales Log Net Amount",
    ROUND(invl.net_amount/COALESCE(((spp.to_date -spp.from_date)+1), 1), 2)                                        AS "Daily Net Price",
    ROUND(ROUND(t.OPEN_AMOUNT/COALESCE((1+t.rate),1), 2)/COALESCE((ROUND(invl.net_amount/COALESCE(((spp.to_date -spp.from_date)+1), 1), 2)), 1), 2) AS "Days Owed",
    ROUND(t.OPEN_AMOUNT/COALESCE((1+t.rate),1), 2)                                                                                                  AS "Credit Amount",
    CASE
        WHEN spa.center IS NOT NULL
        THEN sub.owner_center || 'p' || sub.owner_id
        WHEN op_rel.center IS NOT NULL
        THEN op_rel.center || 'p'|| op_rel.id
        ELSE t.person_center || 'p' || t.person_id
    END AS "Payer Id",
    
    /*Insert into SUD*/
    CASE
        WHEN spa.center IS NOT NULL
        THEN sub.owner_center --|| 'p' || sub.owner_id
        WHEN op_rel.center IS NOT NULL
        THEN op_rel.center --|| 'p'|| op_rel.id
        ELSE t.person_center --|| 'p' || t.person_id
    END AS payer_center,
    CASE
        WHEN spa.center IS NOT NULL
        THEN --sub.owner_center || 'p' || 
        sub.owner_id
        WHEN op_rel.center IS NOT NULL
        THEN --op_rel.center --|| 'p'|| 
        op_rel.id
        ELSE --t.person_center --|| 'p' || 
        t.person_id
    END AS payer_id,
    /*End*/
    
    CASE
        WHEN spa.center IS NOT NULL
        THEN 'Yes'
        WHEN op_rel.center IS NOT NULL
        THEN 'No'
        ELSE 'Yes'
    END AS "Paid By Member"     
FROM
    TRANS_AGG_VIEW t
JOIN
    params
ON
    params.center_id = t.person_center
JOIN
    persons per
ON
    per.center = t.person_center
    AND per.id = t.person_id
JOIN
    centers percenter
ON
    percenter.id = t.person_center
JOIN
    centers salescenter
ON
    salescenter.id = t.sales_center
LEFT JOIN
    invoice_lines_mt invl
ON
    invl.center = t.INVOICE_CENTER
    AND invl.id = t.INVOICE_ID
    AND invl.subid = t.INVOICE_SUBID
LEFT JOIN
    SPP_INVOICELINES_LINK link
ON
    link.INVOICELINE_CENTER = invl.center
    AND link.INVOICELINE_ID = invl.ID
    AND link.INVOICELINE_SUBID = invl.SUBID
LEFT JOIN
    subscriptionperiodparts spp
ON
    link.PERIOD_CENTER = spp.CENTER
    AND link.PERIOD_ID = spp.ID
    AND link.PERIOD_SUBID= spp.SUBID
LEFT JOIN
    subscriptions sub
ON
    sub.center = spp.CENTER
    AND sub.id = spp.id
LEFT JOIN
    payment_agreements spa
ON
    spa.center = sub.payment_agreement_center
    AND spa.id = sub.payment_agreement_id
    AND spa.subid = sub.payment_agreement_subid 
LEFT JOIN
    relatives op_rel
ON
    op_rel.relativecenter=sub.owner_center
    AND op_rel.relativeid=sub.owner_id
    AND op_rel.RTYPE = 12
    AND op_rel.STATUS < 3   
   
   /*Insert into SUD*/
   )t
   join persons ex on ex.center = t.payer_center and ex.id=t.payer_id
   join subscriptions s on s.center = ss_center and s.id=ss_id and s.state not in (3)

   join products prd on s.center = prd.center and prd.globalid='SERVICE_PAP'
   where t."Paid By Member"='Yes'
   group by
   ss_center,
   ss_id,
    t."Subscription Id",
    t.payer_center,
    t.payer_id,
    prd.center,
    prd.id,
    ex.external_id
    /*End insert into SUD*/