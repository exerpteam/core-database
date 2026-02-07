-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/EC-10285
WITH
    future_freeze AS
    (   SELECT
            *
        FROM
            (   SELECT
                    fr.subscription_center , 
                    fr.subscription_id , 
                    TO_CHAR(fr.START_DATE, 'YYYY-MM-DD') AS FreezeFrom , 
                    TO_CHAR(fr.END_DATE, 'YYYY-MM-DD')   AS FreezeTo , 
                    fr.text                              AS FreezeReason , 
                    ROW_NUMBER() over (
                                   PARTITION BY
                                       fr.subscription_center , 
                                       fr.subscription_id
                                   ORDER BY
                                       fr.START_DATE ASC) AS rnk
                FROM
                    SUBSCRIPTION_FREEZE_PERIOD fr
                WHERE
                    fr.subscription_center IN (:scope)
                AND fr.END_DATE > CURRENT_TIMESTAMP)
        WHERE
            rnk = 1
    )
    , 
    included_subs AS
    (   SELECT
            DISTINCT st.center , 
            st.id
        FROM
            subscriptiontypes st
        JOIN
            product_and_product_group_link ppgl
        ON
            ppgl.product_center = st.center
        AND ppgl.product_id = st.id
        JOIN
            product_group pg
        ON
            pg.id = ppgl.product_group_id
        WHERE
            pg.id = 203
    )
    , 
    valid_subs AS
    (   SELECT
            s.* , 
            MIN( s.start_date) over (
                                 PARTITION BY
                                     s.owner_center , 
                                     s.owner_id) AS min_start_date
        FROM
            subscriptions s
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        AND NOT
            (
                st.IS_ADDON_SUBSCRIPTION)
        WHERE
            s.owner_center IN (:scope)
    )
    , 
    last_visit AS
    (   SELECT
            p.center , 
            p.id , 
            longtodatec(MAX(checkin_time),p.center)::DATE AS last_visit
        FROM
            checkins c
        JOIN
            persons p
        ON
            c.person_center = p.center
        AND c.person_id = p.id
        AND p.status IN(1 , 
                        3 )
        WHERE
            p.center IN ( :scope )
        GROUP BY
            p.center , 
            p.id
    )
    , 
    leave_quest AS
    (   SELECT
            * , 
            CAST(CAST((xpath('//question/id/text()',xml_element))[1] AS TEXT) AS INTEGER) AS qqid , 
            CAST(CAST((xpath('//id/text()',unnest(xpath('//question/options/option',xml_element)))) 
            [ 1] AS TEXT) AS INTEGER) AS AID , 
            CAST((xpath('//optionText/text()',unnest(xpath('//question/options/option',xml_element) 
            ) ))[1 ] AS TEXT) AS ANSWER_TEXT
        FROM
            (   SELECT
                    Q.id , 
                    Q.name , 
                    q.CREATION_TIME , 
                    q.externalid , 
                    unnest(xpath('//question',XMLPARSE(DOCUMENT convert_from(q.QUESTIONS, 'UTF-8')) 
                    )) AS xml_element
                FROM
                    QUESTIONNAIRES q
                WHERE
                    q.name = 'Reason for Leaving'-- Reason for Leaving
            ) t
    )
    , 
    leave_reason_answer AS
    (   SELECT
            *
        FROM
            (   SELECT
                    QUN.CENTER , 
                    QUN.ID , 
                    qun.LOG_TIME , 
                    leave_quest.ANSWER_TEXT , 
                    ROW_NUMBER() over (
                                   PARTITION BY
                                       qun.center , 
                                       qun.id
                                   ORDER BY
                                       qun.LOG_TIME DESC) AS rnk
                FROM
                    QUESTION_ANSWER QA
                JOIN
                    QUESTIONNAIRE_ANSWER QUN
                ON
                    QA.ANSWER_CENTER = QUN.CENTER
                AND QA.ANSWER_ID = QUN.ID
                AND QA.ANSWER_SUBID = QUN.SUBID
                JOIN
                    QUESTIONNAIRE_CAMPAIGNS QC
                ON
                    QC.ID = QUN.QUESTIONNAIRE_CAMPAIGN_ID
                JOIN
                    leave_quest
                ON
                    leave_quest.ID = QC.QUESTIONNAIRE
                AND qa.QUESTION_ID = leave_quest.qqid
                AND qa.NUMBER_ANSWER = leave_quest.AID
                WHERE
                    qun.COMPLETED = 1)
        WHERE
            rnk = 1
    ) 
    , 
    scStop AS
    (   SELECT
            *
        FROM
            (   SELECT
                    scStop.* , 
                    ROW_NUMBER() over (
                                   PARTITION BY
                                       scStop.OLD_SUBSCRIPTION_CENTER , 
                                       scStop.OLD_SUBSCRIPTION_ID
                                   ORDER BY
                                       scStop.CHANGE_TIME DESC) AS rnk
                FROM
                    SUBSCRIPTION_CHANGE scStop -- The newly introduced join to fetch lesser rows
                WHERE
                    scStop.TYPE = 'END_DATE' )
        WHERE
            rnk =1
    )
