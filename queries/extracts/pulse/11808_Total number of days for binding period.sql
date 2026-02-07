 SELECT
    a.center || 'ss' || a.id AS SubscriptionId,
    a.total_days
 FROM
     (
         SELECT
             t1.center,
             t1.id,
             CAST( SUM(t1.days) AS INTEGER) AS total_days
         FROM
             (
                 SELECT
                     s.center,
                     s.id,
                     srp.end_date - srp.start_date + 1 AS days
                 FROM
                     subscriptions s
                 JOIN
                     subscriptiontypes st
                 ON
                     s.subscriptiontype_center = st.center
                     AND s.subscriptiontype_id = st.id
                     /* EFT Subscriptions */
                     AND st.st_type = 1
                 JOIN
                     subscription_reduced_period srp
                 ON
                     s.center = srp.subscription_center
                     AND s.id = srp.subscription_id
                 WHERE
                     s.center IN (:scope)
                     AND s.binding_end_date > to_date('21-03-2020', 'dd-MM-yyyy')
                     AND s.end_date IS NULL
                     AND srp.type IN ('FREE_ASSIGNMENT')
                     AND srp.state = 'ACTIVE'
                     AND srp.employee_center = 100
                     AND srp.employee_id IN (6605,4205) ) t1
         GROUP BY
             t1.center,
             t1.id ) a
 JOIN
     subscriptions s
 ON
     s.center = a.center
     AND s.id = a.id
 WHERE
    s.binding_end_date + a.total_days >= CURRENT_DATE
 ORDER BY
     a.total_days
