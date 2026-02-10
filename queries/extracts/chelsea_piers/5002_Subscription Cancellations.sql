-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/servicedesk/customer/portal/9/EC-4751

approved 7/21/22
WITH PARAMS AS
(
   SELECT 
       c.name as center,
       c.id AS CENTER_ID,
       TO_DATE($$CancelDateFrom$$,'YYYY-MM-DD') AS FROMDATE,
       TO_DATE($$CancelDateTo$$,'YYYY-MM-DD')   AS TODATE
   FROM
       centers c
   WHERE
       c.id IN ($$Scope$$)
),
cancelled_addons_and_subscriptions AS
(
        -- Addons
        SELECT
                p.persontype,
                case when st.periodunit = 1 then round(prod.price / (st.periodcount) * 30,2) --day
                        When st.periodunit = 2 then round(prod.price / st.periodcount,2)  -- month
                        When st.periodunit = 3 then round(prod.price / (st.periodcount*12),2) -- year
                        When st.periodunit = 0 then round((prod.price / (st.periodcount*7)) * 30,2) --week
                end monthly_price,
                prod.name,
                'Subscription Addon' AS ProductType,
                current_date-sa.start_date AS Subscription_Days,
                s.center||'ss'||s.id AS SubscriptionID,
                p.center AS personcenter,
                p.id     AS personid,
                p.external_id AS ExternalID,
                p.status,
                p.firstname,
                p.lastname,
                je.creation_time,
                sa.end_date,
                s.state,
                p.address1,
                p.address2,
                p.city,
                p.zipcode,
                s.assigned_staff_center,
                s.assigned_staff_id,
                pg.name AS ProductGroup,
                NULL AS SUBSCRIPTION_STATE,
                NULL AS SUBSCRIPTION_SUB_STATE
        FROM subscription_addon sa
        JOIN subscriptions s
                ON sa.subscription_center = s.center
                AND sa.subscription_id = s.id
        JOIN subscriptiontypes st
                ON st.center = s.subscriptiontype_center
                AND st.id = s.subscriptiontype_id
        JOIN params
                ON params.CENTER_ID = s.center    
        JOIN MASTERPRODUCTREGISTER mpr
                ON mpr.id = sa.ADDON_PRODUCT_ID
        JOIN PRODUCTS prod
                ON prod.center = sa.CENTER_ID
                AND prod.GLOBALID = mpr.GLOBALID
        JOIN persons p
                ON s.owner_center = p.center
                AND s.owner_id = p.id
        JOIN chelseapiers.product_group pg
                ON pg.id = mpr.primary_product_group_id
	JOIN       
        (
                SELECT
                        rank() over (partition BY j.person_center, j.person_id, j.ref_id ORDER BY j.creation_time DESC) AS rnk,
                        j.person_center AS p_center,
                        j.person_id AS p_id,
                        j.ref_id AS addon_id,
                        j.creation_time
                FROM
                        journalentries j
                WHERE
                        j.jetype = 26 -- ended addons
                        AND j.state = 'ACTIVE'
        ) je
                ON je.rnk = 1
                AND p.center = je.p_center
		AND p.id = je.p_id
                AND sa.id = je.addon_id
        WHERE
                sa.end_date >= params.fromdate 
                AND sa.end_date <= params.todate
        UNION ALL
        -- subscriptions 
        SELECT
                p.persontype,
                case when st.periodunit = 1 then round(s.subscription_price / (st.periodcount) * 30,2) --day
                        When st.periodunit = 2 then round(s.subscription_price / st.periodcount,2)  -- month
                        When st.periodunit = 3 then round(s.subscription_price / (st.periodcount*12),2) -- year
                        When st.periodunit = 0 then round((s.subscription_price / (st.periodcount*7)) * 30,2) --week
                end monthly_price,
                prod.name,
                'Subscription' AS ProductType,
                current_date-s.start_date AS Subscription_Days,
                s.center||'ss'||s.id AS SubscriptionID,
                p.center AS personcenter,
                p.id     AS personid,
                p.external_id AS ExternalID,
                p.status,
                p.firstname,
                p.lastname,
                je.creation_time,
                s.end_date,
                s.state,
                p.address1,
                p.address2,
                p.city,
                p.zipcode,
                s.assigned_staff_center,
                s.assigned_staff_id,
                pg.name ProductGroup,
                CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE,
                CASE s.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS SUBSCRIPTION_SUB_STATE
        FROM subscriptions s
        JOIN params
                ON params.CENTER_ID = s.center  
        JOIN subscriptiontypes st
                ON st.center = s.subscriptiontype_center
                AND st.id = s.subscriptiontype_id    
        JOIN PRODUCTS prod
                ON prod.center = s.subscriptiontype_center
                AND prod.ID = s.subscriptiontype_id
        JOIN chelseapiers.product_group pg
                ON pg.id = prod.primary_product_group_id
        JOIN persons p
                ON s.owner_center = p.center
                AND s.owner_id = p.id    
        JOIN       
	(
        	SELECT
			rank() over (partition BY j.person_center, j.person_id, j.ref_center, j.ref_id ORDER BY j.creation_time DESC) AS rnk,
                        j.person_center AS p_center,
                        j.person_id AS p_id,
                        j.ref_center AS sub_center,
                        j.ref_id AS sub_id,
                        j.creation_time
                FROM
                        journalentries j
                WHERE
                        j.jetype = 18 -- 'EFT subscription termination'
                        AND j.state = 'ACTIVE'
        ) je
		ON je.rnk = 1
		AND p.center = je.p_center
		AND p.id = je.p_id
		AND s.center = je.sub_center
		AND s.id = je.sub_id			
        WHERE 
                s.end_date >= params.fromdate 
                AND s.end_date <= params.todate 
                AND s.sub_state not in (3,4,5,6)
                AND NOT EXISTS 
                (
                        SELECT
                                1
                        FROM chelseapiers.subscriptions s2
                        WHERE
                                s2.owner_center = s.owner_center
                                AND s2.owner_id = s.owner_id
                                AND s2.start_date = s.end_date + interval '1 day'
                                AND s2.sub_state NOT IN (7,8)
                                AND s2.id != s.id -- to avoid loops on those subscriptions that never started
                )
)
SELECT 
        params.center AS "Center",
        CASE 
                WHEN cas.PERSONTYPE = 0 THEN 'PRIVATE' WHEN cas.PERSONTYPE = 1 THEN 'STUDENT' WHEN cas.PERSONTYPE = 2 THEN 'STAFF' WHEN cas.PERSONTYPE = 3 THEN 'FRIEND' 
                WHEN cas.PERSONTYPE = 4 THEN 'CORPORATE' WHEN cas.PERSONTYPE = 5 THEN 'ONEMANCORPORATE' WHEN cas.PERSONTYPE = 6 THEN 'FAMILY' WHEN cas.PERSONTYPE = 7 THEN 'SENIOR' 
                WHEN cas.PERSONTYPE = 8 THEN 'GUEST' WHEN cas.PERSONTYPE = 9 THEN 'CHILD' WHEN cas.PERSONTYPE = 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' 
        END AS "Person Type",
        cas.monthly_price  AS "Monthly Price",
        cas.name   AS "Subscription/Addon Name",
        cas.ProductGroup AS "Product Group",
        cas.subscription_days AS "Subscription Days",
        to_char(longtodatec(cas.creation_time,cas.personcenter),'mm/dd/yyyy')  AS "Cancellation Request Date",
        cas.subscriptionid   AS "Subscription ID",
        to_char(cas.end_date,'mm/dd/yyyy') AS "Subscription/Addon End Date",
        cas.personcenter || 'p' || cas.personid AS "Person ID",
        cas.ExternalID  AS  "Person External ID",
        fam.relativecenter||'fam'||fam.relativeid  AS "Family ID",
        CASE cas.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' 
        WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person Status",
        cas.firstname AS "First Name",
        cas.lastname AS "Last Name",
        CASE cas.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END  AS "Subscription State",
        cas.address1 AS "Street Address 1",
        cas.address2 AS "Street Address 2",
        cas.city AS "City",
        cas.zipcode AS "Zip",
        email.txtvalue as "Email",
        phone.txtvalue as "Phone",
        company.center||'p'||company.id as "Company ID",
        company.fullname as "Company",
        ca.name as "Company Agreement",
        company.address1 as "Company Address 1",
        company.address2 as "Company Address 2",
        company.zipcode as "Company Zip",
        company.city as "Company City",
        ass_staff.fullname AS  "Assigned Employee",
        cas.SUBSCRIPTION_STATE,
        cas.SUBSCRIPTION_SUB_STATE,
        (CASE
                WHEN ques.questionnaire_campaign_id IN (1001,1201) AND qa1.number_answer = 1 THEN '3-Day Window'
                WHEN ques.questionnaire_campaign_id IN (1001,1201) AND qa1.number_answer = 2 THEN '90-Day Cancel'
                WHEN ques.questionnaire_campaign_id IN (1001,1201) AND qa1.number_answer = 3 THEN 'Aged Out of Youth'
                WHEN ques.questionnaire_campaign_id IN (1001,1201) AND qa1.number_answer = 4 THEN 'Comp / Ex Employee'
                WHEN ques.questionnaire_campaign_id IN (1001,1201) AND qa1.number_answer = 5 THEN 'COVID-19'
                WHEN ques.questionnaire_campaign_id IN (1001,1201) AND qa1.number_answer = 6 THEN 'Dissatisfied'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 7 THEN 'Downgrade'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 8 THEN 'End of CP Team Season'		
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 9 THEN 'Financial / Bad Debt'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 10 THEN 'Lack of Use'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 11 THEN 'Left Programming'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 12 THEN 'Location / Inconvenient'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 13 THEN 'Medical'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 14 THEN 'MS Adjustment'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 15 THEN 'Non-renewed PIF'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 16 THEN 'Relocation'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 17 THEN 'Revoked / Banned'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 18 THEN 'Rate Increase'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 19 THEN 'Seasonal Member'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 20 THEN 'Upgrade'
                WHEN ques.questionnaire_campaign_id = 1201 AND qa1.number_answer = 21 THEN 'Other'
                WHEN ques.questionnaire_campaign_id = 1001 AND qa1.number_answer = 7 THEN 'End of CP Team Season'
                WHEN ques.questionnaire_campaign_id = 1001 AND qa1.number_answer = 8 THEN 'Financial / Bad Debt'
                WHEN ques.questionnaire_campaign_id = 1001 AND qa1.number_answer = 9 THEN 'Left Programming'
                WHEN ques.questionnaire_campaign_id = 1001 AND qa1.number_answer = 10 THEN 'Location / Inconvenient'
                WHEN ques.questionnaire_campaign_id = 1001 AND qa1.number_answer = 11 THEN 'Medical'
                WHEN ques.questionnaire_campaign_id = 1001 AND qa1.number_answer = 12 THEN 'Relocation'
                WHEN ques.questionnaire_campaign_id = 1001 AND qa1.number_answer = 13 THEN 'Revoked / Banned'
                WHEN ques.questionnaire_campaign_id = 1001 AND qa1.number_answer = 14 THEN 'Rate Increase'
                WHEN ques.questionnaire_campaign_id = 1001 AND qa1.number_answer = 15 THEN 'Seasonal Member'
                WHEN ques.questionnaire_campaign_id = 1001 AND qa1.number_answer = 16 THEN 'Other'		
                WHEN ques.questionnaire_campaign_id = 601 AND qa1.number_answer = 1 THEN 'Relocation'
                WHEN ques.questionnaire_campaign_id = 601 AND qa1.number_answer = 2 THEN 'Medical'
                WHEN ques.questionnaire_campaign_id = 601 AND qa1.number_answer = 3 THEN 'Financial / Bad Debt'
                WHEN ques.questionnaire_campaign_id = 601 AND qa1.number_answer = 4 THEN 'Inconvenient Location'
                WHEN ques.questionnaire_campaign_id = 601 AND qa1.number_answer = 5 THEN 'Not Enough Time'
                WHEN ques.questionnaire_campaign_id = 601 AND qa1.number_answer = 6 THEN 'Rate Increase'
                WHEN ques.questionnaire_campaign_id = 601 AND qa1.number_answer = 7 THEN 'Other'
                WHEN ques.questionnaire_campaign_id = 601 AND qa1.number_answer = 8 THEN 'Comp Cancellation'
                WHEN ques.questionnaire_campaign_id = 601 AND qa1.number_answer = 9 THEN 'Locker Cancellation'
                WHEN ques.questionnaire_campaign_id = 601 AND qa1.number_answer = 10 THEN 'Personal Training Cancellation'
                WHEN ques.questionnaire_campaign_id IS NULL THEN NULL
                ELSE 'ERROR'
             END) AS "Why is member leaving",
             qa2.text_answer AS "Other reason"
