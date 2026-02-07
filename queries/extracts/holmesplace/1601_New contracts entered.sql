SELECT
    salesperson.FULLNAME SALESPERSON,
    ss.OWNER_CENTER || 'p' || ss.OWNER_ID person_id,
    owner.FULLNAME,
    payment_ar.BALANCE ACCOUNT_BALANCE,
    prod.NAME MEMBERSHIP,
    ss.PRICE_NEW JOINING,
    ss.PRICE_ADMIN_FEE adminFee,
    ss.PRICE_PRORATA PRORATA,
    ss.PRICE_INITIAL INITIALP,
    ss.PRICE_PERIOD periodPrice,
    SUM(mp.CACHED_PRODUCTPRICE) addonTotal,
    DECODE(pa.STATE , 1,'CREATED', 2,'SENT', 3,'FAILED', 4,'OK', 5,'ENDED BY BANK', 6, 'ENDED BY CLEARING HOUSE', 7,
    'ENDED BY DEBITOR', 8,'CANCELLED', 9,'END REQUEST SENT', 10, 'ENDED BY CREDITOR', 11,'NO AGREEMENT', 12,
    'DEPRECATED', 13,'NOT NEEDED',14,'INCOMPLETE',15, 'TRANSFERRED','NONE') AS DDM_STATE,
    DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS MEM_STATE,
    DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6,
    'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN') AS MEM_SUBSTATE,
    TO_CHAR(sub.START_DATE, 'DD-MM-YYYY') startdate,
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY') creationdate,
    owner.address1,
    owner.address2,
    owner.zipcode,
    owner.city,
    home.TXTVALUE homephone,
    mobile.TXTVALUE mobilephone,
    email.TXTVALUE email,
    CASE
        WHEN passport.TXTVALUE = 'true'
        THEN 'OK'
        ELSE NULL
    END passport,
    CASE
        WHEN corp_doc.TXTVALUE = 'true'
        THEN 'OK'
        ELSE NULL
    END corp_doc,
    CASE
        WHEN health.TXTVALUE = 'true'
        THEN 'OK'
        ELSE NULL
    END health

FROM
    HP.SUBSCRIPTION_SALES ss
JOIN
    HP.SUBSCRIPTIONS sub
ON
    sub.CENTER = ss.SUBSCRIPTION_CENTER
    AND sub.ID = ss.SUBSCRIPTION_ID
JOIN
    HP.PRODUCTS prod
ON
    ss.SUBSCRIPTION_TYPE_CENTER = prod.CENTER
    AND ss.SUBSCRIPTION_TYPE_ID = prod.ID
JOIN
    HP.PERSONS owner
ON
    owner.CENTER = sub.OWNER_CENTER
    AND owner.ID = sub.OWNER_ID
LEFT JOIN
    HP.SUBSCRIPTION_ADDON addon
ON
    sub.CENTER = addon.SUBSCRIPTION_CENTER
    AND sub.ID = addon.SUBSCRIPTION_ID
    AND addon.CANCELLED = 0
LEFT JOIN
    HP.MASTERPRODUCTREGISTER mp
ON
    addon.ADDON_PRODUCT_ID = mp.ID
LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    owner.center = home.PERSONCENTER
    AND owner.id = home.PERSONID
    AND home.name = '_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    owner.center = mobile.PERSONCENTER
    AND owner.id = mobile.PERSONID
    AND mobile.name = '_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    owner.center = email.PERSONCENTER
    AND owner.id = email.PERSONID
    AND email.name = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS passport
ON
    owner.center = passport.PERSONCENTER
    AND owner.id = passport.PERSONID
    AND passport.name = 'COMM_PASSPORT'
LEFT JOIN
    PERSON_EXT_ATTRS corp_doc
ON
    owner.center = corp_doc.PERSONCENTER
    AND owner.id = corp_doc.PERSONID
    AND corp_doc.name = 'COMM_CORPORATE_DOC'
LEFT JOIN
    PERSON_EXT_ATTRS health
ON
    owner.center = health.PERSONCENTER
    AND owner.id = health.PERSONID
    AND health.name = 'COMM_HEALTH_QUESTIONNAIRE'
LEFT JOIN
    ACCOUNT_RECEIVABLES payment_ar
ON
    payment_ar.CUSTOMERCENTER = owner.center
    AND payment_ar.CUSTOMERID = owner.id
    AND payment_ar.AR_TYPE = 4
LEFT JOIN
    PAYMENT_ACCOUNTS paymentaccount
ON
    paymentaccount.center = payment_ar.center
    AND paymentaccount.id = payment_ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pa
ON
    paymentaccount.ACTIVE_AGR_CENTER = pa.center
    AND paymentaccount.ACTIVE_AGR_ID = pa.id
    AND paymentaccount.ACTIVE_AGR_SUBID = pa.subid
LEFT JOIN
    HP.EMPLOYEES emp
ON
    ss.EMPLOYEE_CENTER = emp.CENTER
    AND ss.EMPLOYEE_ID = emp.ID
LEFT JOIN
    HP.PERSONS salesperson
ON
    salesperson.CENTER = emp.PERSONCENTER
    AND salesperson.ID = emp.PERSONID
WHERE
    ss.SUBSCRIPTION_CENTER = :Center
    AND longtodate(sub.CREATION_TIME) > :CreationFrom
    AND longtodate(sub.CREATION_TIME) <= :CreationTo
    --ss.SUBSCRIPTION_CENTER = 14
    --AND longtodate(sub.CREATION_TIME) > '2013-01-01'
    --AND longtodate(sub.CREATION_TIME) <= '2013-01-31'
GROUP BY
    salesperson.FULLNAME,
    ss.OWNER_CENTER,
    ss.OWNER_ID,
    owner.FULLNAME,
    payment_ar.BALANCE,
    prod.NAME,
    ss.PRICE_NEW,
    ss.PRICE_ADMIN_FEE,
    ss.PRICE_PRORATA,
    ss.PRICE_INITIAL,
    ss.PRICE_PERIOD,
    pa.STATE,
    sub.STATE,
    sub.SUB_STATE,
    TO_CHAR(sub.START_DATE, 'DD-MM-YYYY'),
    TO_CHAR(longtodate(sub.CREATION_TIME), 'DD-MM-YYYY'),
    owner.address1,
    owner.address2,
    owner.zipcode,
    owner.city,
    home.TXTVALUE,
    mobile.TXTVALUE,
    email.TXTVALUE,
    passport.TXTVALUE,
    corp_doc.TXTVALUE,
    health.TXTVALUE
ORDER BY
    salesperson.FULLNAME,
    ss.OWNER_ID
