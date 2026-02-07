-- This is the version from 2026-02-05
--  
WITH
    p_det AS
    (SELECT
        p.*
        , COALESCE(legacyPersonId.txtvalue,p.external_id) AS contactguid
    FROM
        persons p
    LEFT JOIN
        PERSON_EXT_ATTRS legacyPersonId
    ON
        p.center=legacyPersonId.PERSONCENTER
    AND p.id=legacyPersonId.PERSONID
    AND legacyPersonId.name='_eClub_OldSystemPersonId'
    )
    , included_subs AS
    (SELECT
        DISTINCT s.*
        ,ROW_NUMBER() over (
                        PARTITION BY
                            p.transfers_current_prs_center
                            ,p.transfers_current_prs_id
                        ORDER BY
                            (s.state IN (2,4))::INTEGER DESC
                            ,s.creation_time DESC
                            , (ppgl.product_center IS NOT NULL)::INTEGER DESC) AS rnk
    FROM
        subscriptions s
    LEFT JOIN
        product_and_product_group_link ppgl
    ON
        ppgl.product_center = s.subscriptiontype_center
    AND ppgl.product_id = s.subscriptiontype_id
    AND ppgl.product_group_id= 203
    JOIN
        subscriptiontypes st
    ON
        st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    AND NOT
        (
            st.IS_ADDON_SUBSCRIPTION)
    JOIN
        persons p
    ON
        p.center = s.owner_center
    AND p.id = s.owner_id
    )
    , last_tours AS
    (SELECT
        *
    FROM
        (SELECT
            par.participant_center
            ,par.participant_id
            , p.fullname AS touredbyname
            , ROW_NUMBER() over (
                             PARTITION BY
                                 par.participant_center
                                 ,par.participant_id
                             ORDER BY
                                 par.start_time DESC
                                 ,su.cancellation_time IS NULL) AS rnk
        FROM
            participations par
        JOIN
            staff_usage su
        ON
            su.booking_center = par.booking_center
        AND su.booking_id = par.booking_id
        JOIN
            persons p
        ON
            p.center = su.person_center
        AND p.id = su.person_id
        WHERE
            par.state != 'CANCELLED')
    WHERE
        rnk = 1
    )
    , last_visit AS
    (SELECT
        p.center
        , p.id
        , longtodatec(MIN(checkin_time),p.center)::DATE AS last_visit
    FROM
        checkins c
    JOIN
        persons p
    ON
        c.person_center = p.center
    AND c.person_id = p.id
    AND p.status IN(1
                    ,3 )
    GROUP BY
        p.center
        , p.id
    )
    , family_rel AS
    (SELECT
        rfa.center
        ,rfa.id
        ,COUNT(DISTINCT (rfa.relativecenter,rfa.relativeid)) AS num_children
    FROM
        relatives rfa
    WHERE
        rfa.rtype IN(4,12)
    AND rfa.status <2
    GROUP BY
        rfa.center
        ,rfa.id
    )
    , subs_fb_disc AS
    ( SELECT
        mpr.globalid
        , CAST (MAX(pp.price_modification_amount)*100 AS INTEGER) AS fb_disc
    FROM
        privilege_sets ps
    JOIN
        privilege_grants pg
    ON
        pg.privilege_set = ps.id
    AND pg.granter_service = 'GlobalSubscription'
    JOIN
        masterproductregister mpr
    ON
        mpr.id = pg.granter_id
    JOIN
        PRODUCT_PRIVILEGES pp
    ON
        pp.PRIVILEGE_SET = ps.id
    WHERE
        pp.ref_type = 'PRODUCT_GROUP'
    AND pp.ref_id = 404
    AND pp.valid_to IS NULL
    GROUP BY
        mpr.globalid
    )
SELECT
    p.contactguid
    , p.external_id                                            AS memberreferencenumber
    , COALESCE(opp.contactguid, mfp.contactguid,p.contactguid) AS primarycontactguid
    ,opp.center IS NULL
