/* Based on Cash register sales by payment type */
WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				TO_CHAR(TRUNC(ADD_MONTHS(LAST_DAY(to_date(getcentertime(100), 'YYYY-MM-DD HH24:MI'))+1,-2)),'YYYY-MM-DD') AS periodFrom,
				TO_CHAR(TRUNC(ADD_MONTHS(LAST_DAY(to_date(getcentertime(100), 'YYYY-MM-DD HH24:MI')),-1)),'YYYY-MM-DD') AS periodTo,
				datetolongTZ(TO_CHAR(TRUNC(ADD_MONTHS(LAST_DAY(to_date(getcentertime(100), 'YYYY-MM-DD HH24:MI'))+1,-2)), 'YYYY-MM-DD HH24:MI'),'Europe/Stockholm') AS periodFromLong,
				datetolongTZ(TO_CHAR(TRUNC(ADD_MONTHS(LAST_DAY(to_date(getcentertime(100), 'YYYY-MM-DD HH24:MI'))+1,-1)), 'YYYY-MM-DD HH24:MI'),'Europe/Stockholm') AS periodToLong,
				getcentertime(100) AS todaysDate
		FROM DUAL
    )
SELECT
    params.periodFrom PERIOD_FROM
   ,params.periodTo period_to
  ,i2.center_name
  , i2.TODAY
  ,i2.COMPANY_NAME
  ,i2.ADDRESS1
  ,i2.ADDRESS2
  ,i2.ZIPCODE
  ,i2.CITY
  ,i2.SPLIT_RATE_COMMUNITY
  , i1.CLUB
  , i1.CR_ID
  , i1.SALES_CENTER
  , i1.SALES_ID
  , i1.BETAL_DATUM
  , i1.MEDLEMS_NUMMER
  , i1.KUND_TYP
  , i1.TYP
  , i1.ANTAL || ' '                        ANTAL
  , SUM(i1.ANTAL) over (partition BY 1) AS ANTAL_SUMMED
  , i1.NETTO
  , SUM(i1.NETTO) over (partition BY 1) AS                           TOTAL_ECL_VAT_SUMMED
  ,SUM(i1.NETTO) over (partition BY 1)  AS                           TOTAL_ECL_VAT_SUMMED
    /*                                                               NETTO GYM + ATT FØRDELA */
  , i2.SPLIT_RATE_COMMUNITY * SUM(i1.NETTO) over (partition BY 1) AS COMMUNITY_PART
  , i1.MOMS
  , SUM(i1.MOMS) over (partition BY 1) AS VAT_SUMMED
    /*                                    Moms */
  , i1.SUMMA
  , SUM(i1.SUMMA) over (partition BY 1) AS TOTAL_INC_VAT_SUMMED
    /*                                     SUMMA */
  , i1.CASH
  , i1.CARD
  , i1.AR_CASH
  , i1.AR_PAY
  , i1.CHANGE
  , i1.GIFTCARD
  , i1.CUSTOM
  , i1.OTHER
  ,i1.ptype                                                                                                                                                                                                        PROD_TYPE_ID
  ,DECODE(PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription pro-rata', 13, 'Subscription add-on', 14, 'Access product') PROD_TYPE_NAME
  ,i1.shared_municipality
  ,i1.type
  ,i1.trans_id
FROM
	PARAMS params 
CROSS JOIN
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
                THEN DECODE ( PER.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4, 'CORPORATE', 5, 'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')
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
          ,nvl2(spl.PRODUCT_CENTER,1,0)                    SHARED_MUNICIPALITY
          ,'INVOICE'                                       TYPE
          ,IL.CENTER || 'inv' || IL.ID || 'ln' || IL.SUBID trans_id
        FROM
            INVOICELINES IL
		CROSS JOIN PARAMS params
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
                AND INV0.ENTRY_TIME >= params.periodFromLong
                AND INV0.ENTRY_TIME < params.periodToLong
or(INV0.CASHREGISTER_CENTER = 100 and per.center = $$center$$ 
                AND IL.TOTAL_AMOUNT <> 0
                AND INV0.ENTRY_TIME >= params.periodFromLong
                AND INV0.ENTRY_TIME < params.periodToLong)
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
          ,nvl2(spl.PRODUCT_CENTER,1,0)
          ,'INVOICE'
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
                THEN DECODE ( PER.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4, 'CORPORATE', 5, 'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')
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
          ,nvl2(spl.PRODUCT_CENTER,1,0)             SHARED_MUNICIPALITY
          ,'CREDIT'                                 TYPE
          ,CNL.CENTER || 'inv' || CNL.ID || 'ln' || CNL.SUBID
        FROM
            CREDIT_NOTE_LINES CNL
		CROSS JOIN PARAMS params
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
                AND CN.ENTRY_TIME >= params.periodFromLong
                AND CN.ENTRY_TIME < params.periodToLong
or (cn.CASHREGISTER_CENTER = 100 and per.center = $$center$$ AND CN.ENTRY_TIME >= params.periodFromLong
                AND CN.ENTRY_TIME < params.periodToLong)
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
          ,'CREDIT'
          ,nvl2(spl.PRODUCT_CENTER,1,0) ) i1
JOIN
    (
        SELECT
           params.todaysDate today
          ,p.LASTNAME                      COMPANY_NAME
          ,p.ADDRESS1
          ,p.ADDRESS2
          ,p.ZIPCODE
          ,p.CITY
          ,atts.TXTVALUE / 100 SPLIT_RATE_COMMUNITY
          ,c.NAME              CENTER_NAME
        FROM
            PERSONS p
		CROSS JOIN PARAMS params
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
            p.LASTNAME LIKE '9' || REPLACE(lpad($$center$$,3),' ','0') || ' %') i2
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