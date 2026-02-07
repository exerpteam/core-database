SELECT
    t.PersonId,
    t.RCCId,
    t.RCCStartDate,
    t.RCCEndDate,
t.RCCState,
t.RCCSubState,
t.RCCBilledUntil,
    t.RCCProductName,
    t.SubscriptionId,
    t.SubscriptionStartDate,
    t.SubscriptionStopDate,
    t.ProductName
FROM
    (
        SELECT
            rs.owner_center || 'p' || rs.owner_id                                          AS PersonId,
            rs.center || 'ss' || rs.id                                                     AS RCCId,
            rs.start_date                                                                  AS RCCStartDate,
            rs.end_date                                                                    AS RCCEndDate,
			rs.billed_until_date
AS RCCBilledUntil,
(
        CASE rs.state
            WHEN 2
            THEN 'ACTIVE'
            WHEN 3
            THEN 'ENDED'
            WHEN 4
            THEN 'FROZEN'
            WHEN 7
            THEN 'WINDOW'
            WHEN 8
            THEN 'CREATED'
            ELSE 'UNKNOWN'
        END) RCCState,
    (
        CASE rs.sub_state
            WHEN 1
            THEN 'NONE'
            WHEN 2
            THEN 'AWAITING_ACTIVATION'
            WHEN 3
            THEN 'UPGRADED'
            WHEN 4
            THEN 'DOWNGRADED'
            WHEN 5
            THEN 'EXTENDED'
            WHEN 6
            THEN 'TRANSFERRED'
            WHEN 7
            THEN 'REGRETTED'
            WHEN 8
            THEN 'CANCELLED'
            WHEN 9
            THEN 'BLOCKED'
            ELSE 'UNKNOWN'
        END)                                             AS RCCSubState,
			rsprod.name                                                                    AS RCCProductName,
            s.center || 'ss' || s.id                                                       AS SubscriptionId,
            s.start_date                                                                   AS SubscriptionStartDate,
            s.end_date                                                                     AS SubscriptionStopDate,
            prod.name                                                                      AS ProductName,
            rank() over (partition BY s.OWNER_CENTER, s.OWNER_ID ORDER BY s.end_date DESC) AS rnk
        FROM
            hp.subscriptions rs
        JOIN
            hp.subscriptiontypes rst
        ON
            rst.center = rs.subscriptiontype_center
            AND rst.id = rs.subscriptiontype_id
            AND rst.st_type = (2)
        JOIN
            hp.products rsprod
        ON
            rsprod.center = rst.center
            AND rsprod.id = rst.id
        LEFT JOIN
            hp.subscriptions s
        ON
            s.owner_center = rs.owner_center
            AND s.owner_id = rs.owner_id
            AND s.center || 'ss' || s.id != rs.center || 'ss' || rs.id
            AND s.state IN (2,4,7,8)
            AND COALESCE(rs.end_date, to_date('01-01-2900', 'dd-MM-yyyy')) >= COALESCE(s.end_date,to_date('01-01-2900', 'dd-MM-yyyy'))
        LEFT JOIN
            hp.subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
            AND st.id = s.subscriptiontype_id
            AND st.st_type IN (0,1)
        LEFT JOIN
            hp.products prod
        ON
            prod.center = st.center
            AND prod.id = st.id
        WHERE
            rs.owner_center IN ($$Scope$$)
            AND rs.state IN (2,4,7,8)
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    hp.subscriptions s,
                    hp.subscriptiontypes st
                WHERE
                    s.owner_center = rs.owner_center
                    AND s.owner_id = rs.owner_id
                    AND s.center || 'ss' || s.id != rs.center || 'ss' || rs.id
                    AND st.center = s.subscriptiontype_center
                    AND st.id = s.subscriptiontype_id
                    AND st.st_type IN (0,1)
                    AND s.state IN (2,4,7,8)
                    AND COALESCE(rs.end_date, to_date('01-01-2900', 'dd-MM-yyyy')) <= COALESCE(s.end_date,to_date('01-01-2900', 'dd-MM-yyyy'))) )t
WHERE
    t.rnk = 1