SELECT
    DISTINCT p.external_id                                 AS "Person Id" , 
    p.center || 'p' || p.id                                AS "Member Id" , 
    salutation.txtvalue                                    AS "Title" , 
    p.firstname                                            AS "First Name" , 
    p.lastname                                             AS "Last Name" , 
    center.NAME                                            AS "Club" , 
    TO_CHAR(p.birthdate, 'YYYY-MM-DD')                     AS "Birth Date" , 
    p.sex                                                  AS "Gender" , 
    date_part('year', age(CURRENT_DATE, p.birthdate))::INT AS "Age" , 
    p.address1                                             AS "Address Line 1" , 
    p.address2                                             AS "Address Line 2" , 
    p.address3                                             AS "Address Line 3" , 
    p.city                                                 AS "Town" , 
    zipcode.county                                         AS "County" , 
    p.zipcode                                              AS "Post Code" , 
    mobile.txtvalue                                        AS "Mobile Number" , 
    CASE channelSMS.txtvalue
        WHEN 'true'
        THEN 'Yes'
        ELSE 'No'
    END            AS "Can SMS" , 
    email.txtvalue AS "Email" , 
    CASE channelEmail.txtvalue
        WHEN 'true'
        THEN 'Yes'
        ELSE 'No'
    END AS "Email Opted In" , 
    CASE
        WHEN ei_barcode.ID IS NOT NULL
        THEN ei_barcode.IDENTITY
        ELSE NULL
    END AS "Card No - Barcode" , 
    CASE
        WHEN ei_mag.ID IS NOT NULL
        THEN ei_mag.IDENTITY
        ELSE NULL
    END AS "Card No - Magnetic" , 
    CASE
        WHEN ei_rfid.ID IS NOT NULL
        THEN ei_rfid.IDENTITY
        ELSE NULL
    END                                                      AS "Card No - RFID" , 
    last_visit.last_visit                                    AS "Last Attend Date" , 
    LEAST(s.min_start_date, latest_join_attr.txtvalue::DATE) AS "Initial Join Date" , 
    latest_join_attr.txtvalue                                AS "Latest Join Date" , 
    TO_CHAR(s.BINDING_END_DATE, 'YYYY-MM-DD')                AS "Obligation Date" , 
    CASE
        WHEN fh.subscription_center IS NOT NULL
        THEN 'FROZEN'
        WHEN s.end_date IS NOT NULL
        THEN 'EXPIRED'
    END AS "Pending Status" , 
    CASE
        WHEN fh.subscription_center IS NOT NULL
        THEN CAST(fh.FreezeFrom AS DATE)
        WHEN s.end_date IS NOT NULL
        THEN s.end_date
    END AS "Pending Status Start" , 
    CASE
        WHEN GREATEST(reasonforleaving.last_edit_time, leave_reason_answer.LOG_TIME, 
            hobaddebt.last_edit_time) = hobaddebt.last_edit_time
        THEN hobaddebt.txtvalue
        WHEN GREATEST(reasonforleaving.last_edit_time, leave_reason_answer.LOG_TIME, 
            hobaddebt.last_edit_time) = reasonforleaving.last_edit_time
        THEN reasonforleaving.txtvalue
        ELSE leave_reason_answer.answer_text
    END             AS "Reason For Leaving" , 
    fh.FreezeReason AS "Reason For Suspending" , 
    CASE
        WHEN st.st_type = 0
        THEN TO_CHAR(s.end_date, 'YYYY-MM-DD')
        ELSE TO_CHAR(s.BILLED_UNTIL_DATE, 'YYYY-MM-DD')
    END                                                      AS "Expiry Date" , 
    pd.GLOBALID                                              AS "Package Code" , 
    pd.name                                                  AS "Package Description" , 
    pg.name                                                  AS "Package Group Description" , 
    s.subscription_price                                     AS "Membership Rate" , 
    comp.fullname                                            AS "Organisation" , 
    cag.NAME                                                 AS "Organisation Benefit" , 
    COALESCE(opp.external_id, mfp.external_id,p.external_id) AS "Primary Member No" , 
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
        ELSE 'UNKNOWN'
    END AS "Member Type" , 
    CASE
        WHEN pa.STATE IS NULL
        THEN NULL
        WHEN pa.STATE = 1
        THEN 'CREATED'
        WHEN pa.STATE = 2
        THEN 'SENT'
        WHEN pa.STATE = 3
        THEN 'FAILED'
        WHEN pa.STATE = 4
        THEN 'OK'
        WHEN pa.STATE = 5
        THEN 'ENDED BY DEBITOR''S BANK'
        WHEN pa.STATE = 6
        THEN 'ENDED BY THE CLEARING HOUSE'
        WHEN pa.STATE = 7
        THEN 'ENDED BY DEBITOR'
        WHEN pa.STATE = 8
        THEN 'SHAL BE CANCELLED'
        WHEN pa.STATE = 9
        THEN 'END REQUEST SENT'
        WHEN pa.STATE = 10
        THEN 'ENDED BY CREDITOR'
        WHEN pa.STATE = 11
        THEN 'NO AGREEMENT WITH DEBITOR'
        WHEN pa.STATE = 12
        THEN 'DEPRECATED'
        WHEN pa.STATE = 13
        THEN 'NOT NEEDED'
        WHEN pa.STATE = 14
        THEN 'INCOMPLETE'
        WHEN pa.STATE = 15
        THEN 'TRANSFERRED'
        ELSE 'UNKNOWN'
    END AS "Payment Method Status" , 
    CASE
        WHEN pa.state = 4
        THEN true
        ELSE false
    END                                                    AS "Active DD" , 
    pa.REF                                                 AS "DD Ref No" , 
    payment_ar.balance                                     AS "Balance" , 
    longtodatec(acl.entry_time,acl.agreement_center)::DATE AS "Approved Date" , 
    NULL                                                   AS "ID Number" , 
    rcc.txtvalue                                           AS "Recurring Payment Opt In" , 
    CASE
        WHEN ei_rfid.ID IS NOT NULL
        THEN ei_rfid.IDENTITY
        ELSE NULL
    END             AS "Wrist Band Number" , 
    cspr.GLOBALID   AS "Future Package Code" , 
    cspr.name       AS "Future Package Description" , 
    cs.start_Date   AS "Effective Date" , 
    fh.FreezeReason AS "Freeze Type" , 
    fh.FreezeFrom   AS "Freeze Start" , 
    fh.FreezeTo     AS "Freeze End" , 
    frpr.price      AS "Frozen Fees Override" , 
    fsp.from_date   AS "Future Price Date" , 
    fsp.price       AS "Future Price" , 
    CASE channelPhone.txtvalue
        WHEN 'true'
        THEN 'Yes'
        ELSE 'No'
    END AS "Can Contact Via Phone" , 
    CASE channelWhatsapp.txtvalue
        WHEN 'true'
        THEN 'Yes'
        ELSE 'No'
    END AS "Can Send Whats App" , 
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
        ELSE 'Undefined'
    END             AS "Current Member Status",
    barter.txtvalue AS "Barter Type"
    --,pa.bank_accno as "Bank Account Number"
    --,pa.bank_regno as "Bank Account Sort Code"
    , 
    longtodatec(scStop.CHANGE_TIME,p.center) AS "Subscription stop planned date" , 
    scStopstaff.fullname                     AS "Staff who cancelled the subscription" , 
    escStopEmp.center||'emp'||escStopEmp.id  AS "Staff ID who cancelled the subscription"
    
