WITH params AS MATERIALIZED
(
        SELECT 
                EXTRACT('MONTH' FROM TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) AS current_month,
                CAST(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '1 months') - interval '1 days' AS DATE) AS end_of_month,
                (CASE
                         WHEN EXTRACT('MONTH' FROM TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) = 1 THEN
                                TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') 
                         ELSE
                                CAST(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '1 months') AS DATE)
                END) AS next_deduction_date,
                (CASE
                         WHEN EXTRACT('MONTH' FROM TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) = 1 THEN
                                CAST(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '1 months') AS DATE) 
                         ELSE
                                CAST(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) AS DATE)
                END) AS last_billing_period_start,
                (CASE
                         WHEN EXTRACT('MONTH' FROM TO_DATE(getCenterTime(c.id),'YYYY-MM-DD')) = 1 THEN
                                CAST(TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') - interval '1 days' AS DATE)
                         ELSE
                                CAST(DATE_TRUNC('month',TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + interval '1 months') - interval '1 days' AS DATE)
                END) AS last_billing_period_end,
                c.id AS center_id,
                c.name AS center_name
        FROM chelseapiers.centers c
),
list_subs AS
(
        SELECT
            (CASE
                WHEN sub.billed_until_date = sub.end_date THEN
                        NULL
                WHEN sub.billed_until_date > par.end_of_month AND EXTRACT('MONTH' FROM sub.billed_until_date) = EXTRACT('MONTH' FROM sub.billed_until_date + interval '1 day') THEN
                         CAST(DATE_TRUNC('month',sub.billed_until_date) AS DATE)
                WHEN sub.billed_until_date > par.end_of_month AND EXTRACT('MONTH' FROM sub.billed_until_date) != EXTRACT('MONTH' FROM sub.billed_until_date + interval '1 day') THEN
                        CAST(sub.billed_until_date + interval '1 day' AS DATE)
                WHEN sub.start_date <= par.end_of_month THEN
                        CAST(par.end_of_month + interval '1 day' AS DATE)
                WHEN sub.start_date > par.end_of_month THEN
                        CAST(DATE_TRUNC('month',sub.start_date) AS DATE)
                ELSE 
                        NULL
            END) AS nextDeductionDate,
            pd.name as sub_name,
            sub.center,
            sub.id,
            sub.owner_center,
            sub.owner_id,
            sub.assigned_staff_center,
            sub.assigned_staff_id,
            sub.subscription_price,
            sub.start_date,
            sub.end_date,
            sub.state,
            add_months(to_date(TO_CHAR(longtodateC(FLOOR(extract(epoch FROM now())*1000),sub.center), 'YYYY-MM-DD'), 'YYYY-MM-DD'), 1) AS l,
            fpr.price                           AS freeze_product_price,
            par.center_name,
            p_sales.fullname                           AS Assigned_employee_name,
            p_sales.center||'p'||p_sales.id            AS Assigned_employee_Id
        FROM subscriptions sub
        JOIN params par ON sub.center = par.center_id
        JOIN products pd
                ON pd.center = sub.subscriptiontype_center
                AND pd.id = sub.subscriptiontype_id
        JOIN subscriptiontypes st
                ON st.center = pd.center
                AND st.id = pd.id
        JOIN persons p_sales
                ON p_sales.center = sub.assigned_staff_center
                AND p_sales.id = sub.assigned_staff_id
        LEFT JOIN chelseapiers.products fpr
                ON fpr.center = st.freezeperiodproduct_center
                AND fpr.id = st.freezeperiodproduct_id
        WHERE
                sub.state IN (2,4,8)
                AND sub.center IN (:Scope)
                AND st.st_type > 0 
),

