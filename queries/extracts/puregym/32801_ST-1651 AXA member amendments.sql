SELECT distinct 
    p.CENTER || 'p' || p.id  pid
  , s.CENTER || 'ss' || s.id ssid
  ,mpr.CACHED_PRODUCTNAME subscription_name
  , CASE
        WHEN ar.BALANCE != 0
        THEN 'Y'
        ELSE 'N'
    END has_balance
  , CASE
        WHEN pa.CENTER IS NOT NULL
        THEN 'Y'
        ELSE 'N'
    END has_active_agreement
  , CASE
        WHEN s2.CENTER IS NOT NULL
        THEN 'Y'
        ELSE 'N'
    END has_additional_sub
FROM
    SUBSCRIPTIONS s
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
    AND ar.AR_TYPE = 4
LEFT JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.id = ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.id = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
    AND pa.STATE = 4
LEFT JOIN
    SUBSCRIPTIONS s2
ON
    s2.OWNER_CENTER = p.CENTER
    AND s2.OWNER_ID = p.id
    AND s2.id != s.ID
    AND s2.END_DATE IS NULL
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.GLOBALID = prod.GLOBALID
WHERE
    mpr.CACHED_PRODUCTNAME LIKE '%AXA%'
    and s.center in ($$scope$$)
    and s.state in (2)