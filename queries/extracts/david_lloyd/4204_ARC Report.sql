-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-10398
WITH
    params AS
    ( SELECT
        add_months(date_trunc('month',CURRENT_DATE):: DATE,1)                    AS next_month_start
        ,add_months(date_trunc('month',CURRENT_DATE)::DATE,4) - interval '1 day' AS
        next_month_plus_3_end
    )
    , subs_last_billing_date AS
    ( --for each subscription, determine what is the 'actual' binding end date based on the
    -- termination policy - the greatest between the binding_end_date or 3 months from now
    SELECT
        *
        , GREATEST(s.binding_end_date, add_months(params.next_month_start,
        termination_notice_months) - interval '1 day',s.billed_until_date) AS last_billing_date
    FROM
        params 
    CROSS JOIN 
        ( SELECT
            s.*
            ,CASE
                WHEN (
                        st.periodunit = 2
                    AND st.periodcount = 12)
                OR  (
                        st.periodunit = 3
                    AND st.periodcount = 1)
                THEN 0
                ELSE 3
            END AS termination_notice_months
        FROM
            subscriptions s
        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        WHERE
            /* s.center||'ss'||s.id IN ('69ss201'
            , '69ss13414'
            , '69ss202'
            ,'69ss2')
            AND*/
            (
                s.end_date > CURRENT_DATE
            OR  s.end_date IS NULL) ) s
    )
    , contract_value AS
    ( SELECT
        s.center
        ,s.id
        ,s.owner_center
        ,s.owner_id
        ,SUM(duration_months_last_billing_overlap)                 AS total_months_unil_last_billing
        ,COALESCE(SUM(s.price*duration_months_last_billing_overlap),0) AS
        total_price_unil_last_billing
    FROM
        (-- calculate for each subscription price period, how many months will take place with
        -- that
        -- price until
        -- the
        -- last billing date
        SELECT
            s.center, s.id, s.owner_center, s.owner_id
            ,s.center||'ss'||s.id AS subscription_id
            ,sp.price
            ,sp.from_date
            ,sp.to_date
            ,s.billed_until_date
            , GREATEST(sp.from_date,s.billed_until_date) AS sp_last_billing_overlap_start
            ,LEAST(sp.to_date,s.last_billing_date)       AS sp_last_billing_overlap_end
            ,extract(YEAR FROM age(LEAST(sp.to_date,s.last_billing_date), GREATEST(sp.from_date,
            s.billed_until_date))) * 12 + extract(MONTH FROM age(LEAST(sp.to_date,
            s.last_billing_date), GREATEST(sp.from_date,s.billed_until_date))) AS
            duration_months_last_billing_overlap
        FROM
            subs_last_billing_date s
        LEFT JOIN
            subscription_price sp
        ON
            sp.subscription_center = s.center
        AND sp.subscription_id = s.id
        AND
            (
                sp.to_date > CURRENT_DATE
            OR  sp.to_date IS NULL)
        AND sp.from_date < s.last_billing_date) s
    GROUP BY
        s.center
        ,s.id
        ,s.owner_center
        ,s.owner_id
    )
    -- select * from contract_value where owner_center = 69 and owner_id in (486);
    , payer_contract_value AS
    ( SELECT
        payer_center
        ,payer_id
        , SUM( total_price_unil_last_billing) AS remaining_contract_value
    FROM
        ( SELECT
            COALESCE(payer.center,cv.owner_center) AS payer_center
            ,COALESCE(payer.id,cv.owner_id)        AS payer_id
            ,cv.center
            ,cv.id
            ,cv.owner_center
            ,cv.owner_id
            ,cv.total_months_unil_last_billing
            ,cv.total_price_unil_last_billing
        FROM
            contract_value cv
        LEFT JOIN
            relatives op
        ON
            op.relativecenter = cv.owner_center
        AND op.relativeid = cv.owner_id
        AND op.rtype = 12
        AND op.status <2
        LEFT JOIN
            persons payer
        ON
            op.center = payer.center
        AND op.id = payer.id )
    GROUP BY
        payer_center
        ,payer_id
    )
  ,
