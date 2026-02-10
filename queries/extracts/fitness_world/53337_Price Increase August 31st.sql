-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t3.*,
        t3.SPP_AUGUST_PRICE,
        ROUND(t3.INVOICED_PRICE - t3.SPP_AUGUST_PRICE,2) AS DIFF
FROM
(
        SELECT
                t2.*,
                t2.TEMP_PRICE + t2.SPP_PU_DAILY_PRICE AS INVOICED_PRICE
        FROM
                (
                SELECT
                        t1.*,
                        round((t1.SPP_AUGUST_DAILY_PRICE)*30,2) AS TEMP_PRICE
                FROM
                (
                        SELECT
                                s.OWNER_CENTER || 'p' || s.OWNER_ID AS PersonId, 
                                s.CENTER || 'ss' || s.ID AS SubscriptionId,
                                s.BILLED_UNTIL_DATE,
                                s.END_DATE,
                                sp.FROM_DATE AS PriceUpdate_FromDate,
                                sp.TO_DATE AS PriceUpdate_ToDate,
                                sp.PRICE AS PriceUpdate_Price,
                                sp.BINDING AS PriceUpdate_Binding,
                                sp.APPLIED AS PriceUpdate_Applied,
                                spp.FROM_DATE AS SPP_PU_FROM_DATE,
                                spp.TO_DATE AS SPP_PU_TO_DATE,
                                spp.SUBSCRIPTION_PRICE AS SPP_PU_PRICE,
                                spp.SUBSCRIPTION_PRICE / 31 AS SPP_PU_DAILY_PRICE,
                                ROUND(spp.SUBSCRIPTION_PRICE / 31,2) AS SPP_PU_DAILY_PRICE_ROUNDED,
                                spp2.FROM_DATE AS SPP_AUGUST_FROM_DATE,
                                spp2.TO_DATE AS SPP_AUGUST_TO_DATE,
                                spp2.SUBSCRIPTION_PRICE AS SPP_AUGUST_PRICE,
                                spp2.SUBSCRIPTION_PRICE / 31 AS SPP_AUGUST_DAILY_PRICE,
                                ROUND(spp2.SUBSCRIPTION_PRICE / 31,2) AS SPP_AUGUST_DAILY_PRICE_ROUNDED
                        FROM FW.SUBSCRIPTIONS s
                        JOIN FW.SUBSCRIPTION_PRICE sp ON s.CENTER = sp.SUBSCRIPTION_CENTER AND s.ID = sp.SUBSCRIPTION_ID
                        LEFT JOIN FW.SUBSCRIPTIONPERIODPARTS spp ON spp.CENTER = s.CENTER AND spp.ID = s.ID AND spp.SPP_STATE = 1 AND spp.FROM_DATE = TO_DATE('2019-08-31','YYYY-MM-DD')
                        LEFT JOIN FW.SUBSCRIPTIONPERIODPARTS spp2 ON spp2.CENTER = s.CENTER AND spp2.ID = s.ID AND spp2.SPP_STATE = 1 AND spp2.TO_DATE = TO_DATE('2019-08-30','YYYY-MM-DD')
                        WHERE
                                s.OWNER_CENTER IN (269, 263, 268, 264, 271, 262, 266,270)
                                AND sp.FROM_DATE = TO_DATE('2019-08-31','YYYY-MM-DD')
                                AND sp.CANCELLED = 0
                                AND sp.TYPE = 'CONVERSION'
                                --AND s.OWNER_CENTER = 269 AND s.OWNER_ID = 2913
                ) t1
        ) t2
) t3