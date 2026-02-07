SELECT
    /*+ NO_BIND_AWARE */
    DISTINCT p.CENTER || 'p' || p.id                     pid,
    floor(months_between(TRUNC(SYSDATE),p.BIRTHDATE)/12) age,
    p.FIRSTNAME,
    p.LASTNAME,
    exerpro.longToDate(MAX(ci.CHECKIN_TIME) over (PARTITION BY p.EXTERNAL_ID)) last_checkin,
    oldId.TXTVALUE                                                             old_system_id,
    c.NAME                                                                     center_name,
    FIRST_VALUE(acl.LOG_DATE) OVER (PARTITION BY p.CENTER,p.ID ORDER BY acl.LOG_DATE DESC) dd_ended_date,
    FIRST_VALUE(s.END_DATE) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.END_DATE DESC) subscription_end_date,
    ccc.AMOUNT                                                                        debt_case_amount,

    CASE
        WHEN FIRST_VALUE(s.END_DATE) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.END_DATE DESC) is not null
        THEN 'Subscription ended'
        WHEN ccc.AMOUNT is not null
        THEN 'DEBT'
        ELSE 'DD Ended'
    END                                                                               AS TERMINATION_TYPE,


    FIRST_VALUE(prod.NAME) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.END_DATE DESC) subscription_type,
    FIRST_VALUE(pg.NAME) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.END_DATE DESC)   product_group,
    email.TXTVALUE                                                                    email,
    mob.TXTVALUE                                                                      mobil,
    perCreation.txtvalue                                                              joinDate
FROM
    PERSONS p
JOIN
    CENTERS c
ON
    c.id = p.CENTER
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
    AND pac.ID = ar.ID
/* Get all with an agreement that is not OK or on it's way to be ok */    
LEFT JOIN
    PAYMENT_AGREEMENTS pagr
ON
    pagr.CENTER = pac.ACTIVE_AGR_CENTER
    AND pagr.ID = pac.ACTIVE_AGR_ID
    AND pagr.SUBID = pac.ACTIVE_AGR_SUBID
    AND pagr.STATE not IN (1,2,4,13)
/* See that that change of the payment agreement happen this period */    
LEFT JOIN
    AGREEMENT_CHANGE_LOG acl
ON
    acl.AGREEMENT_CENTER = pac.ACTIVE_AGR_CENTER
    AND acl.AGREEMENT_ID = pac.ACTIVE_AGR_ID
    AND acl.AGREEMENT_SUBID = pac.ACTIVE_AGR_SUBID
    AND acl.STATE IN (pagr.STATE)
    AND acl.LOG_DATE BETWEEN $$fromDate$$ AND $$toDate$$ +1

/* Get subscriptions that has has an end date within the period */    
LEFT JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.STATE IN (2,4,8,3)
    AND s.end_date BETWEEN $$fromDate$$ AND $$toDate$$ +1
    AND TO_CHAR(s.START_DATE,'YYYYMM') != TO_CHAR(s.END_DATE,'YYYYMM')
/* But make sure we don't have another one that is active/frozen or created  */    
LEFT JOIN
    SUBSCRIPTIONS s2
ON
    s2.OWNER_CENTER = p.CENTER
    AND s2.OWNER_ID = p.ID
    AND s2.STATE IN (2,4,8)
    AND (s2.end_date is null or s2.end_date > $$toDate$$ +1)
    AND (
        s2.CENTER,s2.ID) NOT IN ((s.CENTER,
                                  s.ID) )
LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
/* Get cash collection cases created this period */    
LEFT JOIN
    CASHCOLLECTIONCASES ccc
ON
    ccc.PERSONCENTER = p.CENTER
    AND ccc.PERSONID = p.ID
    AND ccc.CLOSED = 0
    AND ccc.SUCCESSFULL = 0
    AND ccc.MISSINGPAYMENT = 1
    /* This will make sure they where clean first day of month */
    AND ccc.STARTDATE BETWEEN $$fromDate$$ AND $$toDate$$ + 1
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = p.CENTER
    AND email.PERSONID = p.ID
    AND email.NAME = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS mob
ON
    mob.PERSONCENTER = p.CENTER
    AND mob.PERSONID = p.ID
    AND mob.NAME = '_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS oldId
ON
    oldId.PERSONCENTER = p.CENTER
    AND oldId.PERSONID = p.ID
    AND oldId.NAME = '_eClub_OldSystemPersonId'
LEFT JOIN
    CHECKINS ci
ON
    ci.PERSON_CENTER = p.CENTER
    AND ci.PERSON_ID = p.ID
LEFT JOIN
    PERSON_EXT_ATTRS perCreation
ON
    perCreation.PERSONCENTER = p.CENTER
    AND perCreation.PERSONID = p.ID
    AND perCreation.NAME = 'CREATION_DATE'
