SELECT
        t2.PERSONID,
        t2.BILLED_UNTIL_DATE,
        t2.SUB_START_DATE,
        t2.SUB_END_DATE,
        t2.PRODUCT_NAME,
        t2.PRODUCT_GLOBALID,
        t2.SPP_FROM_DATE,
        t2.SPP_TO_DATE,
        t2.INVOICE_DAYS,
        t2.INV_TOTAL_AMOUNT,
        t2.CREDIT_PERIOD_START,
        t2.CREDIT_PERIOD_END,
        ROUND(t2.DAILY_PRICE, 2) AS DAILY_PRICE,
        t2.CREDIT_DAYS AS CREDIT_DAYS,
        ROUND(t2.DAILY_PRICE * t2.CREDIT_DAYS, 2) AS CREDIT_AMOUNT,
        t2.BOOK_DATE,
        'PartialCreditnote ' || t2.PRODUCT_NAME ||': ' || t2.CREDIT_PERIOD_START || ' - '|| t2.CREDIT_PERIOD_END AS CREDIT_NOTE_TEXT,
        --1 AS threadnumber,
        t2.SUB_CENTER,
        t2.SUB_ID,
        'PAYMENT' AS accountType,
        t2.PROD_CENTER,
        t2.PROD_ID,
        (CASE t2.PRODUCT_GLOBALID
                WHEN 'ALL_INCLUSIVE_BND' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.224,2)  
                WHEN 'ALL_INCLUSIVE_NOBND' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.201,2)
                WHEN 'NORDIC_DAYTIME_BND_GX' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.155,2)
                WHEN 'NORDIC_DAYTIME_BND_CON' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.27,2)
                WHEN 'NORDIC_DAYTIME_NOBND_CON' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.237,2)
                WHEN 'NORDIC_DAYTIME_NOBND_GX' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.134,2)
                WHEN 'NORDIC_ALLDAY_BND_GX' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.142,2)
                WHEN 'NORDIC_ALLDAY_BND_CON' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.249,2)
                WHEN 'NORDIC_ALLDAY_NOBND_CON' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.222,2)
                WHEN 'NORDIC_ALLDAY_NOBND_GX' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.124,2)
                WHEN '1CLUB_DAYTIME_BND_GX' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.177,2)
                WHEN '1CLUB_DAYTIME_BND_CON' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.302,2)
                WHEN '1CLUB_DAYTIME_NOBND_CON' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.263,2)
                WHEN '1CLUB_DAYTIME_NOBND_GX' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.15,2)
                WHEN '1CLUB_ALLDAY_BND_GX' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.16,2)
                WHEN '1CLUB_ALLDAY_BND_CON' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.277,2)
                WHEN '1CLUB_ALLDAY_NOBND_CON' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.243,2)
                WHEN '1CLUB_ALLDAY_NOBND_GX' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.138,2)
                WHEN 'REGION_DAYTIME_BND_GX' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.158,2)
                WHEN 'REGION_DAYTIME_BND_CON' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.273,2)
                WHEN 'REGION_DAYTIME_NOBND_CON' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.24,2)
                WHEN 'REGION_DAYTIME_NOBND_GX' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.136,2)
                WHEN 'REGION_ALLDAY_BND_GX' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.144,2)
                WHEN 'REGION_ALLDAY_BND_CON' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.253,2)
                WHEN 'REGION_ALLDAY_NOBND_CON' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.224,2)
                WHEN 'REGION_ALLDAY_NOBND_GX' THEN ROUND(t2.INV_TOTAL_AMOUNT*0.126,2)
                ELSE 0
        END) AS NEW_CREDIT_AMOUNT,
        1,
        t2.BOOK_DATE,
        (CASE WHEN t2.PRODUCT_GLOBALID IN ('ALL_INCLUSIVE_BND','ALL_INCLUSIVE_NOBND','NORDIC_DAYTIME_BND_CON','NORDIC_DAYTIME_NOBND_CON','NORDIC_ALLDAY_BND_CON',
                                        'NORDIC_ALLDAY_NOBND_CON','1CLUB_DAYTIME_BND_CON','1CLUB_DAYTIME_NOBND_CON','1CLUB_ALLDAY_BND_CON','1CLUB_ALLDAY_NOBND_CON',
                                        'REGION_DAYTIME_BND_CON','REGION_DAYTIME_NOBND_CON','REGION_ALLDAY_BND_CON','REGION_ALLDAY_NOBND_CON')
                                      THEN 'Compensate group training and concepts March 2021'
              ELSE 'Compensate group training March 2021'
        END) AS NEW_CREDIT_NOTE_TEXT
