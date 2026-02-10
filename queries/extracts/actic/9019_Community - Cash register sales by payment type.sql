-- The extract is extracted from Exerp on 2026-02-08
-- Används av Norge
/**
* Creator: Exerp
* Purpose: List transactions for a given period and center.
* Result is grouped by paymenttypes.
*/
SELECT
    INV0.CASHREGISTER_CENTER                                   AS CR_CENTER,
    INV0.CASHREGISTER_ID                                       AS CR_ID,
    INV0.CENTER                                                AS SALES_CENTER,
    INV0.ID                                                    AS SALES_ID,
    TO_CHAR(longtodate(INV0.ENTRY_TIME), 'YYYY-MM-DD HH24:MI')    entryDate,
    CASE
        WHEN IL.PERSON_CENTER IS NOT NULL
        THEN IL.PERSON_CENTER || 'p' || IL.PERSON_ID
        ELSE NULL
    END person_id,
    CASE
        WHEN IL.PERSON_CENTER IS NOT NULL
        THEN CASE  PER.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 
            'CORPORATE'  WHEN 5 THEN  'ONEMANCORPORATE'  WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END
        ELSE NULL
    END                                                               person_type,
    MIN(IL.TEXT) || '...'                                                   as "TEXT",
    SUM(IL.QUANTITY)                                                        quantity,
    SUM(ROUND(IL.TOTAL_AMOUNT - (IL.TOTAL_AMOUNT * (1-(1/(1+IL.RATE)))),2)) excluding_Vat,
    SUM(ROUND(IL.TOTAL_AMOUNT * (1-(1/(1+IL.RATE))),2))                     included_Vat,
    SUM(ROUND(IL.TOTAL_AMOUNT, 2))                                          total_Amount,
    (
        SELECT
            SUM(CRT.AMOUNT)
        FROM
            CASHREGISTERTRANSACTIONS CRT
        WHERE
            CRT.CENTER = INV0.CASHREGISTER_CENTER
        AND CRT.ID = INV0.CASHREGISTER_ID
        AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
        AND CRT.CRTTYPE IN (1) ) CASH,
    (
        SELECT
            SUM(CRT.AMOUNT)
        FROM
            CASHREGISTERTRANSACTIONS CRT
        WHERE
            CRT.CENTER = INV0.CASHREGISTER_CENTER
        AND CRT.ID = INV0.CASHREGISTER_ID
        AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
        AND CRT.CRTTYPE IN (6,7,8) ) CARD,
    (
        CASE
            WHEN INV0.PAYSESSIONID IS NULL
            AND AR.AR_TYPE = 1
            THEN SUM(ART.AMOUNT)
            ELSE
                  (
                  SELECT
                      SUM(CRT.AMOUNT)
                  FROM
                      CASHREGISTERTRANSACTIONS CRT
                  WHERE
                      CRT.CENTER = INV0.CASHREGISTER_CENTER
                  AND CRT.ID = INV0.CASHREGISTER_ID
                  AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
                  AND CRT.CRTTYPE IN (5) )
        END ) AR_CASH,
    (
        CASE
            WHEN INV0.PAYSESSIONID IS NULL
            AND AR.AR_TYPE = 4
            THEN SUM(ART.AMOUNT)
            ELSE
                  (
                  SELECT
                      SUM(CRT.AMOUNT)
                  FROM
                      CASHREGISTERTRANSACTIONS CRT
                  WHERE
                      CRT.CENTER = INV0.CASHREGISTER_CENTER
                  AND CRT.ID = INV0.CASHREGISTER_ID
                  AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
                  AND CRT.CRTTYPE IN (12) )
        END ) AR_PAY,
    (
        SELECT
            -SUM(CRT.AMOUNT)
        FROM
            CASHREGISTERTRANSACTIONS CRT
        WHERE
            CRT.CENTER = INV0.CASHREGISTER_CENTER
        AND CRT.ID = INV0.CASHREGISTER_ID
        AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
        AND CRT.CRTTYPE IN (2) ) CHANGE,
    (
        SELECT
            SUM(CRT.AMOUNT)
        FROM
            CASHREGISTERTRANSACTIONS CRT
        WHERE
            CRT.CENTER = INV0.CASHREGISTER_CENTER
        AND CRT.ID = INV0.CASHREGISTER_ID
        AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
        AND CRT.CRTTYPE IN (9) ) GIFTCARD,
    (
        SELECT
            SUM(CRT.AMOUNT)
        FROM
            CASHREGISTERTRANSACTIONS CRT
        WHERE
            CRT.CENTER = INV0.CASHREGISTER_CENTER
        AND CRT.ID = INV0.CASHREGISTER_ID
        AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
        AND CRT.CRTTYPE IN (13) ) CUSTOM,
    (
        SELECT
            SUM(CRT.AMOUNT)
        FROM
            CASHREGISTERTRANSACTIONS CRT
        WHERE
            CRT.CENTER = INV0.CASHREGISTER_CENTER
        AND CRT.ID = INV0.CASHREGISTER_ID
        AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
        AND CRT.CRTTYPE NOT IN (1,2,4,5,6,7,9,12,13,18) ) OTHER