AND mfp.center IS NULL AS isprimary
    , CASE
        WHEN p.external_id = first_value(p.external_id) over
                                                              (
                                                          PARTITION BY
                                                              COALESCE ( opp.external_id ,
                                                              mfp.external_id , p.external_id )
                                                          ORDER BY
                                                              ( COALESCE ( opp.external_id ,
                                                              mfp.external_id , p.external_id ) =
                                                              p.external_id ) :: INTEGER DESC )
        THEN 'Primary Linked Member'
        WHEN opp.center IS NULL
        AND mfp.center IS NULL
        THEN 'Individual Member'
        WHEN COALESCE(opp.center ,mfp.center) IS NOT NULL
        THEN 'Associate Linked Member'
    END                                                                     AS memberassociationtype
    , TO_CHAR(longtodatec(cje.creation_time,p.center),'YYYY-MM-DD hh24:mi:ss') AS createdatetime
    , TO_CHAR(longtodatec(p.last_modified,p.center),'YYYY-MM-DD hh24:mi:ss')   AS updatedatetime
    , cemp.center||'emp'||cemp.id                                              AS 
                        recordcreatoruserid
    , cempp.fullname AS recordcreatorname
    , NULL           AS recordmanageruserid
    , NULL           AS recordmanagername
    , last_tours.touredbyname
    ,true          AS isactive
    ,p.center      AS siteid
    ,c.external_id AS sitecode
    ,c.name        AS sitename
    , NULL         AS title
    ,p.firstname
    ,p.middlename
    ,p.lastname
    , salutation.txtvalue AS salutation
    , p.birthdate
    ,CASE p.sex
        WHEN 'F'
        THEN 'FEMALE'
        WHEN 'M'
        THEN 'MALE'
        WHEN 'U'
        THEN 'UNDEFINED'
    END AS genderid
    ,CASE p.sex
        WHEN 'F'
        THEN 'Female'
        WHEN 'M'
        THEN 'Male'
        WHEN 'U'
        THEN 'Unknown'
    END AS genderdescription
    , GREATEST(CAST(trim(trim(trim(trim(fb_dis.txtvalue,'Legacy'),'LEGACY') ,'%'),' ') AS INTEGER)
    , subs_fb_disc.fb_disc) AS jobtitleid
    , NULL                  AS jobtitledescription
    ,NULL                   AS maritalstatusid
    , NULL                  AS maritalstatusdescription
    ,p.address1             AS line1
    ,p.address2             AS line2
    ,p.address3             AS line3
    ,p.city
    , zip.county
    , zip.zipcode                     AS postcode
    ,email.txtvalue                   AS emailaddress
    , REPLACE(phone.txtvalue,' ','')  AS hometelephone
    , NULL                            AS worktelephone
    , REPLACE(mobile.txtvalue,' ','') AS mobile
    ,NULL                             AS fax
    ,NULL                             AS webaddress
    ,NULL                             AS altadd1_line1
    , NULL                            AS altadd1_line2
    , NULL                            AS altadd1_line3
    , NULL                            AS altadd1_city
    , NULL                            AS altadd1_county
    , NULL                            AS altadd1_postcode
    , NULL                            AS altadd2_line1
    , NULL                            AS altadd2_line2
    , NULL                            AS altadd2_line3
    , NULL                            AS altadd2_city
    , NULL                            AS altadd2_county
    , NULL                            AS altadd2_postcode
    , NULL                            AS altadd3_line1
    , NULL                            AS altadd3_line2
    , NULL                            AS altadd3_line3
    , NULL                            AS altadd3_city
    , NULL                            AS altadd3_county
    , NULL                            AS altadd3_postcode
    , NULL                            AS altadd4_line1
    , NULL                            AS altadd4_line2
    , NULL                            AS altadd4_line3
    , NULL                            AS altadd4_city
    , NULL                            AS altadd4_county
    , NULL                            AS altadd4_postcode
    , NULL                            AS altadd5_line1
    , NULL                            AS altadd5_line2
    , NULL                            AS altadd5_line3
    , NULL                            AS altadd5_city
    , NULL                            AS altadd5_county
    , NULL                            AS altadd5_postcode
    , lower(channelEmail.txtvalue)    AS cancontactviaemail
    , lower(channelPhone.txtvalue)    AS cancontactviaphone
    , NULL                            AS cancontactviamobile
    , NULL                            AS cancontactviaaddress
    , NULL                            AS cansendtothirdparty
    , lower(channelSMS.txtvalue)      AS cancontactviasms
    , NULL                            AS cancontactviabulksms
    , NULL                            AS cansendemailcampaign
    , NULL                            AS cancontactviafax
    , NULL                            AS preferredcontactmethodid
    , NULL                            AS preferredcontactmethoddescription
    , NULL                            AS phonetype
    , NULL                            AS enquirytypeid -- tbd
    , NULL                            AS enquirytypedescription -- tbd
    , NULL                            AS sourceid
    , NULL                            AS sourcedescription
    , NULL                            AS promotionid
    , NULL                            AS promotiondescription
    , s.center||'ss'||s.id            AS currentmembershipid
    , CASE
        WHEN p.status = 1
        OR  (
                p.status IN(0,6)
            AND p.persontype =8) 
        OR  ( 
                p.status = 3 
            AND s.state = 8)
        THEN 1
        WHEN p.status = 2
        THEN 2
        WHEN p.status = 3 and s.state = 4
        THEN 4
    END AS memberstatusid
    , CASE
        WHEN p.status = 1
        OR  (
                p.status IN(0,6)
            AND p.persontype =8) 
        OR  ( 
                p.status = 3 
            AND s.state = 8)
        THEN 'OK'
        WHEN p.status = 2
        THEN 'CANCEL'
        WHEN p.status = 3 and s.state = 4
        THEN 'FROZEN'
    END AS memberstatuscode
    , CASE
        WHEN p.status = 1
        OR  (
                p.status IN(0,6)
            AND p.persontype =8) 
        OR  ( 
                p.status = 3 
            AND s.state = 8)
        THEN 'Package OK'
        WHEN p.status = 2
        THEN 'Package Cancelled'
        WHEN p.status = 3 and s.state = 4
        THEN 'Package Frozen'
    END                                     AS statusDescription
    , COALESCE(sfp.start_Date,s.start_Date) AS currentstatusstartdate
    , COALESCE(sfp.end_Date,s.end_date)     AS currentstatusenddate
    ,s.billed_until_date                    AS expirydate
    , NULL                                  AS renewalcount
    , CASE
        WHEN (
                p.status IN(0,6)
            AND p.persontype =8)
        THEN '4099'
        ELSE pr.globalid
    END AS membershippackageid
    ,CASE
        WHEN (
                p.status IN(0,6)
            AND p.persontype =8)
        THEN '4957'
        ELSE pr.external_id
    END                                         AS membershippackagecode
    ,pr.name                                    AS membershippackagename
    ,s.start_Date                                AS joindate
    ,last_visit.last_visit                       AS lastattenddate
    ,ss.sales_date                               AS solddate
    , ss.employee_center||'emp'||ss.employee_id  AS soldbyuserid
    , ''                                         AS soldbyname
    , s.binding_end_date                         AS obligationdate
    , s.start_Date                               AS costingdate
    , NULL                                       AS membershipdiscountpercentage
    , NULL                                       AS membershipdiscountamount
    , pag.CENTER||'ar'||pag.ID||'agr'||pag.SUBID AS defaultpaymentsetupid
    , NULL                                       AS secondarypaymentsetupid
    , NULL                                       AS paymentscheduleid
    , 0                                          AS paymentday
    , ''                                         AS notificationdate
    , comp.fullname                              AS companyname
    , ccomp.name                                 AS companyclub
    , ca.center||'p'||ca.id||'rpt'||ca.SUBID     AS organisationbenefitid
    , ca.name                                    AS organisationbenefitname
    , family_rel.num_children                    AS numchildren
    , card.identity                              AS currentmembershipcardnumber
