WITH params AS (
    SELECT
        /*+ materialize */
        TRUNC(CAST($$DeductionDate$$ AS DATE)) AS deductionDate,
        TRUNC(CAST($$DeductionDate$$ AS DATE)) - 7 AS deductionDateOneWeekBack,
        TRUNC(CAST($$DeductionDate$$ AS DATE))
            - TRUNC(CAST($$DeductionDate$$ AS DATE), 'IW') AS deductionDateWeekDay
),
-- Old / existing subscriptions
base_subs AS (
    SELECT s.*
    FROM subscriptions s
    CROSS JOIN params p
    WHERE s.state = 2
      AND s.subscription_price > 0
      AND s.start_date < p.deductionDateOneWeekBack
      AND (s.end_date >= p.deductionDate OR s.end_date IS NULL)
),

-- New subscriptions (week-based logic isolated)
new_subs AS (
    SELECT s.*
    FROM subscriptions s
    CROSS JOIN params p
    WHERE s.state = 2
      AND s.subscription_price > 0
      AND p.deductionDateWeekDay < 5
      AND s.start_date BETWEEN p.deductionDateOneWeekBack
          AND (p.deductionDateOneWeekBack + CASE p.deductionDateWeekDay WHEN 4 THEN 2 ELSE 0 END)
),

-- AR filtered early
ar_type4 AS (
    SELECT *
    FROM account_receivables
    WHERE ar_type = 4
)
SELECT
    CASE
        WHEN p.center IS NULL THEN 'total'
        ELSE p.center || 'p' || p.id
    END AS MemberID,
    CASE
        WHEN new_s.center IS NOT NULL
             AND new_ar.balance < 0
        THEN 'New_Member'
        WHEN s.center IS NOT NULL
        THEN 'Old_Member'
    END AS "Old / New",
    SUM(
        CASE
            WHEN new_s.center IS NOT NULL
                 AND new_ar.balance < 0
            THEN new_ar.balance * -1
            WHEN s.center IS NOT NULL
            THEN s.subscription_price
        END
    ) AS collecting
FROM persons p
CROSS JOIN params
LEFT JOIN base_subs s               -- 170p15346
    ON s.owner_center = p.center
   AND s.owner_id = p.id
LEFT JOIN subscriptiontypes st
    ON st.center = s.subscriptiontype_center
   AND st.id = s.subscriptiontype_id
LEFT JOIN new_subs new_s
    ON new_s.owner_center = p.center
   AND new_s.owner_id = p.id            -- 9p8480
LEFT JOIN subscriptiontypes new_st
    ON new_st.center = new_s.subscriptiontype_center
   AND new_st.id = new_s.subscriptiontype_id
LEFT JOIN ar_type4 ar
    ON ar.customercenter = s.owner_center
   AND ar.customerid = s.owner_id
LEFT JOIN payment_accounts pac
    ON pac.center = ar.center
   AND pac.id = ar.id
LEFT JOIN payment_agreements pa
    ON pa.center = pac.active_agr_center
   AND pa.id = pac.active_agr_id
   AND pa.subid = pac.active_agr_subid
   AND pa.state = 4
LEFT JOIN ar_type4 new_ar
    ON new_ar.customercenter = new_s.owner_center
   AND new_ar.customerid = new_s.owner_id
WHERE
    (
        pa.individual_deduction_day = EXTRACT(DAY FROM params.deductionDate)
        OR new_s.center IS NOT NULL
    )
    AND (st.st_type = 1 OR new_st.st_type = 1)
GROUP BY
    GROUPING SETS (
        (
            p.center,
            p.id,
            new_s.center,
            new_s.start_date,
            new_ar.balance,
            s.center,
            new_st.st_type,
            st.st_type
        ),
        ()
    )
ORDER BY
    1 ASC;