FROM
    persons p
JOIN
    CENTERS center
ON
    p.center = center.id
LEFT JOIN
    zipcodes zipcode
ON
    zipcode.country = p.country
AND zipcode.zipcode = p.zipcode
AND zipcode.city = p.city
LEFT JOIN
    PERSON_EXT_ATTRS salutation
ON
    p.center=salutation.PERSONCENTER
AND p.id=salutation.PERSONID
AND salutation.name='_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
AND p.id=mobile.PERSONID
AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
AND p.id=email.PERSONID
AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS channelEmail
ON
    p.center=channelEmail.PERSONCENTER
AND p.id=channelEmail.PERSONID
AND channelEmail.name='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS rcc
ON
    p.center=rcc.PERSONCENTER
AND p.id=rcc.PERSONID
AND rcc.name='RECURRINGCREDITCARD'
LEFT JOIN
    PERSON_EXT_ATTRS channelPhone
ON
    p.center=channelPhone.PERSONCENTER
AND p.id=channelPhone.PERSONID
AND channelPhone.name='_eClub_AllowedChannelPhone'
LEFT JOIN
    PERSON_EXT_ATTRS channelSMS
ON
    p.center=channelSMS.PERSONCENTER
AND p.id=channelSMS.PERSONID
AND channelSMS.name='_eClub_AllowedChannelSMS'
LEFT JOIN
    ACCOUNT_RECEIVABLES payment_ar
