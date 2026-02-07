WITH
    params AS
    (
        SELECT
            /*+ materialize */
            CAST(DATE_TRUNC('day', CAST($$DeductionDate$$ AS TIMESTAMP)) AS DATE)                                                   AS deductionDate,
            CAST(DATE_TRUNC('day', CAST((CAST($$DeductionDate$$ AS DATE) - 7) AS TIMESTAMP)) AS DATE)                                             AS deductionDateOneWeekBack,
            CAST(DATE_PART('day', DATE_TRUNC('day', CAST($$DeductionDate$$ AS TIMESTAMP)) - DATE_TRUNC('week', CAST($$DeductionDate$$ AS DATE))) AS INT) AS deductionDateWeekDay
    )
SELECT
    CASE
        WHEN p.center IS NULL
        THEN 'total'
        ELSE p.center||'p'||p.id
    END AS MemberID,
    CASE
        WHEN new_s.CENTER IS NOT NULL
            AND new_ar.BALANCE<0
        THEN 'New_Member'
        WHEN s.CENTER IS NOT NULL
        THEN 'Old_Member'
    END AS "Old / New",
    SUM(
        CASE
            WHEN new_s.CENTER IS NOT NULL
                AND new_ar.BALANCE<0
            THEN new_ar.BALANCE*-1
            WHEN s.CENTER IS NOT NULL
            THEN s.SUBSCRIPTION_PRICE
        END) AS collecting,
    ch.name  AS clearinghouseName
FROM
    PERSONS p
CROSS JOIN
    params
LEFT JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND p.id= s.OWNER_ID
    AND (
        s.END_DATE >= params.deductionDate
        OR s.END_DATE IS NULL)
    AND s.START_DATE < params.deductionDateOneWeekBack
    AND s.STATE IN (2)
    AND s.SUBSCRIPTION_PRICE>0
LEFT JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
LEFT JOIN
    SUBSCRIPTIONS new_s
ON
    new_s.OWNER_CENTER = p.CENTER
    AND p.id= new_s.OWNER_ID
    AND new_s.START_DATE BETWEEN params.deductionDateOneWeekBack AND (
        params.deductionDateOneWeekBack + (
            CASE
                WHEN params.deductionDateWeekDay = 4
                THEN 2
                ELSE 0
            END)) -- include Sat and Sun for Friday deduction
    AND new_s.STATE IN (2)
    AND params.deductionDateWeekDay < 5 -- Exclude new membership sale for SAT and SUN deduction day. These will be collected before following Monday
    AND new_s.SUBSCRIPTION_PRICE > 0
LEFT JOIN
    subscriptiontypes new_st
ON
    new_st.center = new_s.subscriptiontype_center
    AND new_st.id = new_s.subscriptiontype_id
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
    AND ar.AR_TYPE = 4
LEFT JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
LEFT JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.ID = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
--    AND pa.state = 4
LEFT JOIN
    CLEARINGHOUSES ch
ON
    ch.id = pa.CLEARINGHOUSE
LEFT JOIN
    ACCOUNT_RECEIVABLES new_ar
ON
    new_ar.CUSTOMERCENTER = new_s.OWNER_CENTER
    AND new_ar.CUSTOMERID = new_s.OWNER_ID
    AND new_ar.AR_TYPE = 4
WHERE
    (
        pa.INDIVIDUAL_DEDUCTION_DAY = CAST(EXTRACT(DAY FROM params.deductionDate) AS INT)
        OR new_s.center IS NOT NULL)
    AND (
        st.st_type = 1
        OR new_st.st_type = 1)
    AND ( (
            'ALL' = $$ClearinghouseName$$)
        OR (
            ch.name = $$ClearinghouseName$$) )
GROUP BY
    grouping sets ( (p.center, p.id, new_s.CENTER, new_s.START_DATE, new_ar.BALANCE, s.CENTER, new_st.st_type, st.st_type, ch.name ), () )
ORDER BY
    1 ASC