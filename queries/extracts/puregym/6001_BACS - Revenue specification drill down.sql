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
    MemberId,
    TYPE,
    TEXT,
    SUM(vat)   AS VAT,
    SUM(TOTAL) AS TOTAL
FROM
    (
        SELECT
            art.center,
            p.CURRENT_PERSON_CENTER || 'p' || p.CURRENT_PERSON_ID AS MemberId,
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
                        WHEN instr(cnl.text,':',1) > 0
                        THEN SUBSTR(cnl.text,1,instr(cnl.text,':',1)-1)
                        ELSE cnl.text
                    END
                WHEN (il.center IS NOT NULL)
                THEN -- acc.name -- todo when account chart is done properly acc.name
                    CASE
                        WHEN instr(il.text,':',1) > 0
                        THEN SUBSTR(il.text,1,instr(il.text,':',1)-1)
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
            NVL(
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
            PUREGYM.AR_TRANS ART
        ON
            ART.COLLECTED = 1
        AND ART.PAYREQ_SPEC_CENTER = prs.center
        AND ART.PAYREQ_SPEC_ID = prs.id
        AND ART.PAYREQ_SPEC_SUBID = prs.subid
        JOIN
            PUREGYM.ACCOUNT_RECEIVABLES AR
        ON
            AR.CENTER = ART.CENTER
        AND AR.ID = ART.ID
        JOIN
            PERSONS p
        ON
            AR.CUSTOMERCENTER = P.CENTER
        AND AR.CUSTOMERID = p.ID
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
            PUREGYM.ART_MATCH am
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
            PUREGYM.INVOICELINES il
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
            PUREGYM.ACCOUNT_TRANS salevat
        ON
            salevat.center = il.VAT_ACC_TRANS_CENTER
        AND salevat.id = il.VAT_ACC_TRANS_ID
        AND salevat.subid = il.VAT_ACC_TRANS_SUBID
        LEFT JOIN
            PUREGYM.CREDIT_NOTE_LINES cnl
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
            PUREGYM.ACCOUNT_TRANS creditvat
        ON
            (
                creditvat.center = cnl.VAT_ACC_TRANS_CENTER
            AND creditvat.id = cnl.VAT_ACC_TRANS_ID
            AND creditvat.subid = cnl.VAT_ACC_TRANS_SUBID )
        LEFT JOIN
            PUREGYM.ACCOUNT_TRANS gltrans
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
            PUREGYM.ACCOUNTS acc
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
        AND pr.center IN (:scope )
            -- sent from Exerp only
        AND pr.REQ_DELIVERY IS NOT NULL
        AND pr.state = 3 )
GROUP BY
    center,
    TYPE,
    text,
    MemberId
HAVING
    (
        SUM(TOTAL)) <> 0
ORDER BY
    Site ASC,
    MemberId,
    TYPE DESC,
    TOTAL DESC,
    text