ON
    payment_ar.CUSTOMERCENTER = p.center
AND payment_ar.CUSTOMERID = p.id
AND payment_ar.AR_TYPE = 4
LEFT JOIN
    ACCOUNT_RECEIVABLES cash_ar
ON
    cash_ar.CUSTOMERCENTER=p.center
AND cash_ar.CUSTOMERID=p.id
AND cash_ar.AR_TYPE = 1
LEFT JOIN
    RELATIVES comp_rel
ON
    comp_rel.center=p.center
AND comp_rel.id=p.id
AND comp_rel.RTYPE = 3
AND comp_rel.STATUS < 3
LEFT JOIN
    COMPANYAGREEMENTS cag
ON
    cag.center= comp_rel.RELATIVECENTER
AND cag.id=comp_rel.RELATIVEID
AND cag.subid = comp_rel.RELATIVESUBID
LEFT JOIN
    persons comp
ON
    comp.center = cag.center
AND comp.id=cag.id
LEFT JOIN
    ENTITYIDENTIFIERS ei_barcode
ON
    ei_barcode.REF_CENTER = p.CENTER
AND ei_barcode.REF_ID = p.id
AND ei_barcode.entitystatus = 1
AND ei_barcode.idmethod = 1
AND ei_barcode.ref_type = 1
LEFT JOIN
    ENTITYIDENTIFIERS ei_mag
ON
    ei_mag.REF_CENTER = p.CENTER
AND ei_mag.REF_ID = p.id
AND ei_mag.entitystatus = 1
AND ei_mag.idmethod = 2
AND ei_mag.ref_type = 1
LEFT JOIN
    ENTITYIDENTIFIERS ei_rfid
ON
    ei_rfid.REF_CENTER = p.CENTER
AND ei_rfid.REF_ID = p.id
AND ei_rfid.entitystatus = 1
AND ei_rfid.idmethod = 4
AND ei_rfid.ref_type = 1
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
    agreement_change_log acl
ON
    acl.agreement_center = pa.center
AND acl.agreement_id = pa.id
AND acl.agreement_subid = pa.subid
AND acl.state = 4 -- Ok
JOIN
    valid_subs s
ON
    s.OWNER_CENTER = p.CENTER
AND s.OWNER_ID = p.ID
AND s.state IN (2,3,4)
JOIN
    SUBSCRIPTIONTYPES st
ON
    s.SUBSCRIPTIONTYPE_CENTER=st.center
AND s.SUBSCRIPTIONTYPE_ID=st.id
JOIN
    PRODUCTS pd