previous_billing AS
(
        SELECT
                ls.center || 'ss' || ls.id,
                ls.center,
                ls.id,
                SUM(il.net_amount) as previous_amount            
        FROM list_subs ls
        JOIN params par ON par.center_id = ls.center
        JOIN chelseapiers.subscriptionperiodparts spp ON ls.center = spp.center AND ls.id = spp.id
        JOIN chelseapiers.spp_invoicelines_link sppl ON spp.center = sppl.period_center AND spp.id = sppl.period_id AND spp.subid = sppl.period_subid
        JOIN chelseapiers.invoice_lines_mt il ON il.center = sppl.invoiceline_center AND il.id = sppl.invoiceline_id AND il.subid = sppl.invoiceline_subid
        WHERE
                spp.cancellation_time = 0
                AND spp.from_date >= par.last_billing_period_start
                AND spp.to_date <= par.last_billing_period_end
        GROUP BY
                ls.center,
                ls.id
),
subscription_price AS
(
        SELECT
                ls.center,
                ls.id,
                sp.price          
        FROM list_subs ls
        JOIN params par ON par.center_id = ls.center
        JOIN subscription_price sp
                ON sp.subscription_center = ls.center
                AND sp.subscription_id = ls.id
                AND sp.from_date <= ls.nextDeductionDate
                AND 
                (
                        sp.to_date IS NULL
                        OR  
                        sp.to_date >= ls.nextDeductionDate
                )
                AND sp.cancelled = false      
)              

SELECT DISTINCT
    ls.center_name                                                AS "Club Name",
    p.center||'p'||p.id                                          AS "Person ID",
    p.firstname                                                  AS "First Name",
    p.lastname                                                   AS "Last Name",
    TO_CHAR(p.first_active_start_date,'MM-DD-YYYY')                                    AS "Member Since Date",
    TO_CHAR(p.birthdate,'MM-DD-YYYY')                            AS "Birth Date",
    CAST(EXTRACT( YEAR FROM (AGE(now(),p.birthdate)))AS INTEGER) AS "Age",
    CASE
        WHEN p.PERSONTYPE = 0
        THEN 'PRIVATE'
        WHEN p.PERSONTYPE = 1
        THEN 'STUDENT'
        WHEN p.PERSONTYPE = 2
        THEN 'STAFF'
        WHEN p.PERSONTYPE = 3
        THEN 'FRIEND'
        WHEN p.PERSONTYPE = 4
        THEN 'CORPORATE'
        WHEN p.PERSONTYPE = 5
        THEN 'ONEMANCORPORATE'
        WHEN p.PERSONTYPE = 6
        THEN 'FAMILY'
        WHEN p.PERSONTYPE = 7
        THEN 'SENIOR'
        WHEN p.PERSONTYPE = 8
        THEN 'GUEST'
        WHEN p.PERSONTYPE = 9
        THEN 'CHILD'
        WHEN p.PERSONTYPE = 10
        THEN 'EXTERNAL_STAFF'
        ELSE 'Undefined'
    END AS "Person Type",
    CASE
        WHEN p.STATUS = 0
        THEN 'LEAD'
        WHEN p.STATUS = 1
        THEN 'ACTIVE'
        WHEN p.STATUS = 2
        THEN 'INACTIVE'
        WHEN p.STATUS = 3
        THEN 'FREEZE'
        WHEN p.STATUS = 4
        THEN 'TRANSFERRED'
        WHEN p.STATUS = 5
        THEN 'DUPLICATE'
        WHEN p.STATUS = 6
        THEN 'PROSPECT'
        WHEN p.STATUS = 7
        THEN 'DELETED'
        WHEN p.STATUS = 8
        THEN 'ANONYMIZED'
        WHEN p.STATUS = 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END                                 AS "Person Status",
    ls.center || 'ss' || ls.id          AS "Agreement ID",
    ls.sub_name                         AS "Agreement Name",
    TO_CHAR(ls.start_date,'MM-DD-YYYY') AS "Start Date",
    TO_CHAR(ls.end_date,'MM-DD-YYYY')   AS "Cancel Date",
    ls.subscription_price               AS "Key Item Price",
    CASE
        WHEN ls.state = 1
        THEN 'Awaiting activation'
        WHEN ls.state = 2
        THEN 'Active'
        WHEN ls.state = 3
        THEN 'Ended'
        WHEN ls.state = 4
        THEN 'Frozen'
        WHEN ls.state = 5
        THEN 'Cancelled'
        WHEN ls.state = 6
        THEN 'Not paid'
        WHEN ls.state = 7
        THEN 'Window'
        WHEN ls.state = 8
        THEN 'Created'
        WHEN ls.state = 9
        THEN 'Ended transferred'
        WHEN ls.state = 10
        THEN 'Created transferred'
    END AS "Agreement State",
    pb.previous_amount AS "Previous Billing",
    (CASE
        WHEN srp.id IS NOT NULL THEN
                0.00
        WHEN sfp.id IS NOT NULL AND sfp.type = 'UNRESTRICTED' THEN 
                0.00
        WHEN sfp.id IS NOT NULL THEN
                ls.freeze_product_price
        ELSE 
                sp.price
    END)                                        AS "Price (Next deduction)",
    TO_CHAR(ls.nextDeductionDate,'MM-DD-YYYY') AS "Next Deduction Date",
    TO_CHAR(ls.end_date,'MM-DD-YYYY')         AS "Termination Date",
    ls.Assigned_employee_name                           AS "Assigned employee (Name)",
    ls.Assigned_employee_id           AS "Assigned employee (Id)",
    company.fullname                           AS "Company",
    email.txtvalue                             AS "Email Address",
    phone.txtvalue                             AS "Phone",
    p.address1                                 AS "Street Address",
    p.address2                                 AS "Street Address 2",
    p.zipcode                                  AS "Postal Code",
    p.city                                     AS "City"