FROM
(
        SELECT
                t1.*,
                t1.INV_TOTAL_AMOUNT / t1.INVOICE_DAYS AS DAILY_PRICE,
                t1.CREDIT_PERIOD_END - t1.CREDIT_PERIOD_START + 1 AS CREDIT_DAYS
        FROM
        (
                WITH
                        params AS
                        (
                                SELECT
                                        /*+ materialize */
                                        c.id                               AS CENTER_ID,
                                        :fromDate AS FROM_DATE,
                                        :toDate AS TO_DATE,
                                        TO_CHAR(CURRENT_DATE,'YYYY-MM-DD') AS TODAYS_DATE
                                FROM
                                        CENTERS c
                                WHERE
                                        c.ID IN (702,703,705,710,713,714,715,716,717,718,723,724,725,726,727,728,729,730,731,732,733,735,736,738,739,740,742)
                        )
                SELECT
                        s.OWNER_CENTER || 'p' || s.OWNER_ID AS PERSONID,
                        s.BILLED_UNTIL_DATE,
                        s.START_DATE AS SUB_START_DATE,
                        s.END_DATE AS SUB_END_DATE,
                        pr.NAME AS PRODUCT_NAME,
                        pr.GLOBALID AS PRODUCT_GLOBALID,
                        spp.FROM_DATE AS SPP_FROM_DATE,
                        spp.TO_DATE AS SPP_TO_DATE,
                        spp.TO_DATE - spp.FROM_DATE +1 AS INVOICE_DAYS,
                        il.TOTAL_AMOUNT AS INV_TOTAL_AMOUNT,
                        GREATEST(spp.FROM_DATE, params.FROM_DATE) AS CREDIT_PERIOD_START,
                        LEAST(spp.TO_DATE, params.TO_DATE) AS CREDIT_PERIOD_END,
                        pr.PTYPE,
                        params.TODAYS_DATE AS BOOK_DATE,
                        s.CENTER AS SUB_CENTER,
                        s.ID AS SUB_ID,
                        pr.CENTER AS PROD_CENTER,
                        pr.ID AS PROD_ID
                FROM SUBSCRIPTIONS s
                JOIN params
                        ON params.CENTER_ID = s.CENTER
                JOIN SUBSCRIPTIONTYPES st 
                        ON st.CENTER = s.SUBSCRIPTIONTYPE_CENTER AND st.ID = s.SUBSCRIPTIONTYPE_ID AND st.ST_TYPE = 1
                JOIN SUBSCRIPTIONPERIODPARTS spp
                        ON spp.CENTER = s.CENTER AND spp.ID = s.ID AND spp.FROM_DATE <= params.TO_DATE AND spp.TO_DATE >= params.FROM_DATE AND spp.SPP_STATE = 1
                JOIN SPP_INVOICELINES_LINK spplink
                        ON spplink.PERIOD_CENTER = spp.CENTER AND spplink.PERIOD_ID = spp.ID AND spplink.PERIOD_SUBID = spp.SUBID
                JOIN INVOICE_LINES_MT il
                        ON il.CENTER = spplink.INVOICELINE_CENTER AND il.ID = spplink.INVOICELINE_ID AND il.SUBID = spplink.INVOICELINE_SUBID
                JOIN PRODUCTS pr
                        ON pr.CENTER = il.PRODUCTCENTER AND pr.ID = il.PRODUCTID
				WHERE pr.GLOBALID IN ('ALL_INCLUSIVE_BND','ALL_INCLUSIVE_NOBND','NORDIC_DAYTIME_BND_GX','NORDIC_DAYTIME_BND_CON','NORDIC_DAYTIME_NOBND_CON',
                        'NORDIC_DAYTIME_NOBND_GX','NORDIC_ALLDAY_BND_GX','NORDIC_ALLDAY_BND_CON','NORDIC_ALLDAY_NOBND_CON','NORDIC_ALLDAY_NOBND_GX',
                        '1CLUB_DAYTIME_BND_GX','1CLUB_DAYTIME_BND_CON','1CLUB_DAYTIME_NOBND_CON','1CLUB_DAYTIME_NOBND_GX','1CLUB_ALLDAY_BND_GX',
                        '1CLUB_ALLDAY_BND_CON','1CLUB_ALLDAY_NOBND_CON','1CLUB_ALLDAY_NOBND_GX','REGION_DAYTIME_BND_GX','REGION_DAYTIME_BND_CON',
                        'REGION_DAYTIME_NOBND_CON','REGION_DAYTIME_NOBND_GX','REGION_ALLDAY_BND_GX','REGION_ALLDAY_BND_CON','REGION_ALLDAY_NOBND_CON','REGION_ALLDAY_NOBND_GX')
        ) t1
WHERE t1.INV_TOTAL_AMOUNT > 0
) t2