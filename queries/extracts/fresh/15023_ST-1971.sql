SELECT
    *
FROM
    (
        SELECT
            CASE
                WHEN sao.USE_INDIVIDUAL_PRICE = 1
                THEN 'INDIVIDUAL PRICE'
                WHEN i1.id IS NULL
                THEN 'IMPOSSIBLE TO COMPARE TO INVOICED PRICE'
                WHEN sao.USE_INDIVIDUAL_PRICE = 0
                    AND i1.TOTAL_AMOUNT != mpr2.CACHED_PRODUCTPRICE
                THEN 'PRICE INSECURE'
                ELSE 'LIST PRICE SAME AS LAST INVOICED PRICE'
            END                                                   AS price_comparison
          ,sao.ID                                                    addon_id
          ,sao.SUBSCRIPTION_CENTER || 'ss' || sao.SUBSCRIPTION_ID    ssid
          ,s.OWNER_CENTER || 'p' || s.OWNER_ID                       pid
          ,prod.NAME                                                 main_subscription
          ,mpr2.CACHED_PRODUCTNAME                                   addon_sub
            --  ,                                                    sao.USE_INDIVIDUAL_PRICE
          ,sao.INDIVIDUAL_PRICE_PER_UNIT
          ,mpr2.CACHED_PRODUCTPRICE LIST_PRICE
            --  ,                   i1.FROM_DATE
            --  ,                   i1.TO_DATE
          , i1.TOTAL_AMOUNT         INVOICED_AMOUNT
        FROM
            SUBSCRIPTION_ADDON sao
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sao.SUBSCRIPTION_CENTER
            AND s.ID = sao.SUBSCRIPTION_ID
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.id = s.SUBSCRIPTIONTYPE_ID
            AND st.ST_TYPE = 1
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        LEFT JOIN
            (
                SELECT
                    sa.ID
                  , spp.FROM_DATE
                  ,spp.TO_DATE
                  , invl.TOTAL_AMOUNT
                FROM
                    SUBSCRIPTION_ADDON sa
                JOIN
                    MASTERPRODUCTREGISTER mpr
                ON
                    mpr.ID = sa.ADDON_PRODUCT_ID
                JOIN
                    SUBSCRIPTIONPERIODPARTS spp
                ON
                    spp.CENTER = sa.SUBSCRIPTION_CENTER
                    AND spp.ID = sa.SUBSCRIPTION_ID
                    AND spp.SPP_TYPE = 1
                    AND spp.SPP_STATE = 1
                    AND TO_CHAR(spp.FROM_DATE,'DD') = 1
                    AND TO_CHAR(spp.TO_DATE,'DD') = TO_CHAR(last_day(spp.TO_DATE),'DD')
                JOIN
                    SPP_INVOICELINES_LINK link
                ON
                    link.PERIOD_CENTER = spp.CENTER
                    AND link.PERIOD_ID = spp.ID
                    AND link.PERIOD_SUBID = spp.SUBID
                JOIN
                    INVOICELINES invl
                ON
                    invl.CENTER = link.INVOICELINE_CENTER
                    AND invl.ID = link.INVOICELINE_ID
                    AND invl.SUBID = link.INVOICELINE_SUBID
                JOIN
                    PRODUCTS prod
                ON
                    prod.CENTER = invl.PRODUCTCENTER
                    AND prod.id = invl.PRODUCTID
                    AND prod.GLOBALID IN ('EFT_GX_ADD_ON_1'
                                        ,'EFT_GX_ADD_ON'
                                        ,'EFT_GX_ADD_ON_70KR'
                                        ,'EFT_GX_ADD_ON_NEW'
                                        ,'EFT_GX_ADD_ON_TRONDHEIM'
                                        ,'EFT_GX_ADD_ON_2')
                WHERE
                    mpr.GLOBALID IN ('EFT_GX_ADD_ON_1'
                                   ,'EFT_GX_ADD_ON'
                                   ,'EFT_GX_ADD_ON_70KR'
                                   ,'EFT_GX_ADD_ON_NEW'
                                   ,'EFT_GX_ADD_ON_TRONDHEIM'
                                   ,'EFT_GX_ADD_ON_2')
                    AND (
                        sa.END_DATE IS NULL
                        OR sa.END_DATE > exerpsysdate())
                    AND sa.CANCELLED = 0
                    AND spp.SUBID =
                    (
                        SELECT
                            MAX(spp2.SUBID)
                        FROM
                            SUBSCRIPTIONPERIODPARTS spp2
                        WHERE
                            spp2.CENTER = sa.SUBSCRIPTION_CENTER
                            AND spp2.id = sa.SUBSCRIPTION_ID
                            AND spp2.SPP_TYPE = 1
                            AND spp2.SPP_STATE = 1
                            AND TO_CHAR(spp2.FROM_DATE,'DD') = 1
                            AND TO_CHAR(spp2.TO_DATE,'DD') = TO_CHAR(last_day(spp2.TO_DATE),'DD') ) ) i1
        ON
            i1.id = sao.id
        JOIN
            MASTERPRODUCTREGISTER mpr2
        ON
            mpr2.ID = sao.ADDON_PRODUCT_ID
        WHERE

            (
                sao.END_DATE IS NULL
                OR sao.END_DATE > exerpsysdate())
            AND sao.CANCELLED = 0
            AND mpr2.GLOBALID IN ('EFT_GX_ADD_ON_1'
                                ,'EFT_GX_ADD_ON'
                                ,'EFT_GX_ADD_ON_70KR'
                                ,'EFT_GX_ADD_ON_NEW'
                                ,'EFT_GX_ADD_ON_TRONDHEIM'
                                ,'EFT_GX_ADD_ON_2') )
ORDER BY
    price_comparison