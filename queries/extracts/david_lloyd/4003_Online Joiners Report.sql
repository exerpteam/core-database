-- The extract is extracted from Exerp on 2026-02-08
--  
/*this report will list all online joiners for DLL. This includes those sold via the online
join
journey (e.g. website), as well as
'tablet sales' where the staff input the member details via the tablets.*/
WITH
    RECURSIVE centers_in_area AS
    ( SELECT
        a.id
        , a.parent
        , ARRAY[id] AS chain_of_command_ids
        , 2         AS level
    FROM
        areas a
    WHERE
        a.types LIKE '%system%'
    AND a.parent IS NULL
    
    UNION ALL
    
    SELECT
        a.id
        , a.parent
        , array_append(cin.chain_of_command_ids, a.id) AS chain_of_command_ids
        , cin.level + 1                                AS level
    FROM
        areas a
    JOIN
        centers_in_area cin
    ON
        cin.id = a.parent
    )
    , areas_total AS
    ( SELECT
        cin.id AS ID
        , cin.level
        , unnest(array_remove(array_agg(b.ID), NULL)) AS sub_areas
    FROM
        centers_in_area cin
    LEFT JOIN
        centers_in_area AS b -- join provides subordinates
    ON
        cin.id = ANY (b.chain_of_command_ids)
    AND cin.level <= b.level
    GROUP BY
        1
        ,2
    )
    , scope_center AS
    ( SELECT
        'A'                 AS SCOPE_TYPE
        , areas_total.ID    AS SCOPE_ID
        , c.ID              AS CENTER_ID
        , areas_total.level AS LEVEL
    FROM
        areas_total
    LEFT JOIN
        area_centers ac
    ON
        ac.area = areas_total.sub_areas
    JOIN
        centers c
    ON
        ac.CENTER = c.id
    
    UNION ALL
    
    SELECT
        'G'    AS SCOPE_TYPE
        , 0    AS SCOPE_ID
        , c.ID AS CENTER_ID
        , 0    AS LEVEL
    FROM
        centers c
    
    UNION ALL
    
    SELECT
        'T'    AS SCOPE_TYPE
        , a.id AS SCOPE_ID
        , c.ID AS CENTER_ID
        , 1    AS LEVEL
    FROM
        centers c
    CROSS JOIN
        areas a
    
    UNION ALL
    
    SELECT
        'C'    AS SCOPE_TYPE
        , c.id AS SCOPE_ID
        , c.ID AS CENTER_ID
        , 999  AS LEVEL
    FROM
        centers c
    )
    , center_config_payment_method_id AS
    ( SELECT
        center_id
        , (xpath('//attribute/@id',xml_element))[1]::             TEXT::INTEGER AS id
        , (xpath('//attribute/@name',xml_element))[1]::           TEXT          AS NAME
        , (xpath('//attribute/@globalAccountId',xml_element))[1]::TEXT          AS globalAccountId
    FROM
        ( SELECT
            center_id
            , unnest(xpath('//attribute',XMLPARSE(DOCUMENT convert_from(mimevalue, 'UTF-8')) )) AS
            xml_element
        FROM
            ( SELECT
                a.name
                , sc.center_id
                , sys.mimevalue
                , sc.level
                , MAX(sc.LEVEL) over (
                                  PARTITION BY
                                      sc.CENTER_ID) AS maxlevel
            FROM
                systemproperties SYS
            JOIN
                scope_center sc
            ON
                sc.SCOPE_ID = sys.scope_id
            AND sys.scope_type = sc.SCOPE_TYPE
            JOIN
                areas a
            ON
                a.id = sys.scope_id
            WHERE
                sys.globalid = 'PaymentMethodsConfig') t
        WHERE
            maxlevel = LEVEL)
    )
    , params AS MATERIALIZED
    ( SELECT
        --            CURRENT_DATE-interval '1 day' AS from_date ,
        --            CURRENT_DATE                  AS to_date
        c.id                                        AS center
        , datetolongc($$from_date$$:: DATE::VARCHAR,c.id)                  AS from_date_long
        , datetolongc($$to_date$$:: DATE::VARCHAR,c.id)+1000*60*60*24 -1  AS to_date_long
        ,add_months(date_trunc('month',CURRENT_DATE:: DATE )::DATE,1) AS next_month_start
        , $$from_date$$:: DATE                                              AS from_date
        , $$to_date$$:: DATE                                              AS to_date
    FROM
        centers c
    WHERE
        c.id IN ($$scope$$)
    )
    , campaign_usage AS
    (SELECT
        s.center
        ,s.id
        ,pg.GRANTER_SERVICE
        ,prg.RGTYPE
        ,pu.target_service
        ,COALESCE(prg.name,sc.name) AS "Promotion"
    FROM
        params
    CROSS JOIN
        privilege_usages pu
    LEFT JOIN
        subscription_price sp
    ON
        sp.id = pu.target_id
    AND pu.target_service = 'SubscriptionPrice'
    JOIN
        privilege_grants pg
    ON
        pg.id = pu.grant_id
    AND pg.GRANTER_SERVICE IN ('StartupCampaign'
                               , 'RetentionCampaign'
                               ,'ReceiverGroup')
    LEFT JOIN
        startup_campaign sc
    ON
        sc.id = pg.GRANTER_ID
    AND pg.GRANTER_SERVICE IN ('StartupCampaign'
                               , 'RetentionCampaign' )
    LEFT JOIN
        privilege_receiver_groups prg
    ON
        prg.id = pg.GRANTER_ID
    AND prg.RGTYPE ='CAMPAIGN'
    AND pg.GRANTER_SERVICE IN ('ReceiverGroup')
    JOIN
        subscriptions s
    ON
        (
            s.invoiceline_center = pu.target_center
        AND s.invoiceline_id = pu.target_id
        AND s.invoiceline_subid = pu.target_subid
        AND pu.target_service = 'InvoiceLine')
    OR
        (
            s.center = sp.subscription_center
        AND sp.subscription_id = s.id)
    WHERE
        pu.plan_time BETWEEN params.from_date_long AND params.to_date_long
    AND
        (
            prg.id IS NOT NULL
        OR  sc.id IS NOT NULL)
    AND s.center = params.center
    )
