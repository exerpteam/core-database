-- The extract is extracted from Exerp on 2026-02-08
-- Includes IBAN

SELECT
    payer.center                                                                                                                                AS Center,
    MAX(salut.txtvalue)                                                                                                                         AS Title,
    MAX(payer.lastname)                                                                                                                         AS Lastname,
    MAX(payer.FIRSTNAME)                                                                                                                        AS Firstname,
    MAX(email.txtvalue)                                                                                                                         AS Email,
    MAX(payer.address1)                                                                                                                         AS Adresse1,
    MAX(payer.address2)                                                                                                                         AS Adresse2,
    MAX(payer.ZIPCODE)                                                                                                                          AS PostCode,
    MAX(payer.CITY)                                                                                                                             AS City,
    MAX(payer.COUNTRY)                                                                                                                          AS Country,
    MAX(pa.IBAN)                                                                                                                                AS IBAN,
    MAX(pa.BIC)                                                                                                                                 AS BIC,
    TRANSLATE(TO_CHAR(SUM(sp.price) / (greatest(COALESCE(COUNT(DISTINCT aopd.ID), 0), 1)), '999.00'), '.', ',')                                 AS SubscriptionsPrice,
    TRANSLATE(TO_CHAR(SUM(aopd.PRICE), '999.00'), '.', ',')                                                                                     AS SubscriptionsAddOnPrice,
    TRANSLATE(TO_CHAR(SUM(sp.price) / (greatest(COALESCE(COUNT(DISTINCT aopd.ID), 0), 1)) + COALESCE(SUM(aopd.PRICE), 0) , '999.00'), '.', ',') AS TotalPrice,
    MAX(pa.ref)                                                                                                                                 AS SEPAMandateId,
    TO_CHAR(longtodate(MAX(pa.CREATION_TIME)), 'YYYY-MM-DD')                                                                                    AS SEPACreationDate,
    MAX(memno.txtvalue)                                                                                                                         AS OldMemNo,
    MAX(
        CASE
            WHEN pa.ref = memno.txtvalue
            THEN 'TRUE'
            ELSE 'FALSE'
        END)                    AS TransferredMandate,
    mem.center || 'p' || mem.id AS MemberId,
    --    mem.lastname as MemberLastname,
    --    mem.FIRSTNAME as MemberFirstname,
    payer.center || 'p' || payer.id AS PayerId
    /*    ,case when rel.center is not null then 'TRUE' else 'FALSE' end as OtherPayer
    ,
    sub.start_date as XX_START_DATE,
    sub.BILLED_UNTIL_DATE XX_BILLED_UNTIL_DATE,
    to_char((COALESCE(sub.BILLED_UNTIL_DATE, sub.start_date-1)+1), 'MON YYYY') as XX_NextDeduction,
    sub.end_date XX_END_DATE
    */
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
            OR sp.from_date = sub.START_DATE)
        AND (
            sp.TO_DATE IS NULL
            OR sub.BILLED_UNTIL_DATE IS NULL
            OR sp.to_date > sub.BILLED_UNTIL_DATE))
LEFT JOIN
    SUBSCRIPTION_ADDON sub_add_on
ON
    sub_add_on.SUBSCRIPTION_CENTER = sub.CENTER
    AND sub_add_on.SUBSCRIPTION_ID = sub.id
    AND sub_add_on.CANCELLED = 0
    AND sub_add_on.START_DATE <= (COALESCE(sub.BILLED_UNTIL_DATE, sub.START_DATE - 1) + 1)
    AND (
        sub_add_on.END_DATE IS NULL
        OR sub_add_on.END_DATE > (COALESCE(sub.BILLED_UNTIL_DATE, sub.START_DATE - 1) + 1))
LEFT JOIN
    MASTERPRODUCTREGISTER mp
ON
    sub_add_on.ADDON_PRODUCT_ID = mp.ID
LEFT JOIN
    PRODUCTS aopd
ON
    aopd.center = sub.center
    AND aopd.GLOBALID = mp.GLOBALID
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
        OR (
            rel.center IS NULL
            AND payer.center = mem.center
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
JOIN
    CLEARINGHOUSES ch
ON
    pa.CLEARINGHOUSE = ch.ID
LEFT JOIN
    PERSON_EXT_ATTRS salut
ON
    salut.PERSONCENTER = payer.center
    AND salut.personid = payer.id
    AND salut.name = '_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS memno
ON
    memno.PERSONCENTER = payer.center
    AND memno.personid = payer.id
    AND memno.name = '_eClub_OldSystemPersonId'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = payer.center
    AND email.personid = payer.id
    AND email.name = '_eClub_Email'
WHERE
    st.ST_TYPE = 1
    AND sub.state IN (2,4,8)
    --and ch.CTYPE in (145, 150)
    AND pa.state = 4
    AND sub.center in ($$scope$$)
    --and pa.ref like '++%'
    --and payer.center = 102
    AND (
        sub.end_date IS NULL
        OR sub.BILLED_UNTIL_DATE IS NULL
        OR sub.BILLED_UNTIL_DATE < sub.END_DATE)
GROUP BY
    payer.center,
    payer.id,
    mem.center,
    mem.id,
    rel.center
ORDER BY
    payer.center,
    payer.id