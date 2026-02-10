-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-10672
WITH
    params AS MATERIALIZED
    ( SELECT
        c.id                                        AS center
        , datetolongc($$from_date$$:: DATE::VARCHAR,c.id)                  AS from_date_long
        , datetolongc($$to_date$$:: DATE::VARCHAR,c.id)+1000*60*60*24 -1 AS to_date_long
        , datetolongc(add_months($$from_date$$:: DATE,-3)::VARCHAR,c.id)   AS from_3_months_date_long
        , $$from_date$$:: DATE                                             AS from_date
        , $$to_date$$:: DATE                                             AS to_date
    FROM
        centers c
    WHERE
        c.id IN ($$scope$$)
    )
    , pea_map AS
    (SELECT
        CAST((xpath('//attribute/@id',xml_element))[1] AS                    TEXT) AS attribute_name
        , CAST(unnest((xpath('//attribute/possibleValues/possibleValue/@id',xml_element))) AS TEXT
        ) AS option_id
        ,CAST(unnest( (xpath('//attribute/possibleValues/possibleValue/text()',xml_element))) AS
        TEXT) AS "value"
    FROM
        ( SELECT
            s.id
            , s.scope_type
            , s.scope_id
            , unnest(xpath('//attribute',XMLPARSE(DOCUMENT convert_from(s.mimevalue, 'UTF-8')) ))
            AS xml_element
        FROM
            systemproperties s
        WHERE
            s.globalid = 'DYNAMIC_EXTENDED_ATTRIBUTES'
        AND s.mimetype = 'text/xml') t
    )
    , last_tour_3_months AS
    ( SELECT
        *
    FROM
        ( SELECT
            p.TRANSFERS_CURRENT_PRS_CENTER
            , p. TRANSFERS_CURRENT_PRS_id
            , a.name
            , longtodatec(bk.starttime,bk.center)       AS tour_start_datetime
            , longtodatec(par.creation_time,par.center) AS tour_creation_datetime
            ,su.person_center
            ,su.person_id
            , ROW_NUMBER() over (
                             PARTITION BY
                                 p.external_id
                             ORDER BY
                                 bk.starttime DESC) AS rnk
        FROM
            params
        JOIN
            participations par
        ON
            par.center = params.center
        JOIN
            bookings bk
        ON
            bk.center = par.booking_center
        AND bk.id = par.booking_id
        JOIN
            activity a
        ON
            a.id = bk.activity
        JOIN
            persons p
        ON
            p.center = par.participant_center
        AND p.id = par.participant_id
        JOIN
            staff_usage su
        ON
            su.booking_center = bk.center
        AND su.booking_id = bk.id
        AND su.cancellation_time IS NULL
        WHERE
            bk.starttime >= params.from_3_months_date_long
        AND par.state = 'PARTICIPATION')
    WHERE
        rnk = 1
    )
    , last_call AS
    ( SELECT
        p.TRANSFERS_CURRENT_PRS_CENTER
        , p.TRANSFERS_CURRENT_PRS_id
        , longtodatec(MAX(tl.entry_time),p.TRANSFERS_CURRENT_PRS_CENTER) AS last_call
    FROM
        task_log tl
    JOIN
        tasks t
    ON
        t.id = tl.task_id
    JOIN
        TASK_TYPES tt
    ON
        tt.id = t.type_id
    JOIN
        WORKFLOWS wf
    ON
        wf.ID = tt.WORKFLOW_ID
    JOIN
        task_actions ta
    ON
        ta.id = tl.task_action_id
    JOIN
        TASK_LOG_DETAILS tld_user_choice
    ON
        tld_user_choice.TASK_LOG_ID = tl.id
    AND tld_user_choice.NAME = 'RequirementType.USER_CHOICE'
    JOIN
        persons p
    ON
        p.center = t.person_center
    AND p.id = t.person_id
    WHERE
        wf.name = 'Lead Management'
    AND ta.name = 'Contact'
    AND tld_user_choice.VALUE = 'Call'
    GROUP BY
        p.TRANSFERS_CURRENT_PRS_CENTER
        , p. TRANSFERS_CURRENT_PRS_id 
    )
    , campaign_code_usage AS
    (SELECT
        DISTINCT s.center
        ,s.id
        ,cco.code
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
        subscriptions s
    ON
        (
            s.invoiceline_center = pu.target_center
        AND s.invoiceline_id = pu.target_id
        AND pu.target_service = 'InvoiceLine')
    OR
        (
            s.center = sp.subscription_center
        AND sp.subscription_id = s.id)
    LEFT JOIN
        campaign_codes cco
    ON
        cco.id = pu.campaign_code_id
    WHERE
        pu.campaign_code_id IS NOT NULL
    AND params.center = s.center
    AND pu.plan_time BETWEEN params.from_date_long AND params.to_date_long 
    )
    , res AS
    (SELECT
        c.name                                                        AS "Club"
        , a.name                                                      AS "Region"
        , COALESCE(assigned_sales_staff.fullname,orig_staff.fullname) AS "Sales Person"
        , p.external_id                                               AS "Member No"
        , pr.name                                                     AS "Membership Type"
        , p.firstname                                                 AS "First Name"
        , p.lastname                                                  AS "Last Name"
        , date_part('year', age(CURRENT_DATE, p.birthdate))::INT      AS "Age"
        , ss.sales_date                                               AS "Join Date"
        , s.start_date                                                AS "Start Date"
        , ref_staff.fullname                                          AS "Referring Name"
        , COALESCE(ref_rel.relativecenter || 'p' || ref_rel.relativeid,'')   AS "Referring ID"
        , COALESCE((he.txtvalue = 'ONLINE JOINING'),false)                   AS "Online Joiner"
        , COALESCE((tablet.txtvalue = 'In Club Sales Tablets'), false)       AS "Tablet Joiner"
        , (SELECT
             count(je_al.id) 
          FROM
             journalentries je_al
          WHERE
             je_al.person_center = p.center
             AND je_al.person_id = p.id
             AND je_al.name = 'Acquisition Link'
         ) > 0 AS  "Acquisition Link Joiner"
        ,hem."value"          AS "How Enquired"
        ,lsm."value"          AS "Lead Source"
        , tour_staff.fullname AS "Who toured by in last 3 months"
        , ccu.code            AS "Campaign Code"
        , (SELECT
            COUNT(*)
        FROM
            checkins ch
        WHERE
            ch.person_center = p.center
        AND ch.person_id = p.id
        AND ch.checkin_time >= s.creation_time) AS "New Member Usage Since Start  Date"
        , CASE
            WHEN ks.txtvalue = '101831'
            THEN 'GREEN'
            WHEN ks.txtvalue = '101830'
            THEN 'RED'
            ELSE ks.txtvalue
        END                    AS "Red / Green Member"
        , s.subscription_price AS "Amount"
        , arp.balance          AS "Payment Account balance"
        , arc.balance          AS "Cash Account balance"
        , CASE
            WHEN cr.type = 'POS'
            THEN pro_il.total_amount
            ELSE NULL
        END                      AS "Pro Rata Paid at POS"
        , ss.price_new           AS "Joining Fee"
        , lt.tour_start_datetime AS "Last Meeting"
        , last_call.last_call    AS "Last Call"
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
        END                         AS "DD Mandate Status"
        , pic.mimevalue IS NOT NULL AS "Has Photo"
        , NULL                      AS "Membership Contract "

         , (SELECT
             count(je_we.id) 
          FROM
             journalentries je_we
          WHERE
             je_we.person_center = p.center
             AND je_we.person_id = p.id
             AND je_we.name = 'Welcome Email'
         ) > 0 AS  "Welcome Email"

          , (SELECT
             count(je_corp.id) 
          FROM
             journalentries je_corp
          WHERE
             je_corp.person_center = p.center
             AND je_corp.person_id = p.id
             AND je_corp.name = 'Proof Received'
         ) > 0 AS  "Corporate"

        , (SELECT
             count(je_health.id) 
          FROM
             journalentries je_health
          WHERE
             je_health.person_center = p.center
             AND je_health.person_id = p.id
             AND je_health.name = 'Health certificate'
             AND je_health.jetype = 31
         ) > 0 AS  "Health Declaration"

        ,(SELECT
            MAX(s2.end_date)
        FROM
            subscriptions s2
        JOIN
            persons p2
        ON
            p2.center = s2.owner_center
        AND p2.id = s2.owner_id
        WHERE
            p.transfers_current_prs_center = p2.transfers_current_prs_center
        AND p.transfers_current_prs_id = p2.transfers_current_prs_id
        AND s.creation_time > s2.creation_time) AS prev_sub_end_date
        , p.status
        , s.sub_state = 8 AS "Refunded (Boolean)"
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
        END AS "Person Type",
        (
          select 1 from 
             product_and_product_group_link pl
             where pl.product_group_id = 203  -- Product group COUNTABLE 
             and pr.center = pl.product_center and pr.id = pl.product_id 
        ) IS NOT NULL AS "Countable"
    FROM
        params
    JOIN
        subscription_sales ss
    ON
        params.center = ss.subscription_center
    JOIN
        persons p
    ON
        p.center = ss.owner_center
    AND p.id = ss.owner_id
    JOIN
        subscriptions s
    ON
        s.center = ss.subscription_center
    AND s.id = ss.subscription_id
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
    JOIN
        centers c
    ON
        c.id = p.center
    JOIN
        area_centers ac
    ON
        c.id = ac.center
    JOIN
        areas a
    ON
        a.id = ac.area
    AND a.root_area = 11
    JOIN
        employees emp
    ON
        emp.center = ss.employee_center
    AND emp.id = ss.employee_id
    JOIN
        persons orig_staff
    ON
        orig_staff.center = emp.personcenter
    AND orig_staff.id = emp.personid
    JOIN
        products pr
    ON
        pr.center = s.subscriptiontype_center
    AND pr.id = s.subscriptiontype_id
    JOIN
        subscriptiontypes st
    ON
        st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    AND NOT
        (
            st.IS_ADDON_SUBSCRIPTION)
    LEFT JOIN
        relatives ref_rel
    ON
        p.center = ref_rel.center
    AND p.id = ref_rel.id
    AND ref_rel.rtype = 13
    AND ref_rel.status < 2
    LEFT JOIN
        persons ref_staff
    ON
        ref_rel.relativeid = ref_staff.center
    AND ref_rel.relativecenter = ref_staff.center
    LEFT JOIN
        person_ext_attrs he
    ON
        he.personcenter = p.center
    AND he.personid = p.id
    AND he.name = 'HOWENQ'
    LEFT JOIN
        person_ext_attrs tablet
    ON
        tablet.personcenter = p.center
    AND tablet.personid = p.id
    AND tablet.name = 'OJJOURNEY'
    LEFT JOIN
        pea_map hem
    ON
        hem.option_id = he.txtvalue
    AND hem.attribute_name= he.name
    LEFT JOIN
        person_ext_attrs ls
    ON
        ls.personcenter = p.center
    AND ls.personid = p.id
    AND ls.name = 'LEADSOURCE'
    LEFT JOIN
        person_ext_attrs ks
    ON
        ks.personcenter = p.center
    AND ks.personid = p.id
    AND ks.name = 'KICKSTART'
    LEFT JOIN
        pea_map lsm
    ON
        lsm.option_id = ls.txtvalue
    AND lsm.attribute_name= ls.name
    LEFT JOIN
        last_tour_3_months lt
    ON
        lt.TRANSFERS_CURRENT_PRS_CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
    AND lt.TRANSFERS_CURRENT_PRS_id = p.TRANSFERS_CURRENT_PRS_id
    LEFT JOIN
        persons tour_staff
    ON
        tour_staff.center = lt.person_center
    AND tour_staff.id = lt.person_id
    LEFT JOIN
        account_receivables arp
    ON
        arp.customercenter = p.center
    AND arp.customerid = p.id
    AND arp.ar_type = 4
    LEFT JOIN
        account_receivables arc
    ON
        arc.customercenter = p.center
    AND arc.customerid = p.id
    AND arc.ar_type = 1
    LEFT JOIN
        last_call
    ON
        last_call.TRANSFERS_CURRENT_PRS_CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
    AND last_call.TRANSFERS_CURRENT_PRS_id = p.TRANSFERS_CURRENT_PRS_id
    LEFT JOIN
        payment_accounts pac
    ON
        arp.center = pac.center
    AND arp.id = pac.id
    LEFT JOIN
        payment_agreements pag
    ON
        pag.center = pac.active_agr_center
    AND pag.id = pac.active_agr_id
    AND pag.subid = pac.active_agr_subid
    LEFT JOIN
        SUBSCRIPTIONPERIODPARTS spp
    ON
        spp.center = s.center
    AND spp.id = s.id
    AND spp.SPP_TYPE = 8
    LEFT JOIN
        SPP_INVOICELINES_LINK sil
    ON
        sil.PERIOD_CENTER = spp.CENTER
    AND sil.PERIOD_ID = spp.id
    AND sil.PERIOD_SUBID = spp.SUBID
    LEFT JOIN
        invoices pro_inv
    ON
        sil.invoiceline_center = pro_inv.center
    AND sil.invoiceline_id = pro_inv.id
    LEFT JOIN
        invoice_lines_mt pro_il
    ON
        sil.invoiceline_center = pro_il.center
    AND sil.invoiceline_id = pro_il.id
    AND sil.invoiceline_subid = pro_il.subid
    LEFT JOIN
        cashregistertransactions crt
    ON
        crt.paysessionid = pro_inv.paysessionid
    LEFT JOIN
        cashregisters cr
    ON
        cr.center = pro_inv.cashregister_center
    AND cr.id = pro_inv.cashregister_id
    LEFT JOIN
        person_ext_attrs pic
    ON
        pic.personcenter = p.center
    AND pic.personid = p.id
    AND pic.name = '_eClub_Picture'
    LEFT JOIN
        campaign_code_usage ccu
    ON
        ccu.center = s.center
    AND ccu.id = s.id
    WHERE
       ss.sales_date BETWEEN params.from_Date AND params.to_date 
       AND NOT EXISTS (SELECT 1 FROM TASKS ts WHERE p.center = ts.person_center AND p.id = ts.person_id AND ts.type_id = 400) -- Winback 
    )