SELECT
    cp.external_id                                             AS "Member No"
    , comp.fullname                                            AS "Organization"
    , COALESCE(opp.external_id, mfp.external_id,p.external_id) AS "Primary Member No"
    , p.center||'p'||p.id                                      AS "Person ID "
    ,p.firstname                                               AS "First Name"
    , p.lastname                                               AS "Last Name"
    , c.name                                                   AS "Home Site"
    , p.birthdate                                              AS "Birth Date"
    , date_part('year', age(CURRENT_DATE, p.birthdate))::INT   AS "Age"
    , p.address1                                               AS "Address line 1"
    , p.address2                                               AS "Address line 2 "
    , p.address3                                               AS "Address line 3"
    , p.city                                                   AS "City"
    , COALESCE(zipcode.county,p.state)                         AS "State"
    , p.zipcode                                                AS "Post code"
    , mobile.txtvalue                                          AS "Mobile number"
    , email.txtvalue                                           AS "Email"
    ,creator.fullname                                          AS "Sales Person Name"
    ,s.center||'ss'||s.id                                      AS "Subscription ID"
    ,pr.name                                                   AS "Subscription package"
    , longtodatec(s.creation_time,s.center)::text                    AS
    "Date + Time subscription was sold"
    ,s.start_date     AS "Subscription Start Date"
    ,sp.price         AS "Next months subscription amount"
    ,ss.price_prorata AS "Pro-rata amount"
    ,ss.price_new     AS "Joining Fee"
    ,EXISTS
    (SELECT
        1
    FROM
        relatives r
    WHERE
        (
            (
                r.relativecenter = p.center
            AND r.relativeid = p.id
            AND r.rtype = 1)
        OR
            (
                r.center = p.center
            AND r.id = p.id
            AND r.rtype = 12))
    AND r.status <2)  AS "Has Associates"
    ,coalesce(assigned_sales_staff.fullname ,creator.fullname) AS "Sales Person Name"
    , COALESCE(cpm.name, CASE crt.CRTTYPE
        WHEN 1
        THEN 'CASH'
        WHEN 2
        THEN 'CHANGE'
        WHEN 3
        THEN 'RETURN ON CREDIT'
        WHEN 4
        THEN 'PAYOUT CASH'
        WHEN 5
        THEN 'PAID BY CASH AR ACCOUNT'
        WHEN 6
        THEN 'DEBIT CARD'
        WHEN 7
        THEN 'CREDIT CARD'
        WHEN 8
        THEN 'DEBIT OR CREDIT CARD'
        WHEN 9
        THEN 'GIFT CARD'
        WHEN 10
        THEN 'CASH ADJUSTMENT'
        WHEN 11
        THEN 'CASH TRANSFER'
        WHEN 12
        THEN 'PAYMENT AR'
        WHEN 13
        THEN 'CONFIG PAYMENT METHOD'
        WHEN 14
        THEN 'CASH REGISTER PAYOUT'
        WHEN 15
        THEN 'CREDIT CARD ADJUSTMENT'
        WHEN 16
        THEN 'CLOSING CASH ADJUST'
        WHEN 17
        THEN 'VOUCHER'
        WHEN 18
        THEN 'PAYOUT CREDIT CARD'
        WHEN 19
        THEN 'TRANSFER BETWEEN REGISTERS'
        WHEN 20
        THEN 'CLOSING CREDIT CARD ADJ'
        WHEN 21
        THEN 'TRANSFER BACK CASH COINS'
        WHEN 22
        THEN 'INSTALLMENT PLAN'
        WHEN 100
        THEN 'INITIAL CASH'
        WHEN 101
        THEN 'MANUAL'
    END ) AS "How these were paid"
    , CASE
        WHEN ei_rfid.ID IS NOT NULL
        THEN ei_rfid.IDENTITY
        ELSE NULL
    END AS "Card No RFID"
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
        WHEN p.status = 3
        AND s.state = 4
        THEN 'Package Frozen'
    END              AS "Package Status"
    , pr.external_id AS "Subscription Code"
    , CASE p.PERSONTYPE
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
    END AS "Person Type"
    , CASE pag.STATE
        WHEN 1
        THEN 'Created'
        WHEN 2
        THEN 'Sent'
        WHEN 3
        THEN 'Failed'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'Ended, bank'
        WHEN 6
        THEN 'Ended, clearing house'
        WHEN 7
        THEN 'Ended, debtor'
        WHEN 8
        THEN 'Cancelled, not sent'
        WHEN 9
        THEN 'Cancelled, sent'
        WHEN 10
        THEN 'Ended, creditor'
        WHEN 11
        THEN 'No agreement'
        WHEN 12
        THEN 'Cash payment (deprecated)'
        WHEN 13
        THEN 'Agreement not needed (invoice payment)'
        WHEN 14
        THEN 'Agreement information incomplete'
        WHEN 15
        THEN 'Transfer'
        WHEN 16
        THEN 'Agreement Recreated'
        WHEN 17
        THEN 'Signature missing'
    END                                         AS "DD Status"
    ,pag.CENTER||'ar'||pag.ID||'agr'||pag.SUBID AS "Payment method ID"
    ,pag.bank_accno                             AS "Bank Account Number"
    ,pag.bank_regno                             AS "Bank Account Sort Code"
    , CASE channelPhone.txtvalue
        WHEN 'true'
        THEN 'Yes'
        ELSE 'No'
    END AS "Can Contact Via Phone"
    , CASE channelSMS.txtvalue
        WHEN 'true'
        THEN 'Yes'
        ELSE 'No'
    END AS "Can Contact Via Phone"
    , CASE channelEmail.txtvalue
        WHEN 'true'
        THEN 'Yes'
        ELSE 'No'
    END AS "Can Contact Via Email"
    , CASE channelWhatsapp.txtvalue
        WHEN 'true'
        THEN 'Yes'
        ELSE 'No'
    END AS "Can Send Whats App"
    , CASE 
        WHEN ks.txtvalue = '101831' 
        THEN 'GREEN' 
        WHEN ks.txtvalue = '101830' 
        THEN 'RED' 
        ELSE ks.txtvalue 
    END AS "Kickstart questionnaire "
    , COALESCE(latest_join_attr.txtvalue,(MIN(s.start_Date) over
                                                                  (
                                                              PARTITION BY
                                                                  p.external_id)):: TEXT) AS
    "Latest joindate"
    , campaign_usage."Promotion"
    , memberurl.txtvalue    AS "Member URL"
    ,membersummary.txtvalue AS "Member Summary"
    , s.billed_until_date   AS "Billed until Date"
    , s.binding_end_date    AS "Binding end Date  "
