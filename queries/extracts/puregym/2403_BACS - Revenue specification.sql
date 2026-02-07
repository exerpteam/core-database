SELECT
    (
        SELECT
            c.EXTERNAL_ID
        FROM
            centers c
        WHERE
            c.id = center) AS CostCenter,
    (
        SELECT
            c.name
        FROM
            centers c
        WHERE
            c.id = center) AS Site,
    TYPE,
    TEXT,
    SUM(vat)   AS VAT,
    SUM(TOTAL) AS TOTAL
FROM
    (
        SELECT
            art.center,
            CASE
                WHEN (il.center IS NOT NULL)
                THEN 'SALE'
                WHEN (cnl.center IS NOT NULL)
                THEN 'CREDIT'
                ELSE 'OTHER'
            END AS TYPE,
            CASE
                WHEN (cnl.center IS NOT NULL)
                THEN -- acc.name -- todo when account chart is done properly
                    CASE
                        WHEN POSITION(':' in cnl.text) > 0
                        THEN SUBSTR(cnl.text,1,POSITION(':' in cnl.text)-1)
                        ELSE cnl.text
                    END
                WHEN (il.center IS NOT NULL)
                THEN -- acc.name -- todo when account chart is done properly acc.name
                    CASE
                        WHEN POSITION(':' in il.text) > 0
                        THEN SUBSTR(il.text,1,POSITION(':' in il.text)-1)
                        ELSE il.text
                    END
                ELSE
                    CASE
                        WHEN (art.text LIKE 'Deduction 20%')
                        THEN 'Converted Harlands'
                        WHEN (acc.name LIKE 'Debt to %')
                        THEN 'Cross center'
                        ELSE acc.name
                    END
            END AS text,
            CASE
                WHEN (il.center IS NOT NULL)
                THEN il.TOTAL_AMOUNT
                WHEN (cnl.center IS NOT NULL)
                THEN -cnl.TOTAL_AMOUNT
                WHEN (art.COLLECTED_AMOUNT = 0)
                THEN 0 -- refunds from previous periods.
                ELSE -art.amount
            END AS TOTAL,
            COALESCE(
                CASE
                    WHEN (cnl.center IS NOT NULL)
                    THEN -creditvat.amount
                    WHEN (il.center IS NOT NULL)
                    THEN salevat.amount
                    ELSE 0
                END,0) AS VAT
        FROM
            PAYMENT_REQUESTS pr
        JOIN
            PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            prs.center = pr.INV_COLL_CENTER
        AND prs.id = pr.INV_COLL_ID
        AND prs.subid = pr.INV_COLL_SUBID
        JOIN
            AR_TRANS ART
        ON
            ART.COLLECTED = 1
        AND ART.PAYREQ_SPEC_CENTER = prs.center
        AND ART.PAYREQ_SPEC_ID = prs.id
        AND ART.PAYREQ_SPEC_SUBID = prs.subid
        LEFT JOIN
            -- when an amount credited on cashaccount has been transfered on the payment account
            AR_TRANS cart
        ON
            cart.REF_TYPE = art.ref_TYpe
        AND cart.ref_center = art.ref_center
        AND cart.ref_id = art.ref_id
        AND cart.ref_subid = art.ref_subid
        AND cart.id <> art.id
        LEFT JOIN
            ART_MATCH am
        ON
            am.ART_PAID_CENTER = cart.center
        AND am.ART_PAID_id = cart.id
        AND am.ART_PAID_subid = cart.subid
        AND am.CANCELLED_TIME IS NULL
        LEFT JOIN
            --cash account transactions that have been moved to payment account
            AR_TRANS art2
        ON
            am.ART_PAYING_CENTER = art2.center
        AND am.ART_PAYING_ID = art2.id
        AND am.ART_PAYING_SUBID = art2.subid
        LEFT JOIN
            INVOICELINES il
        ON
            (
                art.REF_TYPE = 'INVOICE'
            AND art.REF_CENTER = il.center
            AND art.REF_ID = il.id )
        OR  (
                art2.REF_TYPE = 'INVOICE'
            AND art2.REF_CENTER = il.center
            AND art2.REF_ID = il.id )
        LEFT JOIN
            ACCOUNT_TRANS salevat
        ON
            salevat.center = il.VAT_ACC_TRANS_CENTER
        AND salevat.id = il.VAT_ACC_TRANS_ID
        AND salevat.subid = il.VAT_ACC_TRANS_SUBID
        LEFT JOIN
            CREDIT_NOTE_LINES cnl
        ON
            (
                art.REF_TYPE = 'CREDIT_NOTE'
            AND art.REF_CENTER = cnl.center
            AND art.REF_ID = cnl.id )
        OR  (
                art2.REF_TYPE = 'CREDIT_NOTE'
            AND art2.REF_CENTER = cnl.center
            AND art2.REF_ID = cnl.id )
        LEFT JOIN
            ACCOUNT_TRANS creditvat
        ON
            (
                creditvat.center = cnl.VAT_ACC_TRANS_CENTER
            AND creditvat.id = cnl.VAT_ACC_TRANS_ID
            AND creditvat.subid = cnl.VAT_ACC_TRANS_SUBID )
        LEFT JOIN
            ACCOUNT_TRANS gltrans
        ON
            (
                il.ACCOUNT_TRANS_CENTER IS NOT NULL
            AND gltrans.center = il.ACCOUNT_TRANS_CENTER
            AND gltrans.id = il.ACCOUNT_TRANS_ID
            AND gltrans.subid = il.ACCOUNT_TRANS_SUBID )
        OR  (
                cnl.ACCOUNT_TRANS_CENTER IS NOT NULL
            AND gltrans.center = cnl.ACCOUNT_TRANS_CENTER
            AND gltrans.id = cnl.ACCOUNT_TRANS_ID
            AND gltrans.subid = cnl.ACCOUNT_TRANS_SUBID )
        OR  (
                il.ACCOUNT_TRANS_CENTER IS NULL
            AND cnl.ACCOUNT_TRANS_CENTER IS NULL
            AND art.REF_TYPE = 'ACCOUNT_TRANS'
            AND art.REF_CENTER = gltrans.center
            AND art.REF_ID = gltrans.id
            AND art.REF_SUBID = gltrans.subid )
        LEFT JOIN
            ACCOUNTS acc
        ON
            ( ( (
                        art.amount > 0
                    AND gltrans.DEBIT_ACCOUNTCENTER = acc.CENTER
                    AND gltrans.DEBIT_ACCOUNTID = acc.ID )
                OR  (
                        art.amount < 0
                    AND gltrans.CREDIT_ACCOUNTCENTER = acc.CENTER
                    AND gltrans.CREDIT_ACCOUNTID = acc.ID)))
        WHERE
            pr.DUE_DATE >= :fromDate
        AND pr.DUE_DATE <= :toDate
            -- sent from Exerp only
        AND pr.REQ_DELIVERY IS NOT NULL
        AND pr.state = 3 ) t1
GROUP BY
    center,
    TYPE,
    text
HAVING
    (
        SUM(TOTAL)) <> 0
ORDER BY
    Site ASC,
    TYPE DESC,
    TOTAL DESC,
    text