SELECT
    "Club"
    , "Region"
    , "Sales Person"
    , "Member No"
    , "Membership Type"
    , "First Name"
    , "Last Name"
    ,"Person Type"
    , "Age"
    , "Join Date"
    , "Start Date"
    , "Referring Name"
    , "Referring ID"
    , "Online Joiner"
    , "Tablet Joiner"
    , "Acquisition Link Joiner"
    , "How Enquired"
    , "Lead Source"
    , "Who toured by in last 3 months"
    , "Campaign Code"
    , "New Member Usage Since Start  Date"
    , "Red / Green Member"
    , "Amount"
    , "Payment Account balance"
    , "Cash Account balance"
    , SUM("Pro Rata Paid at POS") AS "Pro Rata Paid at POS"
    , "Joining Fee"
    , "Last Meeting"
    , "Last Call"
    , "DD Mandate Status"
    , "Has Photo"
    , "Membership Contract "
    , "Welcome Email"
    , "Corporate"
    , "Age"
    , "Health Declaration"
    ,"prev_sub_end_date" AS "Previous Membership End Date"
    ,COALESCE(status = 2 AND add_months("prev_sub_end_date",3) < "Join Date",false) AS "Ex-member more than 3 months"
    ,COALESCE(status = 2 AND add_months("prev_sub_end_date",3) >= "Join Date",false) AS "Ex-member less than 3 months"
    , "Refunded (Boolean)"
    , "Countable"
FROM
    res
GROUP BY
    "Club"
    , "Region"
    , "Sales Person"
    , "Member No"
    , "Membership Type"
    , "First Name"
    , "Last Name"
    ,"Person Type"
    , "Age"
    , "Join Date"
    , "Start Date"
    , "Referring Name"
    , "Referring ID"
    , "Online Joiner"
    , "Tablet Joiner"
    , "Acquisition Link Joiner"
    , "How Enquired"
    , "Lead Source"
    , "Who toured by in last 3 months"
    , "Campaign Code"
    , "New Member Usage Since Start  Date"
    , "Red / Green Member"
    , "Amount"
    , "Payment Account balance"
    , "Cash Account balance"
    , "Joining Fee"
    , "Last Meeting"
    , "Last Call"
    , "DD Mandate Status"
    , "Has Photo"
    , "Membership Contract "
    , "Welcome Email"
    , "Corporate"
    , "Age"
    , "Health Declaration"
    , "prev_sub_end_date"
    , status    
    , "Refunded (Boolean)"
    , "Countable"