FROM
    params
JOIN
    subscriptions s
ON
    s.center = params.center
JOIN
    employees emp
ON
    emp.center = s.creator_center
AND emp.id = s.creator_id
JOIN
    persons p
ON
    p.center = s.owner_center
AND p.id = s.owner_id
JOIN
    persons cp
ON
    cp.center = p.transfers_current_prs_center
AND cp.id = p.transfers_current_prs_id
JOIN
    persons creator
ON
    creator.center = emp.personcenter
AND creator.id = emp.personid
JOIN
    subscription_sales ss
ON
    ss.subscription_center = s.center
AND ss.subscription_id = s.id
JOIN
    subscriptiontypes st
ON
    st.center = s.subscriptiontype_center
AND st.id = s.subscriptiontype_id
AND NOT
    (
        st.is_addon_subscription)
LEFT JOIN
    relatives rc
ON
    rc.relativecenter = p.center
AND rc.relativeid = p.id
AND rc.rtype = 2
LEFT JOIN
    persons comp
ON
    comp.center = rc.center
AND comp.id = rc.id
AND rc.status <2
JOIN
    products pr
ON
    pr.center = s.subscriptiontype_center
AND pr.id = s.subscriptiontype_id
LEFT JOIN
    subscription_price sp
ON
    sp.subscription_center = s.center
