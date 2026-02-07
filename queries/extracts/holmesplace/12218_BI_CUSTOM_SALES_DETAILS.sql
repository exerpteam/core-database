WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,-1,0,(TRUNC(SYSDATE)-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            (TRUNC(SYSDATE+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000                                  AS TODATE
        FROM
            dual
    )
SELECT
    biview.*
FROM
    params,
    (
        SELECT
            SUBSCRIPTION_SALES_ID,
            total_mc / sub_count AS MEMBER_CARD_VALUE,
            total_sp / sub_count AS STARTER_PACK_VALUE,
            total_sa / sub_count AS ADD_ON_VALUE
        FROM
            (
                SELECT DISTINCT
                    ss.ID                                                                                AS SUBSCRIPTION_SALES_ID,
                    il.center||'inv'||                                                                      il.id,
                    COUNT(DISTINCT s.center||'ss'||s.id) over (partition BY il.center,il.id)             AS sub_count,
                    SUM(DECODE(mc_pr.center,NULL,0,il.TOTAL_AMOUNT)) over (partition BY ss.id)           AS total_mc,
                    SUM(DECODE(sp_pr.center,NULL,0,il.TOTAL_AMOUNT)) over (partition BY il.center,il.id) AS total_sp,
                    SUM(
                        CASE
                            WHEN sa.ID IS NOT NULL
                                AND sa.USE_INDIVIDUAL_PRICE = 1
                            THEN sa.INDIVIDUAL_PRICE_PER_UNIT
                            WHEN sa.ID IS NOT NULL
                                AND sa.USE_INDIVIDUAL_PRICE = 1
                            THEN sa_pr.PRICE
                            ELSE 0
                        END) over (partition BY il.center,il.id)AS total_sa,
                    ss.LAST_MODIFIED                               "ETS"
                FROM
                    HP.INVOICE_LINES_MT il
                JOIN
                    HP.SUBSCRIPTIONS s
                ON
                    il.center = s.INVOICELINE_CENTER
                    AND il.id = s.INVOICELINE_ID
                JOIN
                    HP.SUBSCRIPTION_SALES ss
                ON
                    s.center = ss.SUBSCRIPTION_CENTER
                    AND s.id = ss.SUBSCRIPTION_ID
                LEFT JOIN
                    HP.PRODUCTS mc_pr
                ON
                    mc_pr.center = il.PRODUCTCENTER
                    AND mc_pr.id = il.PRODUCTID
                    AND mc_pr.GLOBALID = 'MEM_CARD'
                LEFT JOIN
                    HP.PRODUCTS sp_pr
                ON
                    sp_pr.center = il.PRODUCTCENTER
                    AND sp_pr.id = il.PRODUCTID
                    AND sp_pr.PRIMARY_PRODUCT_GROUP_ID IN (4603,
                                                           12480)
                LEFT JOIN
                    HP.SUBSCRIPTION_ADDON sa
                ON
                    sa.SUBSCRIPTION_CENTER = s.center
                    AND sa.SUBSCRIPTION_ID = s.id
                    AND sa.START_DATE BETWEEN s.START_DATE AND TRUNC(add_months(s.START_DATE,1),'MONTH')
                LEFT JOIN
                    HP.MASTERPRODUCTREGISTER sa_mpr
                ON
                    sa_mpr.id = sa.ADDON_PRODUCT_ID
                LEFT JOIN
                    HP.PRODUCTS sa_pr
                ON
                    sa_pr.GLOBALID = sa_mpr.GLOBALID
                    AND sa_pr.center = sa.CENTER_ID
                )) biview
