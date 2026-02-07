WITH
    elig_subs AS
    (
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
                AND sc.employee_id = 7403) t1
        WHERE
            rnk = 1
    )
SELECT 
    p.center || 'p' || p.id                                        AS PERSONID,
    c.id                                                           AS CheckinCenterId,
    c.name                                                         AS CheckinCenter,
    TO_CHAR(longToDateC(cil.checkin_time, cil.checkin_center),'yyyy-MM-dd HH24:MI:SS')  AS CheckinTime,
    TO_CHAR(longToDateC(cil.checkout_time, cil.checkin_center),'yyyy-MM-dd HH24:MI:SS') AS CheckOutTime
FROM
    PERSONS p   
    join elig_subs es on es.owner_center = p.center and es.owner_id = p.id
JOIN
    CHECKINS cil
ON
    cil.PERSON_CENTER = p.center
    AND cil.PERSON_ID = p.id
JOIN
    centers c
ON
    c.id = cil.checkin_center