FROM PARAMS
JOIN cancelled_addons_and_subscriptions cas
        ON params.center_id = cas.personcenter 
LEFT JOIN person_ext_attrs email
        ON cas.personcenter = email.personcenter
        AND cas.personid = email.personid
        AND email.name = '_eClub_Email'
LEFT JOIN person_ext_attrs phone
        ON cas.personcenter = phone.personcenter
        AND cas.personid = phone.personid
        AND phone.name = '_eClub_PhoneSMS'
LEFT JOIN relatives r 
        ON r.center = cas.personcenter 
        AND r.id = cas.personid 
        AND r.rtype = 3  -- Company agreement
        AND r.status < 2
LEFT JOIN companyagreements ca 
        ON ca.center = r.relativecenter 
        AND ca.id = r.relativeid
        AND ca.subid = r.relativesubid	
LEFT JOIN persons company 
        ON company.center = ca.center 
        AND company.id = ca.id
LEFT JOIN relatives fam
        ON fam.center = cas.personcenter 
        AND fam.id = cas.personid
        AND r.rtype = 19 -- (family id)    
        AND r.status < 2
LEFT JOIN persons ass_staff
        ON ass_staff.center = cas.assigned_staff_center
        AND ass_staff.id = cas.assigned_staff_id
LEFT JOIN       
(
        SELECT
                rank() over (partition BY qa.center,qa.id ORDER BY qa.log_time DESC) AS rnk,
                qa.center,
                qa.id,
                qa.subid,
                qa.questionnaire_campaign_id
        FROM chelseapiers.questionnaire_answer qa
        WHERE 
                qa.questionnaire_campaign_id IN (601, 1001, 1201)
                AND qa.status = 'COMPLETED'
) ques
        ON ques.rnk = 1
        AND cas.personcenter = ques.center
        AND cas.personid = ques.id
LEFT JOIN chelseapiers.question_answer qa1
        ON qa1.answer_center = ques.center
        AND qa1.answer_id = ques.id
        AND qa1.answer_subid = ques.subid
        AND qa1.question_id = 1
LEFT JOIN chelseapiers.question_answer qa2
        ON qa2.answer_center = ques.center
        AND qa2.answer_id = ques.id
        AND qa2.answer_subid = ques.subid
        AND qa2.question_id = 2