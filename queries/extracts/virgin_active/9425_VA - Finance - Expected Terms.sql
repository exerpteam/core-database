-- Parameters: fromDate(DATE),toDate(DATE),scope(SCOPE)
SELECT
    /*+ NO_BIND_AWARE */
    DISTINCT p.CENTER || 'p' || p.id pid,
    floor(months_between(TRUNC(SYSDATE),p.BIRTHDATE)/12) age,
    p.FIRSTNAME,
    p.LASTNAME,
    exerpro.longToDate(MAX(ci.CHECKIN_TIME) over (PARTITION BY p.EXTERNAL_ID)) last_checkin,
    oldId.TXTVALUE old_system_id,
	p.CENTER ClubID,
    c.SHORTNAME center_name,
    CASE
        WHEN FIRST_VALUE(s.END_DATE) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.END_DATE DESC) IS NOT NULL
        THEN 'Subscription ended'
        WHEN ccc.AMOUNT IS NOT NULL
        THEN 'Debt case'
        ELSE 'DDI case'
    END AS TERMINATION_TYPE,
    CASE
        WHEN msAgreement.STARTDATE IS NOT NULL
        THEN TO_CHAR(msAgreement.STARTDATE, 'YYYY-MM-DD')
        WHEN opAgreementCase.STARTDATE IS NOT NULL
        THEN TO_CHAR(opAgreementCase.STARTDATE, 'YYYY-MM-DD')
    END DDI_STOPPED,
    TO_CHAR(FIRST_VALUE(s.END_DATE) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.END_DATE DESC), 'YYYY-MM-DD')
    subscription_end_date,
    TO_CHAR(ccc.STARTDATE, 'YYYY-MM-DD') debt_case_start,
    ccc.AMOUNT debt_case_amount,
    FIRST_VALUE(prod.NAME) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.END_DATE DESC) subscription_type,
    FIRST_VALUE(pg.NAME) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.END_DATE DESC) product_group,
    email.TXTVALUE email,
    mob.TXTVALUE mobil,
    perCreation.txtvalue join_Date
FROM
    PERSONS p
JOIN
    CENTERS c
ON
    c.id = p.CENTER
LEFT JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.STATE IN (2,4,8,3,9)
    AND s.end_date between ADD_MONTHS (TRUNC (SYSDATE, 'MM'), 0) AND last_day(sysdate)
    AND TO_CHAR(s.START_DATE,'YYYYMM') != TO_CHAR(s.END_DATE,'YYYYMM')
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
    AND ccc.MISSINGPAYMENT = 1
    AND ccc.STARTDATE BETWEEN ADD_MONTHS (TRUNC (SYSDATE, 'MM'), 0) AND last_day(sysdate)
    /* This will make sure they where clean first day of month */
LEFT JOIN
    CASHCOLLECTIONCASES msAgreement
ON
    msAgreement.PERSONCENTER = p.CENTER
    AND msAgreement.PERSONID = p.ID
    AND msAgreement.CLOSED = 0
    AND msAgreement.MISSINGPAYMENT = 0
    AND msAgreement.STARTDATE BETWEEN ADD_MONTHS (TRUNC (SYSDATE, 'MM'), 0) AND last_day(sysdate)
LEFT JOIN
    (
        SELECT
            op_rel.RELATIVECENTER,
            op_rel.RELATIVEID,
            cc.STARTDATE
        FROM
            CASHCOLLECTIONCASES cc
        JOIN
            RELATIVES op_rel
        ON
            op_rel.CENTER = CC.PERSONCENTER
            AND op_rel.ID = CC.PERSONID
            AND op_rel.RTYPE = 12
            AND op_rel.STATUS < 3
        WHERE
            cc.MISSINGPAYMENT = 0
            AND cc.CLOSED = 0 ) opAgreementCase
ON
    opAgreementCase.RELATIVECENTER = p.CENTER
    AND opAgreementCase.RELATIVEID = p.ID
    AND opAgreementCase.STARTDATE BETWEEN ADD_MONTHS (TRUNC (SYSDATE, 'MM'), 0) AND last_day(sysdate)
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
    /* Person status at run time should be LEAD, ACTIVE or TEMPORARYINACTIVE */
    p.STATUS IN (1,3,2)
    /* No companies */
    AND p.SEX != 'C'
    /* No staff members */
    AND p.PERSONTYPE != 2
    /* Exclude product groups */
    AND (
        pg.NAME IS NULL
        OR pg.name NOT IN ( 'Mem Cat: Complimentary',
                           'Legacy Subscriptions (HO only)',
                           'Exclude From Member Count'))
    -- One of the following criteria must be met
    AND (
        msAgreement.CENTER IS NOT NULL
        OR opAgreementCase.STARTDATE IS NOT NULL
        OR ccc.CENTER IS NOT NULL
        OR S.CENTER IS NOT NULL)
    -- Check if rason is sub end date, that there is none starting in future
    AND ( (
            msAgreement.CENTER IS NOT NULL
            OR ccc.CENTER IS NOT NULL
            OR opAgreementCase.STARTDATE IS NOT NULL)
        OR (
            s.CENTER IS NOT NULL
            AND NOT EXISTS
            (
                /* But make sure we don't have another one that is active/frozen or created  */
                SELECT
                    1
                FROM
                    SUBSCRIPTIONS s2
                WHERE
                    s2.OWNER_CENTER = p.CENTER
                    AND s2.OWNER_ID = p.ID
                    AND s2.STATE IN (2,4,8)
                    AND (
                        s2.end_date IS NULL
                        OR s2.end_date > (last_day(sysdate)+1))
                    AND (
                        s2.CENTER,s2.ID) NOT IN ((s.CENTER,
                                                  s.ID)))) ) 