FROM
    INVOICELINES IL
INNER JOIN
    INVOICES INV0
ON
    (
        IL.CENTER = INV0.CENTER
    AND IL.ID = INV0.ID )
LEFT JOIN
    CASHREGISTERREPORTS CRR
ON
    (
        CRR.CENTER = INV0.CASHREGISTER_CENTER
    AND CRR.ID = INV0.CASHREGISTER_ID
    AND CRR.STARTTIME <= INV0.ENTRY_TIME
    AND CRR.REPORTTIME > INV0.ENTRY_TIME )
LEFT JOIN
    PERSONS PER
ON
    (
        IL.PERSON_CENTER = PER.center
    AND IL.PERSON_ID = PER.id )
LEFT JOIN
    AR_TRANS ART
ON
    (
        ART.REF_CENTER = INV0.CENTER
    AND ART.REF_ID = INV0.ID
    AND ART.REF_TYPE = 'INVOICE' )
LEFT JOIN
    ACCOUNT_RECEIVABLES AR
ON
    (
        ART.CENTER = AR.CENTER
    AND ART.ID = AR.ID )
WHERE
    (
        INV0.CASHREGISTER_CENTER = :Center
    AND IL.TOTAL_AMOUNT <> 0
    AND INV0.ENTRY_TIME >= :FromDate
    AND INV0.ENTRY_TIME < :ToDate + (1000*60*60*24)

    )
GROUP BY
    INV0.CASHREGISTER_CENTER,
    INV0.CASHREGISTER_ID,
    INV0.CENTER,
    INV0.ID,
    INV0.ENTRY_TIME,
    INV0.TEXT,
    IL.PERSON_CENTER,
    IL.PERSON_ID,
    INV0.PAYSESSIONID,
    AR.AR_TYPE,
    PER.PERSONTYPE