FROM
    p_det p
LEFT JOIN
    included_subs s
ON
    p.center = s.owner_center
AND p.id = s.owner_id
AND s.rnk = 1
LEFT JOIN
    PERSON_EXT_ATTRS legacyPersonId
ON
    p.center =legacyPersonId.PERSONCENTER
AND p.id =legacyPersonId.PERSONID
AND legacyPersonId.name='_eClub_OldSystemPersonId'
LEFT JOIN
    relatives op
ON
    op.relativecenter = p.center
AND op.relativeid = p.id
AND op.rtype = 12
AND op.status <2
LEFT JOIN
    p_det opp
ON
    opp.center = op.center
AND opp.id = op.id
LEFT JOIN
    relatives mf
ON
    mf.center = p.center
AND mf.id = p.id
AND mf.rtype = 4
AND mf.status <2
LEFT JOIN
    family_rel
ON
    family_rel.center = p.center
AND family_rel.id = p.id
LEFT JOIN
    p_det mfp
ON
    mfp.center = mf.relativecenter
AND mfp.id = mf.relativeid
LEFT JOIN
    journalentries cje
ON
    cje.person_center = p.center
AND cje.person_id = p.id
AND cje.name = 'Person created'
LEFT JOIN
    employees cemp
ON
    cemp.center = cje.creatorcenter