AND sp.subscription_id = s.id
AND sp.from_date <= params.next_month_start
AND
    (
        sp.to_date > params.next_month_start
    OR  sp.to_date IS NULL)
JOIN
    centers c
ON
    p.center = c.id
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
    ENTITYIDENTIFIERS ei_rfid
ON
    ei_rfid.REF_CENTER = p.CENTER
AND ei_rfid.REF_ID = p.id
AND ei_rfid.entitystatus = 1
AND ei_rfid.idmethod = 4
AND ei_rfid.ref_type = 1
LEFT JOIN
    account_receivables ar
ON
    p.center = ar.customercenter
AND p.id = ar.customerid
AND ar.ar_type = 4
LEFT JOIN
    payment_agreements pag
ON
    pag.center = ar.center
AND pag.id = ar.id
LEFT JOIN
    PERSON_EXT_ATTRS channelWhatsapp
ON
    p.center=channelWhatsapp.PERSONCENTER
AND p.id=channelWhatsapp.PERSONID
AND channelWhatsapp.name='WHATSAPP'
LEFT JOIN
    PERSON_EXT_ATTRS channelSMS
ON
    p.center=channelSMS.PERSONCENTER
AND p.id=channelSMS.PERSONID
AND channelSMS.name='_eClub_AllowedChannelSMS'
LEFT JOIN
    PERSON_EXT_ATTRS channelEmail
ON
    p.center=channelEmail.PERSONCENTER
AND p.id=channelEmail.PERSONID
AND channelEmail.name='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS channelPhone
ON
    p.center=channelPhone.PERSONCENTER
AND p.id=channelPhone.PERSONID
AND channelPhone.name='_eClub_AllowedChannelPhone'
LEFT JOIN
    person_ext_attrs ks
ON
    ks.personcenter = p.center
AND ks.personid = p.id
AND ks.name = 'KICKSTART'
LEFT JOIN
    PERSON_EXT_ATTRS latest_join_attr
ON
    p.center=latest_join_attr.PERSONCENTER
AND p.id=latest_join_attr.PERSONID
AND latest_join_attr.name='LATESTJOINDATE'
LEFT JOIN
    PERSON_EXT_ATTRS memberurl
ON
    p.center=memberurl.PERSONCENTER
AND p.id=memberurl.PERSONID
AND memberurl.name='MEMBERURL'
LEFT JOIN
    PERSON_EXT_ATTRS membersummary
ON
    p.center=membersummary.PERSONCENTER
AND p.id=membersummary.PERSONID
AND membersummary.name='MEMBERSUMMARY'
LEFT JOIN
    campaign_usage
ON
    campaign_usage.center = s.center
AND campaign_usage.id = s.id
    LEFT JOIN
        invoice_sales_employee ise
    ON
        ise.invoice_center = s.invoiceline_center
    AND ise.invoice_id = s.invoiceline_id
    AND ise.stop_time IS NULL
    LEFT JOIN
        EMPLOYEES assigned_sales_emp
    ON
        assigned_sales_emp.center = ise.sales_employee_center
    AND assigned_sales_emp.id = ise.sales_employee_id
    LEFT JOIN
        PERSONS assigned_sales_staff
    ON
        assigned_sales_staff.center = assigned_sales_emp.personcenter
    AND assigned_sales_staff.ID = assigned_sales_emp.personid
LEFT JOIN
    zipcodes zipcode
ON
    zipcode.country = p.country
AND zipcode.zipcode = p.zipcode
AND zipcode.city = p.city
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
    persons mfp
ON
    mfp.center = mf.relativecenter
AND mfp.id = mf.relativeid
JOIN
    invoices inv
ON
    inv.center = s.invoiceline_center
AND inv.id = s.invoiceline_id
LEFT JOIN
    cashregistertransactions crt
ON
    crt.paysessionid = inv.paysessionid
LEFT JOIN
    center_config_payment_method_id cpm
ON
    cpm.center_id = crt.center
AND crt.config_payment_method_id = cpm.id
WHERE
    ss.sales_date BETWEEN $$from_date$$ AND $$to_date$$
AND ss.subscription_center IN ($$scope$$)
AND emp.center = 100
AND emp.id IN (450, 451) -- 450 = API USER Mwapi-Digital, 451 = API USER Middlewareapi