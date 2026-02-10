-- The extract is extracted from Exerp on 2026-02-08
--  
/* Based on Cash register sales by payment type */
SELECT
   i1.SALES_CENTER
  , i1.BETAL_DATUM
  , i1.MEDLEMS_NUMMER
  , i1.KUND_TYP
  , i1.TYP
  , i1.SUMMA	
  ,i1.CUSTOM PROD_TYPE_ID

FROM
    (
        SELECT
            INV0.CASHREGISTER_CENTER                                   AS CLUB
          , INV0.CASHREGISTER_ID                                       AS CR_ID
          , INV0.CENTER                                                AS SALES_CENTER
          , INV0.ID                                                    AS SALES_ID
          , TO_CHAR(longtodate(INV0.ENTRY_TIME), 'YYYY-MM-DD HH24:MI')    BETAL_DATUM
          , CASE
                WHEN IL.PERSON_CENTER IS NOT NULL
                THEN IL.PERSON_CENTER || 'p' || IL.PERSON_ID
                ELSE NULL
            END MEDLEMS_NUMMER
          , CASE
                WHEN IL.PERSON_CENTER IS NOT NULL
                THEN CASE  PER.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN  'CORPORATE'  WHEN 5 THEN  'ONEMANCORPORATE'  WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END
                ELSE NULL
            END                                                                           KUND_TYP
          , MIN(IL.TEXT) || '...'                                                         TYP
          , SUM(IL.QUANTITY)                                                              ANTAL
          , SUM(ROUND(IL.TOTAL_AMOUNT - (IL.TOTAL_AMOUNT * (1 - (1 / (1 + IL.RATE)))),2)) NETTO
          , SUM(ROUND(IL.TOTAL_AMOUNT * (1 - (1 / (1 + IL.RATE))),2))                     MOMS
          , SUM(ROUND(IL.TOTAL_AMOUNT, 2))                                                SUMMA
          , (
                SELECT
                    SUM(CRT.AMOUNT)
                FROM
                    CASHREGISTERTRANSACTIONS CRT
                WHERE
                    CRT.CENTER = INV0.CASHREGISTER_CENTER
                    AND CRT.ID = INV0.CASHREGISTER_ID
                    AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
                    AND CRT.CRTTYPE IN (1) ) CASH
          , (
                SELECT
                    SUM(CRT.AMOUNT)
                FROM
                    CASHREGISTERTRANSACTIONS CRT
                WHERE
                    CRT.CENTER = INV0.CASHREGISTER_CENTER
                    AND CRT.ID = INV0.CASHREGISTER_ID
                    AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
                    AND CRT.CRTTYPE IN (6,7,8) ) CARD
          , (
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
                END ) AR_CASH
          , (
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
                END ) AR_PAY
          , (
                SELECT
                    - SUM(CRT.AMOUNT)
                FROM
                    CASHREGISTERTRANSACTIONS CRT
                WHERE
                    CRT.CENTER = INV0.CASHREGISTER_CENTER
                    AND CRT.ID = INV0.CASHREGISTER_ID
                    AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
                    AND CRT.CRTTYPE IN (2) ) CHANGE
          , (
                SELECT
                    SUM(CRT.AMOUNT)
                FROM
                    CASHREGISTERTRANSACTIONS CRT
                WHERE
                    CRT.CENTER = INV0.CASHREGISTER_CENTER
                    AND CRT.ID = INV0.CASHREGISTER_ID
                    AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
                    AND CRT.CRTTYPE IN (9) ) GIFTCARD
          , (
                SELECT
                    SUM(CRT.AMOUNT)
                FROM
                    CASHREGISTERTRANSACTIONS CRT
                WHERE
                    CRT.CENTER = INV0.CASHREGISTER_CENTER
                    AND CRT.ID = INV0.CASHREGISTER_ID
                    AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
                    AND CRT.CRTTYPE IN (13) ) CUSTOM
          , (
                SELECT
                    SUM(CRT.AMOUNT)
                FROM
                    CASHREGISTERTRANSACTIONS CRT
                WHERE
                    CRT.CENTER = INV0.CASHREGISTER_CENTER
                    AND CRT.ID = INV0.CASHREGISTER_ID
                    AND CRT.PAYSESSIONID = INV0.PAYSESSIONID
                    AND CRT.CRTTYPE NOT IN (1,2,4,5,6,7,9,12,13,18) ) OTHER
          ,prod.PTYPE
          ,CASE WHEN spl.PRODUCT_CENTER IS NOT NULL THEN 1 ELSE 0 END                    SHARED_MUNICIPALITY
          ,'INVOICE'                                       as "TYPE"
          ,IL.CENTER || 'inv' || IL.ID || 'ln' || IL.SUBID trans_id
        FROM
            INVOICELINES IL
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = IL.PRODUCTCENTER
            AND prod.ID = IL.PRODUCTID
            /* To get the Share municipality link*/
        LEFT JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK spl
        ON
            spl.PRODUCT_CENTER = prod.CENTER
            AND spl.PRODUCT_ID = prod.ID
            AND spl.PRODUCT_GROUP_ID = 8825
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
                INV0.CASHREGISTER_CENTER = $$center$$
                AND IL.TOTAL_AMOUNT <> 0
                AND INV0.ENTRY_TIME >= $$FromDate$$
                AND INV0.ENTRY_TIME < $$ToDate$$ 
				AND NOT (INV0.EMPLOYEE_CENTER = 100 AND INV0.EMPLOYEE_ID = 6204)-- Remove sales made by API-User.
				)
        GROUP BY
            INV0.CASHREGISTER_CENTER
          , INV0.CASHREGISTER_ID
          , INV0.CENTER
          , INV0.ID
          , INV0.ENTRY_TIME
          , INV0.TEXT
          , IL.PERSON_CENTER
          , IL.PERSON_ID
          , INV0.PAYSESSIONID
          , AR.AR_TYPE
          , PER.PERSONTYPE
          ,prod.PTYPE
          ,IL.CENTER || 'inv' || IL.ID || 'ln' || IL.SUBID
            --          ,CRT.CRTTYPE
          ,CASE WHEN spl.PRODUCT_CENTER IS NOT NULL THEN 1 ELSE 0 END
          ,"TYPE"
        UNION ALL
        SELECT
            CN.CASHREGISTER_CENTER                                   AS CR_CENTER
          , CN.CASHREGISTER_ID                                       AS CR_ID
          , CN.CENTER                                                AS CN_CENTER
          , CN.ID                                                       CN_ID
          , TO_CHAR(longtodate(CN.ENTRY_TIME), 'YYYY-MM-DD HH24:MI')    entryDate
          , CASE
                WHEN CNL.PERSON_CENTER IS NOT NULL
                THEN CNL.PERSON_CENTER || 'p' || CNL.PERSON_ID
                ELSE NULL
            END person_id
          , CASE
                WHEN CNL.PERSON_CENTER IS NOT NULL
                THEN CASE  PER.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN  'CORPORATE'  WHEN 5 THEN  'ONEMANCORPORATE'  WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END
                ELSE NULL
            END person_type
          , MIN(CNL.TEXT) || '...'
          , - SUM(CNL.QUANTITY)                                                                quantity
          , - SUM(ROUND(CNL.TOTAL_AMOUNT - (CNL.TOTAL_AMOUNT * (1 - (1 / (1 + CNL.RATE)))),2)) excluding_Vat
          , - SUM(ROUND(CNL.TOTAL_AMOUNT * (1 - (1 / (1 + CNL.RATE))),2))                      included_Vat
          , - SUM(ROUND(CNL.TOTAL_AMOUNT, 2))                                                  total_Amount
          , (
                SELECT
                    SUM( - CRT.AMOUNT)
                FROM
                    CASHREGISTERTRANSACTIONS CRT
                WHERE
                    CRT.CENTER = CN.CASHREGISTER_CENTER
                    AND CRT.ID = CN.CASHREGISTER_ID
                    AND CRT.PAYSESSIONID = CN.PAYSESSIONID
                    AND CRT.CRTTYPE IN (4) ) CASH
          , (
                SELECT
                    SUM( - CRT.AMOUNT)
                FROM
                    CASHREGISTERTRANSACTIONS CRT
                WHERE
                    CRT.CENTER = CN.CASHREGISTER_CENTER
                    AND CRT.ID = CN.CASHREGISTER_ID
                    AND CRT.PAYSESSIONID = CN.PAYSESSIONID
                    AND CRT.CRTTYPE IN (18) ) CARD
          , (
                CASE
                    WHEN CN.PAYSESSIONID IS NULL
                        AND AR.AR_TYPE = 1
                    THEN SUM( - ART.AMOUNT)
                    ELSE
                          (
                          SELECT
                              SUM( - CRT.AMOUNT)
                          FROM
                              CASHREGISTERTRANSACTIONS CRT
                          WHERE
                              CRT.CENTER = CN.CASHREGISTER_CENTER
                              AND CRT.ID = CN.CASHREGISTER_ID
                              AND CRT.PAYSESSIONID = CN.PAYSESSIONID
                              AND CRT.CRTTYPE IN (5) )
                END ) AR_CASH
          , (
                CASE
                    WHEN CN.PAYSESSIONID IS NULL
                        AND AR.AR_TYPE = 4
                    THEN SUM( - ART.AMOUNT)
                    ELSE
                          (
                          SELECT
                              SUM( - CRT.AMOUNT)
                          FROM
                              CASHREGISTERTRANSACTIONS CRT
                          WHERE
                              CRT.CENTER = CN.CASHREGISTER_CENTER
                              AND CRT.ID = CN.CASHREGISTER_ID
                              AND CRT.PAYSESSIONID = CN.PAYSESSIONID
                              AND CRT.CRTTYPE IN (12) )
                END ) AR_PAY
          , (
                SELECT
                    - SUM(CRT.AMOUNT)
                FROM
                    CASHREGISTERTRANSACTIONS CRT
                WHERE
                    CRT.CENTER = CN.CASHREGISTER_CENTER
                    AND CRT.ID = CN.CASHREGISTER_ID
                    AND CRT.PAYSESSIONID = CN.PAYSESSIONID
                    AND CRT.CRTTYPE IN (2) ) CHANGE
          , (
                SELECT
                    SUM(CRT.AMOUNT)
                FROM
                    CASHREGISTERTRANSACTIONS CRT
                WHERE
                    CRT.CENTER = CN.CASHREGISTER_CENTER
                    AND CRT.ID = CN.CASHREGISTER_ID
                    AND CRT.PAYSESSIONID = CN.PAYSESSIONID
                    AND CRT.CRTTYPE IN (9) ) GIFTCARD
          , (
                SELECT
                    SUM(CRT.AMOUNT)
                FROM
                    CASHREGISTERTRANSACTIONS CRT
                WHERE
                    CRT.CENTER = CN.CASHREGISTER_CENTER
                    AND CRT.ID = CN.CASHREGISTER_ID
                    AND CRT.PAYSESSIONID = CN.PAYSESSIONID
                    AND CRT.CRTTYPE IN (13) ) CUSTOM
          , (
                SELECT
                    SUM(CRT.AMOUNT)
                FROM
                    CASHREGISTERTRANSACTIONS CRT
                WHERE
                    CRT.CENTER = CN.CASHREGISTER_CENTER
                    AND CRT.ID = CN.CASHREGISTER_ID
                    AND CRT.PAYSESSIONID = CN.PAYSESSIONID
                    AND CRT.CRTTYPE NOT IN (1,2,4,5,6,7,9,12,13,18) ) OTHER
          ,prod.PTYPE
          ,CASE WHEN spl.PRODUCT_CENTER IS NOT NULL THEN 1 ELSE 0 END             SHARED_MUNICIPALITY
          ,'CREDIT'                                 as "TYPE"
          ,CNL.CENTER || 'inv' || CNL.ID || 'ln' || CNL.SUBID
        FROM
            CREDIT_NOTE_LINES CNL
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = CNL.PRODUCTCENTER
            AND prod.id = CNL.PRODUCTID
            /* To get the Share municipality link*/
        LEFT JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK spl
        ON
            spl.PRODUCT_CENTER = prod.CENTER
            AND spl.PRODUCT_ID = prod.ID
            AND spl.PRODUCT_GROUP_ID = 8825
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
                CN.CASHREGISTER_CENTER = $$center$$
                AND CN.ENTRY_TIME >= $$FromDate$$
                AND CN.ENTRY_TIME < $$ToDate$$ 
				AND NOT (CN.EMPLOYEE_CENTER = 100 AND CN.EMPLOYEE_ID = 6204) -- Remove sales made by API-User.
		)
        GROUP BY
            CN.CASHREGISTER_CENTER
          , CN.CASHREGISTER_ID
          , CN.CENTER
          , CN.ID
          , CN.ENTRY_TIME
          , CN.TEXT
          , CNL.PERSON_CENTER
          , CNL.PERSON_ID
          , CN.PAYSESSIONID
          , AR.AR_TYPE
          , PER.PERSONTYPE
          , prod.PTYPE
          ,CNL.CENTER || 'inv' || CNL.ID || 'ln' || CNL.SUBID
          ,"TYPE"
          ,CASE WHEN spl.PRODUCT_CENTER IS NOT NULL THEN 1 ELSE 0 END ) i1
