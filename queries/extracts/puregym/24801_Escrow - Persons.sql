SELECT
    center.id AS centerId,
    center.NAME AS centerName,
    p.center || 'p' || p.id AS personid,
    p.firstname AS firstname,
    p.MIDDLENAME AS middlename,
    p.lastname AS lastname,
    p.ssn AS ssn,
    TO_CHAR(p.birthdate, 'YYYY-MM-DD') AS birthdate,
    p.sex AS gender,
    p.ADDRESS1 AS AddressLine1,
    p.ADDRESS2 AS AddressLine2,
    p.zipcode AS zipcode,
    p.city AS city,
    p.country AS country,
    home.txtvalue AS homephone,
    workphone.txtvalue AS workphone,
    mobile.txtvalue AS mobilephone,
    email.txtvalue AS email,
    CASE
        WHEN has_sub.OWNER_CENTER IS NOT NULL
        THEN 'ACTIVE_EFT'
        WHEN has_cash_sub.OWNER_CENTER IS NOT NULL
        THEN 'ACTIVE_CASH'
        WHEN has_clipcard.OWNER_CENTER IS NOT NULL
        THEN 'CLIPCARD'
        WHEN pay_for.payer_CENTER IS NOT NULL
        THEN 'OTHER_PAYER'
        ELSE 'INACTIVE'
    END AS personcomment,
    DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,
    'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PersonType,
    CASE
        WHEN pt_rel_p.center IS NOT NULL
        THEN pt_rel_p.center || 'p' || pt_rel_p.id
        ELSE NULL
    END AS RelatedToId,
    pt_rel_p.fullname AS RelatedToName,
    comp.lastname AS RelatedToCompanyName,
    cag.NAME AS RelatedToCompanyAgreement,
    cash_ar.balance AS CashAccountBalance,
    payment_ar.balance AS PaymentAccountBalance,
    ei."IDENTITY" AS membercardid,
    CASE
      WHEN  ei.idmethod = 1 THEN
        'BARCODE'
      WHEN  ei.idmethod = 4 THEN
        'RFID'
    END as cardtype,
    pa.REF AS dd_referenceid,
    pa.CLEARINGHOUSE_REF AS dd_contractid,
    pa.BANK_REGNO dd_bankreg,
    pa.BANK_BRANCH_NO AS dd_bankbranch,
    pa.BANK_ACCNO AS dd_bankaccount,
    pa.BANK_ACCOUNT_HOLDER dd_accountholder,
    pa.EXTRA_INFO AS dd_extrainfo,
    pa.IBAN dd_iban,
    TO_CHAR(longtodate(pa.CREATION_TIME), 'YYYY-MM-DD') AS dd_creationdate,
    CASE
        WHEN
            (
                op.center IS NULL
                AND pa.state IS NOT NULL
                AND
                (
                    has_sub.owner_center IS NOT NULL
                    OR pay_for.payer_center IS NOT NULL
                )
            )
        THEN DECODE(pa.STATE, 1,'CREATED', 2,'SENT', 3,'FAILED', 4,'OK', 5,'ENDED BY DEBITOR''S BANK', 6,
            'ENDED BY THE CLEARING HOUSE', 7,'ENDED BY DEBITOR', 8,'SHAL BE CANCELLED', 9,'END REQUEST SENT', 10,
            'ENDED BY CREDITOR', 11,'NO AGREEMENT WITH DEBITOR', 12,'DEPRECATED', 13,'NOT NEEDED',14, 'INCOMPLETE',15,
            'TRANSFERRED','UNKNOWN')
        ELSE ''
    END AS dd_state,
    pa.REQUESTS_SENT,
    CASE
        WHEN op.center IS NOT NULL
        THEN op.FIRSTNAME || ' ' || op.LASTNAME
        ELSE NULL
    END AS OTHERPAYERNAME,
    op.ssn AS OTHERPAYERSSN,
    CASE
        WHEN op.CENTER IS NOT NULL
        THEN op.center || 'p' || op.id
        ELSE ''
    END AS OTHERPAYERID,
    CASE
        WHEN pay_for.PAYER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS IS_OTHER_PAYER,
    CASE
        WHEN has_sub.OWNER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS HAS_EFT_SUB,
    CASE
        WHEN has_cash_sub.OWNER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS HAS_CASH_SUB,
    CASE
        WHEN has_clipcard.OWNER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS HAS_CLIP_CARD
FROM
    persons p
JOIN CENTERS center
ON
    p.center = center.id
LEFT JOIN PERSON_EXT_ATTRS home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
LEFT JOIN PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN PERSON_EXT_ATTRS workphone
ON
    p.center=workphone.PERSONCENTER
    AND p.id=workphone.PERSONID
    AND workphone.name='_eClub_PhoneWork'
LEFT JOIN PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS personcomment
ON
    p.center=personcomment.PERSONCENTER
    AND p.id=personcomment.PERSONID
    AND personcomment.name='_eClub_Comment'
LEFT JOIN ACCOUNT_RECEIVABLES payment_ar
ON
    payment_ar.CUSTOMERCENTER = p.center
    AND payment_ar.CUSTOMERID = p.id
    AND payment_ar.AR_TYPE = 4
LEFT JOIN ACCOUNT_RECEIVABLES cash_ar
ON
    cash_ar.CUSTOMERCENTER=p.center
    AND cash_ar.CUSTOMERID=p.id
    AND cash_ar.AR_TYPE = 1
LEFT JOIN RELATIVES comp_rel
ON
    comp_rel.center=p.center
    AND comp_rel.id=p.id
    AND comp_rel.RTYPE = 3
    AND comp_rel.STATUS < 3
