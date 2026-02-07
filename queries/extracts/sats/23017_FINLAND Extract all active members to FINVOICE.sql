SELECT
    payer.center || 'p' || payer.id                                      AS PayerId,
    payer.FIRSTNAME                                               AS FirstNamePayer,
    payer.lastname                                                 AS LastNamePayer,
	payer.co_name													AS CONamePayer,
    payer.address1                                                      AS Adresse1,
    payer.address2                                                      AS Adresse2,
    payer.ZIPCODE                                                       AS PostCode,
    payer.CITY                                                            AS City,
    pd.name                                                     AS SubscriptionName,
    TRANSLATE(TO_CHAR(sp.price, '99.00'), '.', ',')                       AS SubscriptionPrice,
    pa.ref                                                                AS AgreementRef,
    pa.BANK_REGNO                                                         AS BankRegistrationNumber,
    pa.BANK_ACCNO                                                         AS BankAccountNumber,
    mem.center || 'p' || mem.id                                           AS MemberId,
    mem.FIRSTNAME                                                         AS MemberFirstName,
    mem.lastname                                                          AS MemberLastName,
    sub.start_date                                                        AS XX_START_DATE,
    sub.BILLED_UNTIL_DATE                                                    XX_BILLED_UNTIL_DATE,
    TO_CHAR((NVL(sub.BILLED_UNTIL_DATE, sub.start_date-1)+1), 'MON YYYY') AS XX_NextDeduction,
    sub.end_date                                                             XX_END_DATE
FROM
    SUBSCRIPTIONS sub
JOIN
    SUBSCRIPTIONTYPES st
ON
    sub.SUBSCRIPTIONTYPE_CENTER = st.CENTER
AND sub.SUBSCRIPTIONTYPE_ID = st.id
JOIN
    PRODUCTS pd
ON
    pd.center = st.center
AND pd.id = st.id
JOIN
    SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = sub.center
AND sp.SUBSCRIPTION_ID = sub.id
AND ((
            sp.from_date <= (sub.BILLED_UNTIL_DATE+1)
        OR  sp.from_date = sub.START_DATE)
    AND (
            sp.TO_DATE IS NULL
        OR  sub.BILLED_UNTIL_DATE IS NULL
        OR  sp.to_date > sub.BILLED_UNTIL_DATE))
JOIN
    PERSONS mem
ON
    mem.center = sub.OWNER_CENTER
AND mem.id = sub.OWNER_ID
LEFT JOIN
    RELATIVES rel
ON
    rel.relativeCENTER = mem.center
AND rel.relativeid = mem.id
AND rel.RTYPE = 12
AND rel.STATUS < 3
JOIN
    PERSONS payer
ON
    ((
            rel.center IS NOT NULL
        AND payer.center = rel.center
        AND payer.id = rel.id)
    OR  (
            payer.center = mem.center
        AND payer.id = mem.id))
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    payer.center = ar.CUSTOMERCENTER
AND payer.id = ar.CUSTOMERID
AND ar.AR_TYPE = 4
JOIN
    PAYMENT_ACCOUNTS pac
ON
    ar.center = pac.center
AND ar.id = pac.id
JOIN
    PAYMENT_AGREEMENTS pa
ON
    pac.ACTIVE_AGR_CENTER = pa.center
AND pac.ACTIVE_AGR_ID = pa.id
AND pac.ACTIVE_AGR_SUBID = pa.subid
WHERE
    st.ST_TYPE = 1
AND sub.state IN (2,4,8)
AND pa.CLEARINGHOUSE = 8
AND payer.center >= 700
AND (
        sub.end_date IS NULL
    OR  sub.BILLED_UNTIL_DATE IS NULL
    OR  sub.BILLED_UNTIL_DATE < sub.END_DATE)
ORDER BY
    payer.id