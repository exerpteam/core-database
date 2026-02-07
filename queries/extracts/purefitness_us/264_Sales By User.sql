SELECT
    c.SHORTNAME,
    emp.CENTER || 'emp' || emp.ID emp_id,
    pemp.FIRSTNAME                EMP_FIRSTNAME,
    pemp.LASTNAME                 EMP_LASTNAME,
    ss.SALES_DATE,
    ss.START_DATE,
    ss.PRICE_PERIOD,
    p.CENTER,
    p.ID,
    p.FULLNAME,
    CASE p.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS STATUS,
    CASE p.PERSONTYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL STAFF'
        ELSE 'UNKNOWN'
    END AS PERSONTYPE,
    p.FIRSTNAME,
    p.LASTNAME,
    p.SEX,
    p.BLACKLISTED,
    p.ADDRESS1,
    p.ADDRESS2,
    p.COUNTRY,
    p.ZIPCODE,
    p.BIRTHDATE,
    p.PINCODE,
    p.FRIENDS_ALLOWANCE,
    p.CITY,
    ph.txtvalue  AS phonehome,
    pm.txtvalue  AS phonemobile,
    pem.txtvalue AS email,
    p.MIDDLENAME,
    ch.name AS clearinghouseName
FROM
    subscription_sales ss
JOIN
    CENTERS c
ON
    c.ID = ss.OWNER_CENTER
JOIN
    EMPLOYEES emp
ON
    emp.CENTER = ss.EMPLOYEE_CENTER
    AND emp.ID = ss.EMPLOYEE_ID
JOIN
    PERSONS pemp
ON
    pemp.CENTER = emp.PERSONCENTER
    AND pemp.ID = emp.PERSONID
JOIN
    PERSONS p
ON
    p.CENTER = ss.OWNER_CENTER
    AND p.ID = ss.OWNER_ID
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    p.center = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
    AND ar.AR_TYPE = 4
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
JOIN
    PAYMENT_AGREEMENTS pag
ON
    pag.CENTER = pac.ACTIVE_AGR_CENTER
    AND pag.ID = pac.ACTIVE_AGR_ID
    AND pag.SUBID = pac.ACTIVE_AGR_SUBID
JOIN
    CLEARINGHOUSES ch
ON
    ch.id = pag.CLEARINGHOUSE
LEFT JOIN
    relatives r
ON
    p.center = r.relativecenter
    AND p.id = r.relativeid
    AND r.rtype = 2
    AND r.status <> 3
LEFT JOIN
    person_ext_attrs ph
ON
    ph.personcenter = p.center
    AND ph.personid = p.id
    AND ph.name = '_eClub_PhoneHome'
LEFT JOIN
    person_ext_attrs pem
ON
    pem.personcenter = p.center
    AND pem.personid = p.id
    AND pem.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs pm
ON
    pm.personcenter = p.center
    AND pm.personid = p.id
    AND pm.name = '_eClub_PhoneSMS'
WHERE
    p.CENTER IN ($$Scope$$)
    AND ss.SALES_DATE BETWEEN $$salesDateFrom$$ AND $$salesDateTo$$
    AND ( (
            'ALL' = $$ClearinghouseName$$)
        OR (
            ch.name = $$ClearinghouseName$$) )