WHERE
    ( (
            i1.ptype IN (1, 2, 4, 5, 8, 10, 13, 14)
            OR (
                i1.shared_municipality = 1
                AND i1.ptype IN (4,2) ) )
        AND ( (
                i1.CASH IS NOT NULL
                AND 'CASH' IN ($$kind$$) )
            OR (
                i1.CARD IS NOT NULL
                AND 'CARD' IN ($$kind$$) )
            OR (
                i1.AR_CASH IS NOT NULL
                AND 'AR_CASH' IN ($$kind$$) )
            OR (
                i1.AR_PAY IS NOT NULL
                AND 'AR_PAY' IN ($$kind$$) )
            OR (
                i1.CHANGE IS NOT NULL
                AND 'CHANGE' IN ($$kind$$) )
            OR (
                i1.GIFTCARD IS NOT NULL
                AND 'GIFTCARD' IN ($$kind$$) )
            OR (
                i1.CUSTOM IS NOT NULL
                AND 'CUSTOM' IN ($$kind$$) )
            OR (
                i1.OTHER IS NOT NULL
                AND 'OTHER' IN ($$kind$$) ) ) )
    OR (
        i1.ptype IN (1, 2, 4, 5, 8, 10, 13, 14)
        --AND i1.CRTTYPE IS NULL
       AND i1.ANTAL < 0)
		AND i1."TYPE" LIKE 'INVOICE'