AND cemp.id = cje.creatorid
LEFT JOIN
    persons cempp
ON
    cempp.center = cemp.personcenter
AND cempp.id = cemp.personid
LEFT JOIN
    last_tours
ON
    last_tours.participant_center = p.center
AND last_tours.participant_id = p.id
LEFT JOIN
    centers c
ON
    c.id =p.center
LEFT JOIN
    PERSON_EXT_ATTRS salutation
ON
    p.center =salutation.PERSONCENTER
AND p.id =salutation.PERSONID
AND salutation.name='_eClub_Salutation'
LEFT JOIN
    zipcodes zip
ON
    zip.country = p.country
AND zip.zipcode = p.zipcode
AND zip.city = p.city
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center =email.PERSONCENTER
AND p.id =email.PERSONID
AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center =mobile.PERSONCENTER
AND p.id =mobile.PERSONID
AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS phone
ON
    p.center =phone.PERSONCENTER
AND p.id =phone.PERSONID
AND phone.name='_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS channelPhone
ON
    p.center =channelPhone.PERSONCENTER
AND p.id =channelPhone.PERSONID
AND channelPhone.name='_eClub_AllowedChannelPhone'
LEFT JOIN
    PERSON_EXT_ATTRS channelSMS
ON
    p.center =channelSMS.PERSONCENTER
AND p.id =channelSMS.PERSONID
AND channelSMS.name='_eClub_AllowedChannelSMS'
LEFT JOIN
    PERSON_EXT_ATTRS channelEmail
ON
    p.center =channelEmail.PERSONCENTER
AND p.id =channelEmail.PERSONID
AND channelEmail.name='_eClub_AllowedChannelEmail'
LEFT JOIN
    subscription_freeze_period sfp
ON
    sfp.subscription_center = s.center
AND sfp.subscription_id = s.id
AND s.state = 4
AND sfp.start_date <= CURRENT_DATE
AND sfp.end_date > CURRENT_DATE
AND sfp.cancel_time IS NULL
LEFT JOIN
    products pr
ON
    pr.center = s.subscriptiontype_center
AND pr.id = s.subscriptiontype_id
LEFT JOIN
    last_visit
ON
    last_visit.center =p.center
AND last_visit.id = p.id
LEFT JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
LEFT JOIN
    payment_accounts pac
ON
    pac.center = ar.center
AND pac.id = ar.id
LEFT JOIN
    payment_agreements pag
ON
    pag.center = pac.active_agr_center
AND pag.id = pac.active_agr_id
AND pag.subid = pac.active_agr_subid
LEFT JOIN
    relatives rc
ON
    rc.relativecenter = p.center
AND rc.relativeid = p.id
AND rc.rtype = 2
AND rc.status <2
LEFT JOIN
    relatives rca
ON
    rca.center = p.center
AND rca.id = p.id
AND rca.rtype = 2
AND rca.status <2
LEFT JOIN
    persons comp
ON
    comp.center = rc.center
AND comp.id = rc.id
LEFT JOIN
    companyagreements ca
ON
    ca.center = rca.relativecenter
AND ca.id = rca.relativeid
AND ca.subid = rca.relativesubid
LEFT JOIN
    centers ccomp
ON
    ccomp.id = comp.center
LEFT JOIN
    entityidentifiers card
ON
    p.center = card.REF_CENTER
AND p.ID = card.REF_ID
AND card.ref_type = 1
AND card.stop_time IS NULL
AND card.ENTITYSTATUS = 1
AND idmethod = 4
LEFT JOIN
    person_ext_attrs fb_dis
ON
    fb_dis.personcenter = p.center
AND fb_dis.personid = p.id
AND fb_dis.name = 'FBDISCOUNT'
LEFT JOIN
    subs_fb_disc
ON
    subs_fb_disc.globalid = pr.globalid
LEFT JOIN
    subscription_sales ss
ON
    ss.subscription_center = s.center
AND ss.subscription_id = s.id
WHERE
    ( 
        p.status IN(1,2,3)
    OR
        (
            p.status IN(0,6)
        AND p.persontype =8))