UNION ALL
SELECT
    CN.CASHREGISTER_CENTER                                   AS CR_CENTER,
    CN.CASHREGISTER_ID                                       AS CR_ID,
    CN.CENTER                                                AS CN_CENTER,
    CN.ID                                                       CN_ID,
    TO_CHAR(longtodate(CN.ENTRY_TIME), 'YYYY-MM-DD HH24:MI')    entryDate,
    CASE
        WHEN CNL.PERSON_CENTER IS NOT NULL
        THEN CNL.PERSON_CENTER || 'p' || CNL.PERSON_ID
        ELSE NULL
    END person_id,
    CASE
        WHEN CNL.PERSON_CENTER IS NOT NULL
        THEN CASE  PER.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 
            'CORPORATE'  WHEN 5 THEN  'ONEMANCORPORATE'  WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END
        ELSE NULL
    END person_type,
    MIN(CNL.TEXT) || '...',
    -SUM(CNL.QUANTITY)                                                          quantity,
    -SUM(ROUND(CNL.TOTAL_AMOUNT - (CNL.TOTAL_AMOUNT * (1-(1/(1+CNL.RATE)))),2)) excluding_Vat,
    -SUM(ROUND(CNL.TOTAL_AMOUNT * (1-(1/(1+CNL.RATE))),2))                      included_Vat,
    -SUM(ROUND(CNL.TOTAL_AMOUNT, 2))                                            total_Amount,
    (
        SELECT
            SUM(-CRT.AMOUNT)
        FROM
            CASHREGISTERTRANSACTIONS CRT
        WHERE
            CRT.CENTER = CN.CASHREGISTER_CENTER
        AND CRT.ID = CN.CASHREGISTER_ID
        AND CRT.PAYSESSIONID = CN.PAYSESSIONID
        AND CRT.CRTTYPE IN (4) ) CASH,
    (
        SELECT
            SUM(-CRT.AMOUNT)
        FROM
            CASHREGISTERTRANSACTIONS CRT
        WHERE
            CRT.CENTER = CN.CASHREGISTER_CENTER
        AND CRT.ID = CN.CASHREGISTER_ID
        AND CRT.PAYSESSIONID = CN.PAYSESSIONID
        AND CRT.CRTTYPE IN (18) ) CARD,
    (
        CASE
            WHEN CN.PAYSESSIONID IS NULL
            AND AR.AR_TYPE = 1
            THEN SUM(-ART.AMOUNT)
            ELSE
                  (
                  SELECT
                      SUM(-CRT.AMOUNT)
                  FROM
                      CASHREGISTERTRANSACTIONS CRT
                  WHERE
                      CRT.CENTER = CN.CASHREGISTER_CENTER
                  AND CRT.ID = CN.CASHREGISTER_ID
                  AND CRT.PAYSESSIONID = CN.PAYSESSIONID
                  AND CRT.CRTTYPE IN (5) )
        END ) AR_CASH,
    (
        CASE
            WHEN CN.PAYSESSIONID IS NULL
            AND AR.AR_TYPE = 4
            THEN SUM(-ART.AMOUNT)
            ELSE
                  (
                  SELECT
                      SUM(-CRT.AMOUNT)
                  FROM
                      CASHREGISTERTRANSACTIONS CRT
                  WHERE
                      CRT.CENTER = CN.CASHREGISTER_CENTER
                  AND CRT.ID = CN.CASHREGISTER_ID
                  AND CRT.PAYSESSIONID = CN.PAYSESSIONID
                  AND CRT.CRTTYPE IN (12) )
        END ) AR_PAY,
    (
        SELECT
            -SUM(CRT.AMOUNT)
        FROM
            CASHREGISTERTRANSACTIONS CRT
        WHERE
            CRT.CENTER = CN.CASHREGISTER_CENTER
        AND CRT.ID = CN.CASHREGISTER_ID
        AND CRT.PAYSESSIONID = CN.PAYSESSIONID
        AND CRT.CRTTYPE IN (2) ) CHANGE,
    (
        SELECT
            SUM(CRT.AMOUNT)
        FROM
            CASHREGISTERTRANSACTIONS CRT
        WHERE
            CRT.CENTER = CN.CASHREGISTER_CENTER
        AND CRT.ID = CN.CASHREGISTER_ID
        AND CRT.PAYSESSIONID = CN.PAYSESSIONID
        AND CRT.CRTTYPE IN (9) ) GIFTCARD,
    (
        SELECT
            SUM(CRT.AMOUNT)
        FROM
            CASHREGISTERTRANSACTIONS CRT
        WHERE
            CRT.CENTER = CN.CASHREGISTER_CENTER
        AND CRT.ID = CN.CASHREGISTER_ID
        AND CRT.PAYSESSIONID = CN.PAYSESSIONID
        AND CRT.CRTTYPE IN (13) ) CUSTOM,
    (
        SELECT
            SUM(CRT.AMOUNT)
        FROM
            CASHREGISTERTRANSACTIONS CRT
        WHERE
            CRT.CENTER = CN.CASHREGISTER_CENTER
        AND CRT.ID = CN.CASHREGISTER_ID
        AND CRT.PAYSESSIONID = CN.PAYSESSIONID
        AND CRT.CRTTYPE NOT IN (1,2,4,5,6,7,9,12,13,18) ) OTHER
FROM
    CREDIT_NOTE_LINES CNL
INNER JOIN
    CREDIT_NOTES CN
ON
    (
        CNL.CENTER = CN.CENTER
    AND CNL.ID = CN.ID )
LEFT JOIN
    CASHREGISTERREPORTS CRR
ON
    (
        CRR.CENTER = CN.CASHREGISTER_CENTER
    AND CRR.ID = CN.CASHREGISTER_ID
    AND CRR.STARTTIME <= CN.ENTRY_TIME
    AND CRR.REPORTTIME > CN.ENTRY_TIME )
LEFT JOIN
    PERSONS PER
ON
    (
        CNL.PERSON_CENTER = PER.center
    AND CNL.PERSON_ID = PER.id )
LEFT JOIN
    AR_TRANS ART
ON
    (
        ART.REF_CENTER = CN.CENTER
    AND ART.REF_ID = CN.ID
    AND ART.REF_TYPE = 'CREDIT_NOTE' )
LEFT JOIN
    ACCOUNT_RECEIVABLES AR
ON
    (
        ART.CENTER = AR.CENTER
    AND ART.ID = AR.ID )
WHERE
    (
        CN.CASHREGISTER_CENTER = :Center
    AND CN.ENTRY_TIME >= :FromDate
    AND CN.ENTRY_TIME < :ToDate + (1000*60*60*24)

    )
GROUP BY
    CN.CASHREGISTER_CENTER,
    CN.CASHREGISTER_ID,
    CN.CENTER,
    CN.ID,
    CN.ENTRY_TIME,
    CN.TEXT,
    CNL.PERSON_CENTER,
    CNL.PERSON_ID,
    CN.PAYSESSIONID,
    AR.AR_TYPE,
    PER.PERSONTYPE
