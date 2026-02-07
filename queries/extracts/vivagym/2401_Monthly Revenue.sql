SELECT
        t1.*,
        (CASE when t1.text = 'Converted subscription invoice'
        and t1.new_to_date-t1.new_from_date+1 = 31 THEN 
                t1.subscription_price
                ELSE t1.IL_TOTAL_AMOUNT
         END) AS NEW_IL_TOTAL_AMOUNT
FROM
(
        SELECT
            INV0.payer_center || 'p' || INV0.payer_id as personid,
            spp.from_date,
            spp.to_date,
            spp.subscription_price,
            (CASE WHEN
               IL.TOTAL_AMOUNT = 0
                THEN NULL
                ELSE greatest(spp.from_date,TO_DATE('2021-08-01','YYYY-MM-DD'))
            END) AS new_from_date,
            (CASE WHEN
                IL.TOTAL_AMOUNT = 0
                THEN NULL
                ELSE least(spp.to_date,TO_DATE('2021-08-31','YYYY-MM-DD'))
            END) AS new_to_date,
            round(spp.subscription_price/31,5) as daily_price,
            INV0.CENTER                 AS INV0_CENTER,
            EM.CENTER                   AS EM_CENTER,
            EM.ID                       AS EM_ID,
            PE.FULLNAME                 AS PE_FULLNAME,
            INV0.TRANS_TIME             AS INV0_TRANS_TIME,
            INV0.ENTRY_TIME             AS INV0_ENTRY_TIME,
            PR.CENTER                   AS PR_CENTER,
            PR.NAME                     AS PR_NAME,
            PR.GLOBALID                 AS PR_GLOBALID,
            PR.PRIMARY_PRODUCT_GROUP_ID AS PR_PRIMARY_PRODUCT_GROUP_ID,
            PR.EXTERNAL_ID              AS PR_EXTERNAL_ID,
            INV1.CENTER                 AS INV1_CENTER,
            IL.QUANTITY                 AS IL_QUANTITY,
            IL.TOTAL_AMOUNT             AS IL_TOTAL_AMOUNT,
            IL.NET_AMOUNT               AS IL_NET_AMOUNT,
            (
                SELECT
                    STRING_AGG((ILVATL.RATE * 100) || '%', ',')
                FROM
                    INVOICELINES_VAT_AT_LINK AS ILVATL
                WHERE
                    (
                        IL.CENTER = ILVATL.INVOICELINE_CENTER
                    AND IL.ID = ILVATL.INVOICELINE_ID
                    AND IL.SUBID = ILVATL.INVOICELINE_SUBID)) AS VAT_RATES
                    ,inv0.text,preq.req_date
        FROM
            INVOICE_LINES_MT AS IL
        INNER JOIN
            INVOICES AS INV0
        ON
            (
                IL.CENTER = INV0.CENTER
            AND IL.ID = INV0.ID)
        INNER JOIN
            PRODUCTS AS PR
        ON
            (
                IL.PRODUCTCENTER = PR.CENTER
            AND IL.PRODUCTID = PR.ID)
        LEFT JOIN vivagym.spp_invoicelines_link spil ON spil.invoiceline_center = il.center AND spil.invoiceline_id = il.id AND spil.invoiceline_subid = il.subid
        LEFT JOIN vivagym.subscriptionperiodparts spp ON spil.period_center = spp.center AND spil.period_id = spp.id AND spil.period_subid = spp.subid AND spp.cancellation_time = 0
        LEFT JOIN vivagym.subscriptions s ON spil.period_center = s.center AND spil.period_id = s.id
        LEFT JOIN vivagym.account_receivables ar ON ar.customercenter = s.owner_center AND ar.customerid = s.owner_id AND ar.ar_type = 4
        LEFT JOIN vivagym.payment_requests preq ON preq.center = ar.center AND preq.id = ar.id AND preq.req_date = TO_DATE('2021-07-01','YYYY-MM-DD')
        LEFT JOIN
            INVOICES AS INV1
        ON
            (
                INV1.SPONSOR_INVOICE_CENTER = INV0.CENTER
            AND INV1.SPONSOR_INVOICE_ID = INV0.ID)
        LEFT JOIN
            EMPLOYEES AS EM
        ON
            (
                INV0.EMPLOYEE_CENTER = EM.CENTER
            AND INV0.EMPLOYEE_ID = EM.ID)
        LEFT JOIN
            PERSONS AS PE
        ON
            (
                PE.CENTER = EM.PERSONCENTER
            AND PE.ID = EM.PERSONID)
        WHERE
            (
                INV0.CENTER NOT IN(100)
            AND(
                    INV0.TRANS_TIME >= GETSTARTOFDAY('2021-08-01', INV0.CENTER)
                AND INV0.TRANS_TIME <= GETENDOFDAY('2021-08-31', INV0.CENTER)))

) t1