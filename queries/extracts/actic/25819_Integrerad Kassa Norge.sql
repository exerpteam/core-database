/* Based on Cash register sales by payment type */
SELECT
    TO_CHAR(TRUNC(ADD_MONTHS(((date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date+1),-2)),'YYYY-MM-DD') "PERIOD_FROM"
  ,TO_CHAR(TRUNC(ADD_MONTHS(((date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date),-1)),'YYYY-MM-DD')    "PERIOD_TO"
  ,i2.center_name "CENTER_NAME"
  , i2.TODAY "TODAY"
  ,i2.COMPANY_NAME "COMPANY_NAME"
  ,i2.ADDRESS1 "ADDRESS1"
  ,i2.ADDRESS2 "ADDRESS2"
  ,i2.ZIPCODE "ZIPCODE"
  ,i2.CITY "CITY"
  ,i2.SPLIT_RATE_COMMUNITY "SPLIT_RATE_COMMUNITY"
  , i1.CLUB "CLUB"
  , i1.CR_ID "CR_ID"
  , i1.SALES_CENTER "SALES_CENTER"
  , i1.SALES_ID "SALES_ID"
  , i1.BETAL_DATUM "BETAL_DATUM"
  , i1.MEDLEMS_NUMMER "MEDLEMS_NUMMER"
  , i1.KUND_TYP "KUND_TYP"
  , i1.TYP "TYP"
  , i1.ANTAL || ' '                        "ANTAL"
  , SUM(i1.ANTAL) over (partition BY 1) AS "ANTAL_SUMMED"
  , i1.NETTO "NETTO"
  , SUM(i1.NETTO) over (partition BY 1) AS                           "TOTAL_ECL_VAT_SUMMED"
  ,SUM(i1.NETTO) over (partition BY 1)  AS                           "TOTAL_ECL_VAT_SUMMED"
    /*                                                               NETTO GYM + ATT FãRDELA */
  , i2.SPLIT_RATE_COMMUNITY * SUM(i1.NETTO) over (partition BY 1) AS "COMMUNITY_PART"
  , i1.MOMS "MOMS"
  , SUM(i1.MOMS) over (partition BY 1) AS "VAT_SUMMED"
    /*                                    Moms */
  , i1.SUMMA "SUMMA"
  , SUM(i1.SUMMA) over (partition BY 1) AS "TOTAL_INC_VAT_SUMMED"
    /*                                     SUMMA */
  , i1.CASH "CASH"
  , i1.CARD "CARD"
  , i1.AR_CASH "AR_CASH"
  , i1.AR_PAY "AR_PAY"
  , i1.CHANGE "CHANGE"
  , i1.GIFTCARD "GIFTCARD"
  , i1.CUSTOM "CUSTOM"
  , i1.OTHER "OTHER"
  ,i1.ptype                                                                                                                                                                                                        "PROD_TYPE_ID"
  ,CASE PTYPE  WHEN 1 THEN  'Retail'  WHEN 2 THEN  'Service'  WHEN 4 THEN  'Clipcard'  WHEN 5 THEN  'Subscription creation'  WHEN 6 THEN  'Transfer'  WHEN 7 THEN  'Freeze period'  WHEN 8 THEN  'Gift card'  WHEN 9 THEN  'Free gift card'  WHEN 10 THEN  'Subscription'  WHEN 12 THEN  'Subscription pro-rata'  WHEN 13 THEN  'Subscription add-on'  WHEN 14 THEN  'Access product' END "PROD_TYPE_NAME"
  ,i1.shared_municipality "SHARED_MUNICIPALITY"
  ,i1.type "TYPE"
  ,i1.trans_id "TRANS_ID"
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
          , SUM(ROUND(IL.TOTAL_AMOUNT - (IL.TOTAL_AMOUNT * (1 - (1 / (1 + COALESCE(IL.RATE,0))))),2)) NETTO
          , SUM(ROUND(IL.TOTAL_AMOUNT * (1 - (1 / (1 + COALESCE(IL.RATE,0)))),2))                     MOMS
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
          ,'INVOICE'                                       as TYPE
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
                AND INV0.ENTRY_TIME >= dateToLongC(TO_CHAR(TRUNC(ADD_MONTHS(((date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date+1),-2)), 'YYYYMMdd HH24:MI'),$$center$$)
                AND INV0.ENTRY_TIME < dateToLongC(TO_CHAR(TRUNC(ADD_MONTHS(((date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date+1),-1)), 'YYYYMMdd HH24:MI'),$$center$$)

				OR(
					INV0.CASHREGISTER_CENTER = 500 and per.center = $$center$$ 
                	AND IL.TOTAL_AMOUNT <> 0
                	AND INV0.ENTRY_TIME >= dateToLongC(TO_CHAR(TRUNC(ADD_MONTHS(((date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date+1),-2)), 'YYYYMMdd HH24:MI'),$$center$$)
                	AND INV0.ENTRY_TIME < dateToLongC(TO_CHAR(TRUNC(ADD_MONTHS(((date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date+1),-1)), 'YYYYMMdd HH24:MI'),$$center$$)
				)
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
            ) )
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
          ,type
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
          , - SUM(ROUND(CNL.TOTAL_AMOUNT - (CNL.TOTAL_AMOUNT * (1 - (1 / (1 + COALESCE(CNL.RATE,0))))),2)) excluding_Vat
          , - SUM(ROUND(CNL.TOTAL_AMOUNT * (1 - (1 / (1 + COALESCE(CNL.RATE,0)))),2))                      included_Vat
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
          ,'CREDIT'                                 as TYPE
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
                AND CN.ENTRY_TIME >= dateToLongC(TO_CHAR(TRUNC(ADD_MONTHS(((date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date+1),-2)), 'YYYYMMdd HH24:MI'),$$center$$)
                AND CN.ENTRY_TIME < dateToLongC(TO_CHAR(TRUNC(ADD_MONTHS(((date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date+1),-1)), 'YYYYMMdd HH24:MI'),$$center$$)
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
            ) )
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
          ,type
          ,CASE WHEN spl.PRODUCT_CENTER IS NOT NULL THEN 1 ELSE 0 END ) i1
JOIN
    (
        SELECT
            TO_CHAR(current_timestamp ,'YYYY-MM-DD') today
          ,p.LASTNAME                      COMPANY_NAME
          ,p.ADDRESS1
          ,p.ADDRESS2
          ,p.ZIPCODE
          ,p.CITY
          ,atts.TXTVALUE::DECIMAL / 100 SPLIT_RATE_COMMUNITY
          ,c.NAME              CENTER_NAME
        FROM
            PERSONS p
        JOIN
            CENTERS c
        ON
            c.id = $$center$$
        JOIN
            PERSON_EXT_ATTRS atts
        ON
            atts.PERSONCENTER = p.CENTER
            AND atts.PERSONID = p.ID
            AND atts.NAME = 'SPLIT_RATE_COMMUNITY'
        WHERE
            p.LASTNAME LIKE '8' || REPLACE(lpad($$center$$::VARCHAR,3),' ','0') || ' %') i2
ON
    1 = 1
WHERE
    ( (
            i1.ptype IN (5,10)
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
        i1.ptype IN (5,10)
        --AND i1.CRTTYPE IS NULL
        AND i1.ANTAL < 0)
		--AND i1.SUMMA <> 0
		AND i1.type LIKE 'INVOICE'
