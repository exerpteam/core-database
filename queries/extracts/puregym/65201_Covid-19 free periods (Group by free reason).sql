 WITH LIST_CENTERS AS MATERIALIZED
 (
         SELECT
                 c.ID AS CENTERID
         FROM CENTERS c
         WHERE
                 CAST(c.ID AS VARCHAR) IN (:Scope)
 )
 SELECT
     srd.text AS "Free reason",
     COUNT(*) AS "Count"
 FROM
     persons p
 JOIN LIST_CENTERS lc ON p.CENTER = lc.CENTERID
 JOIN
     centers c
 ON
     c.id = p.center
 JOIN
     subscriptions s
 ON
     s.owner_center = p.center
     AND s.owner_id = p.id
 JOIN
     subscriptiontypes st
 ON
     st.center = s.subscriptiontype_center
     AND st.id = s.subscriptiontype_id
         AND st.st_type > 0 -- Except CASH
 JOIN
     products prod
 ON
     prod.center = st.center
     AND prod.id = st.id
 JOIN
     subscription_reduced_period srd
 ON
     srd.subscription_center = s.center
     AND srd.subscription_id = s.id
     AND srd.state = 'ACTIVE'
     AND srd.type = 'FREE_ASSIGNMENT'
     AND srd.end_date >= :OpeningDate
 WHERE
     p.persontype != 2  -- exclude staff
 GROUP BY
        srd.text
