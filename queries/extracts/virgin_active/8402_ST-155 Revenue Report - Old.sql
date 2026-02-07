SELECT
    svw.SALES_TYPE,
    NVL(c.NAME,c2.name) center_name,
    svw.PRODUCT_NAME,
    pg.NAME                                                                                                                                                                                                        product_group_name,
    DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription', 13, 'Subscription add-on') PT_TYPE,
    TO_CHAR( SUM(svw.TOTAL_AMOUNT ), 'FM999999999999,9990.09' )                                                                                                                                                                         Year_to_date_Revenue,
    TO_CHAR( SUM(svw.NET_AMOUNT), 'FM999999999999,9990.09' )                                                                                                                                                                            Year_to_date_Revenue_excl_vat,
    SUM(svw.QUANTITY)                                                                                                                                                                                                        year_to_date_count,
    TO_CHAR(SUM(
        CASE
            WHEN svw.TRANS_TIME BETWEEN exerpro.dateToLong(TO_CHAR(TRUNC($$endDate$$,'MM'), 'YYYY-MM-dd HH24:MI')) AND exerpro.dateToLong(TO_CHAR($$endDate$$, 'YYYY-MM-dd HH24:MI')) + (1000*60*60*24) - 1
            THEN svw.TOTAL_AMOUNT
            ELSE 0
        END), 'FM999999999999,9990.09' ) Month_to_date_Revenue,
    TO_CHAR(SUM(
        CASE
            WHEN svw.TRANS_TIME BETWEEN exerpro.dateToLong(TO_CHAR(TRUNC($$endDate$$,'MM'), 'YYYY-MM-dd HH24:MI')) AND exerpro.dateToLong(TO_CHAR($$endDate$$, 'YYYY-MM-dd HH24:MI')) + (1000*60*60*24) - 1
            THEN svw.NET_AMOUNT
            ELSE 0
        END), 'FM999999999999,9990.09' ) Month_to_date_Revenue_excl_vat,
    SUM(
        CASE
            WHEN svw.TRANS_TIME BETWEEN exerpro.dateToLong(TO_CHAR(TRUNC($$endDate$$,'MM'), 'YYYY-MM-dd HH24:MI')) AND exerpro.dateToLong(TO_CHAR($$endDate$$, 'YYYY-MM-dd HH24:MI')) + (1000*60*60*24) - 1
            THEN 1 * svw.QUANTITY
            ELSE 0
        END) month_to_date_count
FROM
    VA.SALES_VW svw
JOIN
    PRODUCTS prod
ON
    prod.CENTER = svw.PRODUCT_CENTER
    AND prod.ID = svw.PRODUCT_ID
JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
    AND (
        pg.id = 271
        OR pg.PARENT_PRODUCT_GROUP_ID = 271)
LEFT JOIN
    VA.CENTERS c
ON
    c.id = svw.CENTER
    AND svw.REBOOKING_TO_CENTER IS NULL
LEFT JOIN
    VA.CENTERS c2
ON
    c2.id = svw.REBOOKING_TO_CENTER
    AND svw.REBOOKING_TO_CENTER IS NOT NULL
WHERE
    svw.TRANS_TIME BETWEEN exerpro.dateToLong(TO_CHAR(TRUNC($$endDate$$,'YYYY'),'YYYY-MM-dd HH24:MI')) AND exerpro.dateToLong(TO_CHAR($$endDate$$, 'YYYY-MM-dd HH24:MI')) + (1000*60*60*24) - 1
    AND svw.PRODUCT_TYPE IN ('CLIPCARD',
                             'SUBS_PERIOD',
                             'SUBS_PRORATA',
                             'ADDON')
    AND ((
            svw.center IN ($$scope$$)
            AND svw.REBOOKING_TO_CENTER IS NULL)
        OR (
            svw.REBOOKING_TO_CENTER IN ($$scope$$)))
GROUP BY
    svw.SALES_TYPE,
    NVL(c.NAME,c2.name),
    svw.PRODUCT_NAME ,
    pg.NAME ,
    DECODE(prod.PTYPE, 1, 'Retail', 2, 'Service', 4, 'Clipcard', 5, 'Subscription creation', 6, 'Transfer', 7, 'Freeze period', 8, 'Gift card', 9, 'Free gift card', 10, 'Subscription', 12, 'Subscription', 13, 'Subscription add-on')