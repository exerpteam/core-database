SELECT DISTINCT
    p.CENTER || 'p' || p.id pid,
	oldId.TXTVALUE old_system_id,
    p.FIRSTNAME,
    p.LASTNAME,
    c.NAME center_name,
    CASE
        WHEN acl.ID IS NOT NULL
        THEN 1
        ELSE 0
    END AS dd_ended,
    acl.LOG_DATE dd_ended_date,
    CASE
        WHEN je.ID IS NOT NULL
            AND s.END_DATE IS NOT NULL
        THEN 1
        ELSE 0
    END AS customer_ended,
    CASE
        WHEN je.ID IS NOT NULL
            AND s.END_DATE IS NOT NULL
        THEN longToDateC(je.CREATION_TIME,p.center)
        ELSE null
    END AS customer_ended_date,
    
    s.END_DATE subscription_end_date,
    CASE
        WHEN ccc.CENTER IS NOT NULL
        THEN 1
        ELSE 0
    END AS debt_case_started,
    ccc.STARTDATE debt_case_started_date,
	ccc.AMOUNT debt_case_amount,
    prod.NAME subscription_type
FROM
    PERSONS p
JOIN CENTERS c
ON
    c.id = p.CENTER
JOIN ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
    AND ar.AR_TYPE = 4
LEFT JOIN AGREEMENT_CHANGE_LOG acl
ON
    acl.AGREEMENT_CENTER = ar.CENTER
    AND acl.AGREEMENT_ID = ar.ID
    AND acl.STATE IN (5,6,7,10)
    AND acl.LOG_DATE BETWEEN $$fromDate$$ AND $$toDate$$
LEFT JOIN SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.STATE IN (2,4,8)
LEFT JOIN JOURNALENTRIES je
ON
    je.PERSON_CENTER = p.CENTER
    AND je.PERSON_ID = p.ID
    AND je.JETYPE = 18
    AND je.REF_CENTER = s.CENTER
    AND je.REF_ID = s.ID
    AND je.CREATION_TIME BETWEEN dateToLongC(TO_CHAR($$fromDate$$, 'YYYY-MM-dd HH24:MI'),p.center) AND dateToLongC(TO_CHAR($$toDate$$, 'YYYY-MM-dd HH24:MI'),p.center)
LEFT JOIN PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN CASHCOLLECTIONCASES ccc
ON
    ccc.PERSONCENTER = p.CENTER
    AND ccc.PERSONID = p.ID
    AND ccc.CLOSED = 0
    AND ccc.SUCCESSFULL = 0
    AND ccc.MISSINGPAYMENT = 1
    AND ccc.STARTDATE BETWEEN $$fromDate$$ AND $$toDate$$
left JOIN PERSON_EXT_ATTRS oldId
ON
    oldId.PERSONCENTER = p.CENTER
    AND oldId.PERSONID = p.ID
    AND oldId.NAME = '_eClub_OldSystemPersonId'
WHERE
    ((
        je.ID IS NOT NULL
        AND s.CENTER IS NOT NULL
    )
    OR
    (
        acl.ID IS NOT NULL
    )
    OR
    (
        ccc.CENTER IS NOT NULL
    ))
    AND p.STATUS IN (0,1,3)
    AND p.SEX != 'C'
	and p.center in(:scope)