latest_inactive_package as
  (
   SELECT
     ROW_NUMBER() over (PARTITION BY s.owner_center, s.owner_id ORDER BY s.end_date DESC) AS sub_rnk,
     s.owner_center,
     s.owner_id,
     s.subscriptiontype_center,
     s.subscriptiontype_id,
     s.end_date,
     s.binding_end_date,
     s.subscription_price,
     (st.periodunit = 2 AND st.periodcount = 12)  OR (st.periodunit = 3 AND st.periodcount = 1)  AS is_annual,
     pr.name AS package_description,
     pg.name as package_group 
     
     FROM
        contract_value cv
    LEFT JOIN subscriptions s
    ON
         s.owner_center = cv.owner_center
        AND s.owner_id = cv.owner_id
    JOIN
        subscriptiontypes st
    ON
        st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    JOIN 
       products pr 
    ON
       st.center = pr.center
       AND st.id = pr.id   
    LEFT JOIN
       product_group pg
    ON
       pr.primary_product_group_id = pg.id       
   WHERE 
     s.state = 3 OR (s.state in (2,4,8) and s.sub_state = 9)                          
) 
, overdue_amounts 
AS
    (SELECT
        art.center
        ,art.id
        ,MIN(
        CASE
            WHEN art.due_date < CURRENT_DATE
            THEN art.due_date
            ELSE NULL
        END) AS debt_start
        ,SUM(
        CASE
            WHEN art.due_date < CURRENT_DATE
            THEN art.unsettled_amount
            ELSE NULL
        END)*-1 AS total_debt
    FROM
        ar_trans art
    WHERE
        art.status != 'CLOSED'
    AND art.due_date < CURRENT_DATE
    GROUP BY
        art.center
        ,art.id
    )
    , leave_quest AS
    (SELECT
        *
        , CAST(CAST((xpath('//question/id/text()',xml_element))[1] AS TEXT) AS INTEGER) AS qqid
        , CAST(CAST((xpath('//id/text()',unnest(xpath('//question/options/option',xml_element))))[
        1] AS TEXT) AS INTEGER) AS AID
        , CAST((xpath('//optionText/text()',unnest(xpath('//question/options/option',xml_element))
        ))[1 ] AS TEXT) AS ANSWER_TEXT
    FROM
        ( SELECT
            Q.id
            , Q.name
            , q.CREATION_TIME
            , q.externalid
            , unnest(xpath('//question',XMLPARSE(DOCUMENT convert_from(q.QUESTIONS, 'UTF-8')) ))
            AS xml_element
        FROM
            QUESTIONNAIRES q
        WHERE
            q.name = 'Reason for Leaving'-- Reason for Leaving
        ) t
    )
    , leave_reason_answer AS
    ( SELECT
        *
    FROM
        (SELECT
            QUN.CENTER
            , QUN.ID
            ,qun.LOG_TIME
            , leave_quest.ANSWER_TEXT
            , ROW_NUMBER() over (
                             PARTITION BY
                                 qun.center
                                 , qun.id
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
            qun.COMPLETED)
    WHERE
        rnk = 1
    )
SELECT
    c.external_id               AS "Club code "
    , c.name                    AS "Club "
    , co.name                   AS "Country"
    , p.external_id             AS "Member No "
    , p.birthdate               AS "Birthdate"
    , NULL                      AS "Title "
    , p.firstname               AS "First Name"
    , p.lastname                AS "Last name"
    , p.address1                AS "Address 1"
    , p.address2                AS "Address 2"
    , p.address3                AS "Address 3"
    , p.city                    AS "City"
    , NULL                      AS "County state "
    , p.zipcode                 AS "Post code "
    , phone.txtvalue            AS "Phone no "
    , mobile.txtvalue           AS "Mobile no "
    , email.txtvalue            AS "Email"
    , p.first_active_start_date AS "Initial join date"
    , latest_join_attr.txtvalue AS "Latest join date"
    , lip.binding_end_date      AS "Obligation date"
    , CASE pag.STATE
        WHEN 1 THEN 'Created'
        WHEN 2 THEN 'Sent'
        WHEN 3 THEN 'Failed'
        WHEN 4 THEN 'OK'
        WHEN 5 THEN 'Ended, bank'
        WHEN 6 THEN 'Ended, clearing house'
        WHEN 7 THEN 'Ended, debtor'
        WHEN 8 THEN 'Cancelled, not sent'
        WHEN 9 THEN 'Cancelled, sent'
        WHEN 10 THEN 'Ended, creditor'
        WHEN 11 THEN 'No agreement'
        WHEN 12 THEN 'Cash payment (deprecated)'
        WHEN 13 THEN 'Agreement not needed (invoice payment)'
        WHEN 14 THEN 'Agreement information incomplete'
        WHEN 15 THEN 'Transfer'
        WHEN 16 THEN 'Agreement Recreated'
        WHEN 17 THEN 'Signature missing'
    END              AS "Payment status "
    , NULL           AS "Payment approval date "
    , lip.package_group  AS "Package group "
    , lip.package_description AS "Package description "
    , NULL           AS "Notes "
    , c.address1     AS "Club address 1 "
    , c.address2     AS "Club address 2 "
    , c.address3     AS "Club address 3 "
    , c.city         AS "Club City "
    , co.name        AS "Club County "
    , c.zipcode      AS "Club Zip code "
    , mp.fullname    AS "Club GM name "
    , c.phone_number AS "Club phone "
    , CASE
        WHEN GREATEST(reasonforleaving.last_edit_time, leave_reason_answer.LOG_TIME,
            hobaddebt.last_edit_time) = hobaddebt.last_edit_time
        AND hobaddebt.txtvalue = 'YES'
        THEN 'HOBADDEBT'
        WHEN GREATEST(reasonforleaving.last_edit_time, leave_reason_answer.LOG_TIME,
            hobaddebt.last_edit_time) = reasonforleaving.last_edit_time
        THEN reasonforleaving.txtvalue
        ELSE leave_reason_answer.answer_text
    END                                                        AS "Reason for cancellation "
    , NULL                                                     AS "Debt Band 1 "
    , NULL                                                     AS "Debt Band 2 "
    , NULL                                                     AS "Debt Band 3 "
    , NULL                                                     AS "Debt Band 4 "
    ,oa.total_debt                                             AS current_overdue_debt
    ,COALESCE(pcv.remaining_contract_value,0)                  AS remaining_contract_value
    , oa.total_debt + COALESCE(pcv.remaining_contract_value,0) AS "Total debt "
    , CASE WHEN lip.is_annual
        THEN 1
        ELSE 12
    END * lip.subscription_price AS "SPV"
    , ROUND(lip.subscription_price /    
    CASE
        WHEN lip.is_annual
        THEN 12
        ELSE 1
    END,2) AS "SPV Monthly"
    , NULL AS "Initial Term "
    , NULL AS "Months remaining "
    , NULL AS "ARC Debt before admin fee "
    , NULL AS "Admin Fee "
    , NULL AS "Concatenate "
    , NULL AS "Commission "
    , NULL AS "ARC Debt "
    -- debt_start is the earliest duedate for any unsettled, overdue transaction on the payer's
    -- account
    , CURRENT_DATE - oa.debt_start AS "Days since debt started"
FROM
    overdue_amounts oa
JOIN
    account_receivables ar
ON
    oa.center = ar.center
AND oa.id = ar.id
JOIN
    persons p
ON
    p.center = ar.customercenter
AND p.id = ar.customerid
AND ar.ar_type = 4
LEFT JOIN
    payer_contract_value pcv
ON
    pcv.payer_center = p.center
AND pcv.payer_id = p.id
LEFT JOIN
    latest_inactive_package lip
ON
    lip.owner_center = p.center
    AND lip.owner_id = p.id
    AND lip.sub_rnk = 1    
JOIN
    centers c
ON
    c.id = p.center
JOIN
    countries co
ON
    co.id = c.country
LEFT JOIN
    PERSON_EXT_ATTRS phone
ON
    p.center =phone.PERSONCENTER
AND p.id =phone.PERSONID
AND phone.name='_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center =mobile.PERSONCENTER
AND p.id =mobile.PERSONID
AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center =email.PERSONCENTER
AND p.id =email.PERSONID
AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS latest_join_attr
ON
    p.center=latest_join_attr.PERSONCENTER
AND p.id=latest_join_attr.PERSONID
AND latest_join_attr.name='LATESTJOINDATE'
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
    persons mp
ON
    mp.center = c.manager_center
AND mp.id = c.manager_id
LEFT JOIN
    leave_reason_answer
ON
    leave_reason_answer.center = p.center
AND leave_reason_answer.id = p.id
LEFT JOIN
    PERSON_EXT_ATTRS hobaddebt
ON
    p.center=hobaddebt.PERSONCENTER
AND p.id=hobaddebt.PERSONID
AND hobaddebt.name='HOBADDEBT'
AND hobaddebt.txtvalue ='YES'
LEFT JOIN
    PERSON_EXT_ATTRS reasonforleaving
ON
    p.center=reasonforleaving.PERSONCENTER
AND p.id=reasonforleaving.PERSONID
AND reasonforleaving.name='REASONFORLEAVING'
AND reasonforleaving.txtvalue IS NOT NULL
WHERE
    oa.total_debt IS NOT NULL
AND p.center IN($$scope$$)