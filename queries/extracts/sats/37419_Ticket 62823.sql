SELECT
    p.CENTER || 'p' || p.ID as MemberID,
    p.PERSONTYPE,
    p.STATUS,
    p.FIRSTNAME,
    p.LASTNAME,
    p.ZIPCODE,
    p.ADDRESS1
FROM
    SATS.PERSONS p
JOIN
    SATS.ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.center
    AND ar.CUSTOMERID = p.id
    AND ar.AR_TYPE = 4
JOIN
    SATS.PAYMENT_ACCOUNTS pac
ON
    pac.center = ar.center
    AND ar.id = pac.id
JOIN
    SATS.PAYMENT_AGREEMENTS pa
ON
    pac.ACTIVE_AGR_CENTER = pa.center
    AND pac.ACTIVE_AGR_ID = pa.id
    AND pac.ACTIVE_AGR_SUBID = pa.SUBID
    AND p.center = 168
    AND pa.CLEARINGHOUSE =2