WITH
    PARAMS AS
    (
        SELECT
            :dateFrom FromDate,
            :dateTo   ToDate
        FROM
            dual
    )
SELECT
    cen.NAME,
    p.center || 'p' || p.id AS personid,
    p.FULLNAME,
    e.IDENTITY AS PIN,
p.EXTERNAL_ID as ExtID,
DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,    
p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    email.TXTVALUE               AS email,
    phone.TXTVALUE               AS phone,
    mobile.TXTVALUE              AS mobile,
    s.START_DATE                 AS JoinDate,
    pag.BANK_REGNO               AS SortCode,
    pag.BANK_ACCNO               AS Account,
    pag.INDIVIDUAL_DEDUCTION_DAY AS DeductionDay,
    cen1.NAME                    AS lastGymVisit,
    EXERP_CI.MaxExerp            AS LatestCheckin
    --    min(s.START_DATE) as START_DATE,
    --    max(s.END_DATE) as END_DATE,
    --    count(*)
FROM
    persons p
CROSS JOIN
    PARAMS
JOIN
    PUREGYM.ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
JOIN
    PUREGYM.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.START_DATE >= PARAMS.FromDate
    AND s.START_DATE <= PARAMS.ToDate
    AND s.END_DATE < s.START_DATE + 31
    AND s.END_DATE >= s.START_DATE
    AND s.SUB_STATE NOT IN (3,4,6,8)
    AND s.state = 3
JOIN
    PUREGYM.SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = s.SUBSCRIPTIONTYPE_ID
    AND st.ST_TYPE = 1
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = p.CENTER
    AND email.PERSONID = p.ID
    AND email.NAME = '_eClub_Email'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS mobile
ON
    mobile.PERSONCENTER = p.CENTER
    AND mobile.PERSONID = p.ID
    AND mobile.NAME = '_eClub_PhoneSMS'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS phone
ON
    phone.PERSONCENTER = p.CENTER
    AND phone.PERSONID = p.ID
    AND phone.NAME = '_eClub_PhoneHome'
JOIN
    PUREGYM.CENTERS cen
ON
    cen.ID = p.CENTER
JOIN
    PUREGYM.PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
JOIN
    PUREGYM.PAYMENT_AGREEMENTS pag
ON
    pag.CENTER = pac.ACTIVE_AGR_CENTER
    AND pag.ID = pac.ACTIVE_AGR_ID
    AND pag.SUBID = pac.ACTIVE_AGR_SUBID
LEFT JOIN
    (
        SELECT
            p.center,
            p.id,
            ci.CHECKIN_CENTER,
            TO_CHAR(longtodateTZ(MAX(ci.CHECKIN_TIME), 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS MaxExerp
        FROM
            PUREGYM.PERSONS p
        LEFT JOIN
            PUREGYM.CHECKINS ci
        ON
            ci.PERSON_CENTER = p.center
            AND ci.PERSON_ID = p.id
        GROUP BY
            p.center,
            p.id,
            ci.CHECKIN_CENTER ) EXERP_CI
ON
    EXERP_CI.center = p.center
    AND EXERP_CI.id = p.id
LEFT JOIN
    PUREGYM.CENTERS cen1
ON
    cen1.ID = EXERP_CI.CHECKIN_CENTER
LEFT JOIN
    PUREGYM.ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER = p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
WHERE
p.center in($$scope$$) and
    NOT EXISTS
    (
        SELECT
            1
        FROM
            PUREGYM.PAYMENT_REQUESTS pr
        WHERE
            pr.CENTER = ar.CENTER
            AND pr.ID = ar.ID
            AND pr.STATE IN (3,4)
            AND pr.REQ_DATE >= s.start_date
            AND pr.REQ_DATE <= s.end_date+1
            AND pr.REQUEST_TYPE IN (1,6) )
    AND EXISTS
    (
        SELECT
            1
        FROM
            PUREGYM.PAYMENT_REQUESTS parq
        WHERE
            parq.CENTER = ar.CENTER
            AND parq.ID = ar.ID
            AND parq.REQ_DATE >= s.start_date
            AND parq.REQ_DATE <= s.end_date+1
            AND parq.state NOT IN (8)
            AND parq.REQUEST_TYPE IN (1,6))