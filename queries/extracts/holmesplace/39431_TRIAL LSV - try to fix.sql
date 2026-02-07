

WITH
    recursive v_periods AS
    (
        SELECT
            1                                                                      AS LEVEL,
            first_day                                                                 first_date,
            date_trunc('month', first_day + interval '1 month') - interval '1 day'    last_date,
            extract('day' FROM date_trunc('month', first_day + interval '1 month') - interval
            '1 day' - first_day + interval '1 day') days_in_month
        FROM
            (
                SELECT
                    /* The starting point of the months rows */
                    DATE_TRUNC('month', CURRENT_DATE - interval '9 month') first_day ) x
        UNION ALL
        /* how many month from the starting point */
        SELECT
            v.LEVEL +1,
            first_day + interval '1 month' * v.level first_date,
            date_trunc('month', first_day + interval '1 month' * (v.level +1)) - interval '1 day'
            last_date,
            extract('day' FROM (date_trunc('month', first_day + interval '1 month' * (v.level +1))
            - interval '1 day') - (first_day + interval '1 month' * v.level) + interval '1 day')
            days_in_month
        FROM
            (
                SELECT
                    /* The starting point of the months rows */
                    DATE_TRUNC('month', CURRENT_DATE - interval '9 month') first_day ) x
        JOIN
            v_periods v
        ON
            v.level <=30
    )
SELECT
    rev.OWNER_CENTER AS CenterId,
    /*   rev.OWNER_ID, */
    rev.OWNER_CENTER || 'p' || rev.OWNER_ID AS memberId,
    /*   rev.SID,
    rev.SUB_CENTER,
    rev.SUB_ID, */
    prod.NAME AS Subscription,
    ch.NAME      CLEARING_HOUSE,
    CASE pa.STATE
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement (deprecated)'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
    END AS PA_STATUS,
    CASE
        WHEN rel.CENTER IS NOT NULL
        THEN 1
        ELSE 0
    END                        AS OTHER_PAYER,
    rev.full_value_of_contract AS Revenueuntildate
