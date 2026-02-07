SELECT
    decode(p.center,null,'total',p.center||'p'||p.id) AS MemberID,
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
        END) AS collecting
FROM
    PERSONS p
LEFT JOIN--170p15346
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND p.id= s.OWNER_ID
    AND (
        s.END_DATE >= TRUNC($$DeductionDate$$)
        OR s.END_DATE IS NULL)
    AND s.START_DATE < TRUNC($$DeductionDate$$ - 7)
    AND s.STATE IN (2)
    AND s.SUBSCRIPTION_PRICE>0
LEFT JOIN
    SUBSCRIPTIONS new_s
ON
    new_s.OWNER_CENTER = p.CENTER
    AND p.id= new_s.OWNER_ID --9p8480
    AND new_s.START_DATE = TRUNC($$DeductionDate$$ - 7)
    AND new_s.STATE IN (2)
    AND new_s.SUBSCRIPTION_PRICE > 0
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = s.OWNER_CENTER
    AND ar.CUSTOMERID = s.OWNER_ID
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
LEFT JOIN
    ACCOUNT_RECEIVABLES new_ar
ON
    new_ar.CUSTOMERCENTER = new_s.OWNER_CENTER
    AND new_ar.CUSTOMERID = new_s.OWNER_ID
    AND new_ar.AR_TYPE = 4
WHERE
    (
        pa.INDIVIDUAL_DEDUCTION_DAY = EXTRACT(DAY FROM $$DeductionDate$$ )
        OR new_s.center IS NOT NULL)
GROUP BY
    grouping sets ( (p.center, p.id, new_s.CENTER, new_s.START_DATE, new_ar.BALANCE, s.CENTER), () ) order by 1 asc