FROM list_subs ls
JOIN persons p
        ON p.center = ls.owner_center
        AND p.id = ls.owner_id   
LEFT JOIN subscription_price sp
        ON ls.center = sp.center
        AND ls.id = sp.id
LEFT JOIN chelseapiers.subscription_freeze_period sfp
        ON sfp.subscription_center = ls.center
        AND sfp.subscription_id = ls.id
        AND sfp.cancel_time IS NULL
        AND sfp.start_date <=ls.nextDeductionDate
        AND sfp.end_date > ls.nextDeductionDate
        AND sfp.state IN ('ACTIVE')
LEFT JOIN chelseapiers.subscription_reduced_period srp
        ON srp.subscription_center = ls.center
        AND srp.subscription_id = ls.id
        AND srp.cancel_time IS NULL
        AND srp.start_date <=ls.nextDeductionDate
        AND srp.end_date > ls.nextDeductionDate
        AND srp.type NOT IN ('FREEZE')
        AND srp.state IN ('ACTIVE')
LEFT JOIN chelseapiers.person_ext_attrs email
        ON p.center = email.personcenter
        AND p.id = email.personid
        AND email.name = '_eClub_Email'
LEFT JOIN chelseapiers.person_ext_attrs phone
        ON p.center = phone.personcenter
        AND p.id = phone.personid
        AND phone.name = '_eClub_PhoneSMS'
LEFT JOIN chelseapiers.relatives r
        ON r.center = p.center
        AND r.id = p.id
        AND r.rtype = 3
LEFT JOIN chelseapiers.persons company
        ON company.center = r.relativecenter
        AND company.id = r.relativeid
LEFT JOIN previous_billing pb
        ON pb.center = ls.center
        AND pb.id = ls.id
WHERE
        --(
        --        ls.end_date IS NULL
        --        OR  
        --        ls.end_date >= ls.nextDeductionDate
        --)
        --AND 
        --ls.nextDeductionDate <= add_months(to_date(TO_CHAR(longtodateC(FLOOR(extract(epoch FROM now())*1000),ls.center), 'YYYY-MM-DD'), 'YYYY-MM-DD'), 1)
        --AND 
        p.STATUS NOT IN (4,5,7,8)
ORDER BY
    1,
    3