FROM
    (
        SELECT
            calPrice.OWNER_CENTER,
            calPrice.OWNER_ID,
            calPrice.center || 'ss' || calPrice.id                      sid,
            calPrice.center                                             SUB_CENTER,
            calPrice.id                                                 SUB_ID,
            SUM(price_for_period) - SUM( COALESCE(freeze_days_price,0)) full_value_of_contract
        FROM
            (
                SELECT
                    first_date,
                    last_date,
                    greatest(first_date,test.from_date) price_from,
                    least(last_date,COALESCE(test.to_date,TO_DATE('2035-01-01','yyyy-MM-dd')))
                                   price_to ,
                    srp.start_date freeze_start ,
                    srp.end_date   freeze_end,
                    ROUND(CAST(( DATE_PART('day',
                    CASE
                        WHEN srp.end_date > least(last_date,COALESCE(test.to_date,TO_DATE
                            ('2035-01-01' ,'yyyy-MM-dd')))
                        THEN least(last_date,COALESCE(test.to_date,TO_DATE('2035-01-01',
                            'yyyy-MM-dd')) ) + interval '1 day'
                        ELSE srp.end_date + interval '1 day'
                    END -
                    CASE
                        WHEN srp.start_date < greatest(first_date,test.from_date)
                        THEN greatest(first_date,test.from_date)
                        ELSE srp.start_date
                    END )) * (PRICE / days_in_month) AS NUMERIC),2) AS freeze_days_price,
                    ROUND(CAST(DATE_PART('day',(PRICE/days_in_month) * (least(last_date,COALESCE
                    (test.to_date,TO_DATE ('2035-01-01','yyyy-MM-dd'))) - greatest(first_date,
                    test.from_date)+interval '1 day' )) AS NUMERIC),2) price_for_period,
                    days_in_month                                      PRICE ,
                    test.center,
                    test.id,
                    test.OWNER_CENTER,
                    test.OWNER_ID
                FROM
                    v_periods
                    /* so lets join the price changes to the generated periods */
                LEFT JOIN
                    (
                        SELECT
                            sp.PRICE,
                            CASE
                                WHEN (
                                        SELECT
                                            MIN(sp2.FROM_DATE)
                                        FROM
                                            HP.SUBSCRIPTION_PRICE sp2
                                        WHERE
                                            sp2.SUBSCRIPTION_CENTER = sp.SUBSCRIPTION_CENTER
                                        AND sp2.SUBSCRIPTION_ID = sp.SUBSCRIPTION_ID
                                            --AND sp2.BINDING = 1
AND sp2.CANCELLED = 0
                                        AND sp2.FROM_DATE < least(COALESCE(s.END_DATE,:endDate),
                                            :endDate )
                                        AND ( sp2.TO_DATE > s.BILLED_UNTIL_DATE
                                            OR  sp2.TO_DATE IS NULL )
                                        AND sp2.CANCELLED = 0
                                        AND ( sp2.TO_DATE > s.BILLED_UNTIL_DATE
                                            OR  sp2.TO_DATE IS NULL ) ) = sp.FROM_DATE
                                    --THEN s.BILLED_UNTIL_DATE + 1
                                THEN COALESCE(s.BILLED_UNTIL_DATE+1,sp.FROM_DATE)
                                ELSE sp.FROM_DATE
                            END AS FROM_DATE,
                            CASE
                                WHEN (
                                        SELECT
                                            MAX(sp2.FROM_DATE)
                                        FROM
                                            HP.SUBSCRIPTION_PRICE sp2
                                        WHERE
                                            sp2.SUBSCRIPTION_CENTER = sp.SUBSCRIPTION_CENTER
                                        AND sp2.SUBSCRIPTION_ID = sp.SUBSCRIPTION_ID
                                            --AND sp2.BINDING = 1
AND sp2.CANCELLED = 0
                                        AND sp2.FROM_DATE < least(COALESCE(s.END_DATE,:endDate),
                                            :endDate )
                                        AND ( sp2.TO_DATE > s.BILLED_UNTIL_DATE
                                            OR  sp2.TO_DATE IS NULL )
                                        AND sp2.CANCELLED = 0
                                        AND ( sp2.TO_DATE > s.BILLED_UNTIL_DATE
                                            OR  sp2.TO_DATE IS NULL ) ) = sp.FROM_DATE
                                THEN least(COALESCE(s.END_DATE,:endDate),:endDate)
                                ELSE sp.TO_DATE
                            END            AS TO_DATE,
                            sp.FROM_DATE      org_from_date,
                            sp.TO_DATE        org_to_date,
                            'PRICE_CHANGE' AS "type",
                            s.CENTER,
                            s.ID,
                            s.OWNER_CENTER,
                            s.OWNER_ID
                        FROM
                            HP.SUBSCRIPTIONS s
                        LEFT JOIN
                            HP.SUBSCRIPTION_PRICE sp
                        ON
                            sp.SUBSCRIPTION_CENTER = s.CENTER
                        AND sp.SUBSCRIPTION_ID = s.ID
                        AND sp.CANCELLED = 0
                            --AND sp.BINDING = true
                        AND sp.FROM_DATE < least(COALESCE(s.END_DATE,:endDate),:endDate)
                        AND (
                                sp.TO_DATE > s.BILLED_UNTIL_DATE
                            OR  sp.TO_DATE IS NULL )
                        AND (
                                sp.TO_DATE > s.BILLED_UNTIL_DATE
                            OR  sp.TO_DATE IS NULL )
                        WHERE
                            (
                                s.CENTER,s.ID ) IN
                            (
                                SELECT
                                    s.CENTER,
                                    s.ID
                                FROM
                                    HP.SUBSCRIPTIONS s
                                JOIN
                                    HP.SUBSCRIPTIONTYPES st
                                ON
                                    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                                AND st.id = s.SUBSCRIPTIONTYPE_ID
                                AND st.ST_TYPE IN (1,2)
                                WHERE
                                    s.STATE IN (2,4,8)
                                AND s.center IN (:scope)
                                    --AND s.OWNER_ID = 39958
                                    --and s.OWNER_ID = 4444
                                    --and s.ID = 8446
                            ) ) test
                    /* Any price change that intersects the generated month should be joined */
                ON
                    (
                        test.from_date <= last_date
                    AND test.to_date IS NULL )
                OR  (
                        test.from_date < last_date
                    AND test.to_date > first_date )
                    /* Join freezes and free periods*/
                LEFT JOIN
                    HP.SUBSCRIPTION_REDUCED_PERIOD srp
                ON
                    srp.SUBSCRIPTION_CENTER = test.CENTER
                AND srp.SUBSCRIPTION_ID = test.ID
				AND srp.STATE != 'CANCELLED'
                    /* Anythinh that intercepts */
                AND ( (
                            srp.START_DATE <= least(last_date,COALESCE(test.to_date,TO_DATE
                            ('2035-01-01' , 'yyyy-MM-dd')))
                        AND srp.END_DATE > greatest(first_date,test.from_date) )
                    OR  (
                            srp.START_DATE >= greatest(first_date,test.from_date)
                        AND srp.END_DATE > greatest(first_date,test.from_date)
                        AND srp.START_DATE <= least(last_date,COALESCE(test.to_date,TO_DATE
                            ('2035-01-01' ,'yyyy-MM-dd'))) ) ) ) calPrice
        GROUP BY
            calPrice.OWNER_CENTER,
            calPrice.OWNER_ID,
            calPrice.center,
            calPrice.id ) rev
JOIN
    HP.SUBSCRIPTIONS s
ON
    s.CENTER = rev.SUB_CENTER
AND s.ID = rev.SUB_ID
JOIN
    HP.PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
AND prod.ID = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    HP.RELATIVES rel
ON
    rel.RTYPE = 12
AND rel.RELATIVECENTER = rev.OWNER_CENTER
AND rel.RELATIVEID = rev.OWNER_ID
AND rel.STATUS = 1
LEFT JOIN
    HP.ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = COALESCE(rel.CENTER, rev.OWNER_CENTER)
AND ar.CUSTOMERID = COALESCE(rel.ID,rev.OWNER_ID)
AND ar.AR_TYPE = 4
LEFT JOIN
    HP.PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
AND pac.ID = ar.ID
LEFT JOIN
    HP.PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
AND pa.ID = pac.ACTIVE_AGR_ID
AND pa.SUBID = pac.ACTIVE_AGR_SUBID
LEFT JOIN
    HP.CLEARINGHOUSES ch
ON
    ch.ID = pa.CLEARINGHOUSE 
