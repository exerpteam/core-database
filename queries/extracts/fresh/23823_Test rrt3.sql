-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
            old_subscription_center AS center ,
            old_subscription_id     AS id,
            owner_center ,
            owner_id,
            last_end_date
        FROM
            (
                SELECT
                    sc.*,
                    lsc.effect_date AS last_end_date,
                    s.owner_center,
                    s.owner_id,
                    row_number() over (partition BY s.center,s.id ORDER BY lsc.change_time DESC) AS
                    rnk
                FROM
                    subscriptions s
                JOIN
                    subscription_change sc
                ON
                    sc.old_subscription_center = s.center
                AND sc.old_subscription_id = s.id
                JOIN
                    subscriptiontypes st
                ON
                    st.center=s.subscriptiontype_center
                AND st.id = s.subscriptiontype_id
                LEFT JOIN
                    subscription_change lsc
                ON
                    lsc.old_subscription_center = s.center
                AND lsc.old_subscription_id = s.id
                AND lsc.change_time < sc.change_time
                AND ( lsc.cancel_time IS NULL
                    OR  lsc.cancel_time > 1680307200000) -- april 1st
                WHERE
                    sc.change_time BETWEEN 1680307200000 AND 1682899200000 --april 1st until may 1st
                AND sc.type = 'END_DATE'
                AND sc.effect_date = '2023-04-30'
                AND sc.cancel_time IS NULL
                AND s.center = 207
                AND sc.employee_center = 200
                AND sc.employee_id = 7403
)fo