LEFT JOIN COMPANYAGREEMENTS cag
ON
    cag.center= comp_rel.RELATIVECENTER
    AND cag.id=comp_rel.RELATIVEID
    AND cag.subid = comp_rel.RELATIVESUBID
LEFT JOIN persons comp
ON
    comp.center = cag.center
    AND comp.id=cag.id
LEFT JOIN ENTITYIDENTIFIERS ei
ON
    ei.REF_CENTER = p.CENTER
    AND ei.REF_ID = p.id
    AND ei.entitystatus = 1
    AND ei.idmethod in (1,4)
LEFT JOIN PAYMENT_ACCOUNTS paymentaccount
ON
    paymentaccount.center = payment_ar.center
    AND paymentaccount.id = payment_ar.id
LEFT JOIN PAYMENT_AGREEMENTS pa
ON
    paymentaccount.ACTIVE_AGR_CENTER = pa.center
    AND paymentaccount.ACTIVE_AGR_ID = pa.id
    AND paymentaccount.ACTIVE_AGR_SUBID = pa.subid
LEFT JOIN RELATIVES op_rel
ON
    op_rel.relativecenter=p.center
    AND op_rel.relativeid=p.id
    AND op_rel.RTYPE = 12
    AND op_rel.STATUS < 3
LEFT JOIN PERSONS op
ON
    op.center = op_rel.center
    AND op.id = op_rel.id
LEFT JOIN ACCOUNT_RECEIVABLES otherPayerAR
ON
    otherPayerAR.CUSTOMERCENTER = op.center
    AND otherPayerAR.CUSTOMERID = op.id
    AND otherPayerAR.AR_TYPE = 4
    -- other payer
LEFT JOIN
    (
        SELECT DISTINCT
            rel.center AS PAYER_CENTER,
            rel.id AS PAYER_ID
        FROM
            PERSONS mem
        JOIN SUBSCRIPTIONS sub
        ON
            mem.center = sub.OWNER_CENTER
            AND mem.id = sub.OWNER_ID
            AND sub.STATE IN (2,4,8)
            AND
            (
                sub.end_date IS NULL
                OR sub.end_date > sub.BILLED_UNTIL_DATE
            )
        JOIN SUBSCRIPTIONTYPES st
        ON
            st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
            AND st.id = sub.SUBSCRIPTIONTYPE_ID
        JOIN RELATIVES rel
        ON
            rel.RELATIVECENTER = mem.center
            AND rel.RELATIVEID = mem.id
            AND rel.RTYPE = 12
            AND rel.STATUS < 3
        WHERE
            st.ST_TYPE = 1
            AND mem.center = 101
            AND mem.persontype NOT IN (2,8)
    )
    pay_for
ON
    pay_for.payer_center = p.center
    AND pay_for.payer_id = p.id
    -- has eft sub
LEFT JOIN
    (
        SELECT DISTINCT
            sub.owner_center,
            sub.owner_id
        FROM
            SUBSCRIPTIONS sub
        JOIN SUBSCRIPTIONTYPES st
        ON
            st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
            AND st.id = sub.SUBSCRIPTIONTYPE_ID
        WHERE
            st.ST_TYPE = 1
            AND sub.center = 101
            AND sub.STATE IN (2,4,8)
    )
    has_sub
ON
    has_sub.owner_center = p.center
    AND has_sub.owner_id = p.id
    -- has cash sub
LEFT JOIN
    (
        SELECT DISTINCT
            sub.owner_center,
            sub.owner_id
        FROM
            SUBSCRIPTIONS sub
        JOIN SUBSCRIPTIONTYPES st
        ON
            st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
            AND st.id = sub.SUBSCRIPTIONTYPE_ID
        WHERE
            st.ST_TYPE = 0
            AND sub.center = 101
            AND sub.STATE IN (2,4,8)
    )
    has_cash_sub
ON
    has_cash_sub.owner_center = p.center
    AND has_cash_sub.owner_id = p.id
    -- clipcards
LEFT JOIN
    (
        SELECT DISTINCT
            clips.OWNER_CENTER,
            clips.OWNER_ID
        FROM
            clipcards clips
        JOIN products pd
        ON
            pd.center = clips.center
            AND pd.id = clips.id
        WHERE
            clips.OWNER_CENTER = 101
            AND clips.CLIPS_LEFT > 0
            AND clips.FINISHED = 0
            AND clips.CANCELLED = 0
            AND clips.BLOCKED = 0
    )
    has_clipcard
ON
    has_clipcard.owner_center = p.center
    AND has_clipcard.owner_id = p.id
    -- get friends, family relation
LEFT JOIN RELATIVES pt_rel
ON
    pt_rel.CENTER = p.center
    AND pt_rel.id = p.id
    AND pt_rel.STATUS < 3
    AND
    (
        (
            p.PERSONTYPE = 3
            AND pt_rel.RTYPE = 1
        )
        OR
        (
            p.PERSONTYPE = 6
            AND pt_rel.RTYPE = 4
        )
    )
LEFT JOIN PERSONS pt_rel_p
ON
    pt_rel_p.center = pt_rel.RELATIVECENTER
    AND pt_rel_p.id = pt_rel.RELATIVEID
WHERE
    p.sex!='C'
    AND p.center = :Center
    AND p.persontype NOT IN (8)
    AND p.status < 4
    AND
    (
        (
            p.status IN (1,3)
            AND p.persontype NOT IN (2)
        )
        -- add other payer for active eft sub
        OR pay_for.payer_center IS NOT NULL
        -- add clipcard only owners
        OR
        (
            has_clipcard.owner_center IS NOT NULL
            AND p.persontype NOT IN (2)
        )
    )
ORDER BY
    p.center,
    p.id 