WHERE
        /*
        So if either we have
        1. A subscription with an end date in the period and no other to cover for the ended one or
        2. A bad payment agreement in the period or
        3. A cc cases that has started within the current period
        */
    ((
            s.CENTER IS NOT NULL
            AND s2.CENTER IS NULL)
        OR (
            acl.ID IS NOT NULL )
        OR (
            ccc.CENTER IS NOT NULL ))
    /* Person status at run time should be LEAD, ACTIVE or TEMPORARYINACTIVE */        
    AND p.STATUS IN (0,1,3,2)
    /* No companies */
    AND p.SEX != 'C'
    /* No staff members */
    AND p.PERSONTYPE != 2
    AND p.center IN ($$scope$$)
    and (p.center,p.id) not in 
(
SELECT
    /*+ NO_BIND_AWARE */
    DISTINCT p.CENTER , p.id                     
FROM
    PERSONS p
JOIN
    CENTERS c
ON
    c.id = p.CENTER
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
    AND pac.ID = ar.ID
/* Get all with an agreement that is not OK or on it's way to be ok */    
LEFT JOIN
    PAYMENT_AGREEMENTS pagr
ON
    pagr.CENTER = pac.ACTIVE_AGR_CENTER
    AND pagr.ID = pac.ACTIVE_AGR_ID
    AND pagr.SUBID = pac.ACTIVE_AGR_SUBID
    AND pagr.STATE not IN (1,2,4,13)
/* See that that change of the payment agreement happen this period */    
LEFT JOIN
    AGREEMENT_CHANGE_LOG acl
ON
    acl.AGREEMENT_CENTER = pac.ACTIVE_AGR_CENTER
    AND acl.AGREEMENT_ID = pac.ACTIVE_AGR_ID
    AND acl.AGREEMENT_SUBID = pac.ACTIVE_AGR_SUBID
    AND acl.STATE IN (pagr.STATE)
    AND acl.LOG_DATE BETWEEN add_months($$fromDate$$,-1) AND add_months($$toDate$$ +1,-1)

/* Get subscriptions that has has an end date within the period */    
LEFT JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.STATE IN (2,4,8)
    AND s.end_date BETWEEN add_months($$fromDate$$,-1) AND add_months($$toDate$$ +1,-1)
    AND TO_CHAR(s.START_DATE,'YYYYMM') != TO_CHAR(s.END_DATE,'YYYYMM')
/* But make sure we don't have another one that is active/frozen or created  */    
LEFT JOIN
    SUBSCRIPTIONS s2
ON
    s2.OWNER_CENTER = p.CENTER
    AND s2.OWNER_ID = p.ID
    AND s2.STATE IN (2,4,8)
    AND (s2.end_date is null or s2.end_date > add_months($$toDate$$ +1,-1))
    AND (
        s2.CENTER,s2.ID) NOT IN ((s.CENTER,
                                  s.ID) )
LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
/* Get cash collection cases created this period */    
LEFT JOIN
    CASHCOLLECTIONCASES ccc
ON
    ccc.PERSONCENTER = p.CENTER
    AND ccc.PERSONID = p.ID
    AND ccc.CLOSED = 0
    AND ccc.SUCCESSFULL = 0
    AND ccc.MISSINGPAYMENT = 1
    /* This will make sure they where clean first day of month */
    AND ccc.STARTDATE BETWEEN add_months($$fromDate$$,-1) AND add_months($$toDate$$ + 1,-1)
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = p.CENTER
    AND email.PERSONID = p.ID
    AND email.NAME = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS mob
ON
    mob.PERSONCENTER = p.CENTER
    AND mob.PERSONID = p.ID
    AND mob.NAME = '_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS oldId
ON
    oldId.PERSONCENTER = p.CENTER
    AND oldId.PERSONID = p.ID
    AND oldId.NAME = '_eClub_OldSystemPersonId'
LEFT JOIN
    CHECKINS ci
ON
    ci.PERSON_CENTER = p.CENTER
    AND ci.PERSON_ID = p.ID
LEFT JOIN
    PERSON_EXT_ATTRS perCreation
ON
    perCreation.PERSONCENTER = p.CENTER
    AND perCreation.PERSONID = p.ID
    AND perCreation.NAME = 'CREATION_DATE'
WHERE
        /*
        So if either we have
        1. A subscription with an end date in the period and no other to cover for the ended one or
        2. A bad payment agreement in the period or
        3. A cc cases that has started within the current period
        */
    ((
            s.CENTER IS NOT NULL
            AND s2.CENTER IS NULL)
        OR (
            acl.ID IS NOT NULL )
        OR (
            ccc.CENTER IS NOT NULL ))
    /* Person status at run time should be LEAD, ACTIVE or TEMPORARYINACTIVE */        
    AND p.STATUS IN (0,1,3)
    /* No companies */
    AND p.SEX != 'C'
    /* No staff members */
    AND p.PERSONTYPE != 2
    AND p.center IN ($$scope$$))