ON
    st.center=pd.center
AND st.id=pd.id
LEFT JOIN
    product_group pg
ON
    pd.primary_product_group_id = pg.id
LEFT JOIN
    future_freeze AS fh
ON
    fh.subscription_center = s.center
AND fh.subscription_id = s.id
LEFT JOIN
    RELATIVES pt_rel
ON
    pt_rel.CENTER = p.center
AND pt_rel.id = p.id
AND pt_rel.STATUS < 3
AND
    (
        (
            p.PERSONTYPE = 3
        AND pt_rel.RTYPE = 1 )
    OR
        (
            p.PERSONTYPE = 6
        AND pt_rel.RTYPE = 4 ) )
LEFT JOIN
    PERSONS pt_rel_p
ON
    pt_rel_p.center = pt_rel.RELATIVECENTER
AND pt_rel_p.id = pt_rel.RELATIVEID
LEFT JOIN
    subscription_price fsp
ON
    fsp.subscription_center = s.center
AND fsp.subscription_id = s.id
AND fsp.from_date > CURRENT_DATE
AND NOT fsp.cancelled
LEFT JOIN
    PERSON_EXT_ATTRS channelWhatsapp
ON
    p.center=channelWhatsapp.PERSONCENTER
AND p.id=channelWhatsapp.PERSONID
AND channelWhatsapp.name='WHATSAPP'
LEFT JOIN
    products frpr
ON
    frpr.center = st.freezeperiodproduct_center
AND frpr.id = st.freezeperiodproduct_id
LEFT JOIN
    last_visit
ON
    last_visit.center = p.center
AND last_visit.id = p.id
LEFT JOIN
    leave_reason_answer
ON
    leave_reason_answer.center = p.center
AND leave_reason_answer.id = p.id
LEFT JOIN
    relatives op
ON
    op.relativecenter = p.center
AND op.relativeid = p.id
AND op.rtype = 12
AND op.status <2
LEFT JOIN
    persons opp
ON
    op.center = opp.center
AND op.id = opp.id
LEFT JOIN
    relatives mf
ON
    mf.center = p.center
AND mf.id = p.id
AND mf.rtype = 4
AND mf.status <2
LEFT JOIN
    persons mfp
ON
    mf.relativecenter =mfp.center
AND mf.relativeid =mfp.id
LEFT JOIN
    subscriptions cs
ON
    p.center = cs.owner_center
AND p.id = cs.owner_id
AND cs.start_Date > CURRENT_DATE
AND cs.sub_state != 8
LEFT JOIN
    products cspr
ON
    cspr.center = cs.SUBSCRIPTIONTYPE_CENTER
AND cspr.id = cs.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    PERSON_EXT_ATTRS latest_join_attr
ON
    p.center=latest_join_attr.PERSONCENTER
AND p.id=latest_join_attr.PERSONID
AND latest_join_attr.name='LATESTJOINDATE'
LEFT JOIN
    PERSON_EXT_ATTRS hobaddebt
ON
    p.center=hobaddebt.PERSONCENTER
AND p.id=hobaddebt.PERSONID
AND hobaddebt.name='HOBADDEBT'
LEFT JOIN
    PERSON_EXT_ATTRS reasonforleaving
ON
    p.center=reasonforleaving.PERSONCENTER
AND p.id=reasonforleaving.PERSONID
AND reasonforleaving.name='REASONFORLEAVING'
LEFT JOIN
    PERSON_EXT_ATTRS barter
ON
    p.center=barter.PERSONCENTER
AND p.id=barter.PERSONID
AND barter.name='BARTERTYPE'
LEFT JOIN
    scStop
ON
    scStop.old_subscription_center = s.center
AND scStop.old_subscription_id = s.id
LEFT JOIN
    employees escStopEmp
ON
    escStopEmp.center = scStop.EMPLOYEE_CENTER
AND escStopEmp.id = scStop.EMPLOYEE_ID
LEFT JOIN
    persons scStopstaff
ON
    escStopEmp.PERSONCENTER = scStopstaff.center
AND escStopEmp.PERSONID =scStopstaff.id
WHERE
    p.center IN (:scope)