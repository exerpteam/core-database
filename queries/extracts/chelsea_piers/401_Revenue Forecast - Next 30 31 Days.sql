SELECT distinct
    c.id          AS "Club Id",
    c.name        AS "Club Name",
    p.center||'p'||p.id AS "Person ID",
    P.FULLNAME    AS "MEMBER_FULLNAME",
    s1.name       AS "Product Description",
    --to_char(sp.price,'FM999990.00') as "Price (Next deduction)",
    sp.price                    AS "Price (Next deduction)",
    s1.individual_deduction_day AS "Assessment Day of Month",
    s1.nextDeductionDate        AS "Next Deduction Date",
    s1.end_date                 AS "Termination Date",
    p_sales.fullname            AS "Assigned employee (Name)",
    p_sales.center||'p'||p_sales.id         AS "Assigned employee (Id)",    
    subs.center||'ss'||subs.id as "Subscripton ID",
    CASE
    WHEN s1.state = 1
    then 'Awaiting activation'
    when s1.state = 2
    then 'Active'
    when s1.state = 3
    then 'Ended'
    when s1.state = 4
    then 'Frozen'
    when s1.state = 5
    then 'Cancelled'
    when s1.state = 6
    then 'Not paid'
    when s1.state = 7
    then 'Window'
    when s1.state = 8
    then 'Created'
    when s1.state = 9
    then 'Ended transferred'
    when s1.state = 10
    then 'Created transferred'
    end as "Subscription State",
    payment_agreement_ref as "Payment Agreement Ref"
    
FROM
    (
        SELECT
            CASE
                  
                WHEN sub.billed_until_date IS NULL
                THEN sub.start_date
                 
                WHEN sub.billed_until_date <= (add_months(to_date(TO_CHAR(longtodateC(FLOOR(extract
                    (epoch FROM now())*1000),sub.center), 'YYYY-MM-DD'), 'YYYY-MM-DD'), 1) - 1)
                THEN sub.billed_until_date + 1                  
                ELSE add_months(sub.billed_until_date, -1) + 1
            END AS nextDeductionDate,
            pd.name,
            sub.*,
            pag.ref as payment_agreement_ref,
            case when pag.individual_deduction_day is null then 1 else individual_deduction_day end as individual_deduction_day,
            add_months(to_date(TO_CHAR(longtodateC(FLOOR(extract(epoch FROM now())*1000),sub.center
            ), 'YYYY-MM-DD'), 'YYYY-MM-DD'), 1) AS l
        FROM
           subscriptions sub
        -- link to the eventual other payer    
        LEFT JOIN relatives rel on rel.relativecenter = sub.owner_center and rel.relativeid = sub.owner_id and rel.status < 3 and rel.rtype = 12    
        -- find the payment account of the member or its payer
        LEFT JOIN account_receivables ar on 
        (
        ( rel.center is null and ar.customercenter = sub.owner_center and ar.customerid = sub.owner_id and ar.ar_type = 4 and ar.state = 0)
        or
        ( rel.center is not null and ar.customercenter = rel.center and ar.customerid = rel.id and ar.ar_type = 4 and ar.state = 0)
        )
        LEFT JOIN chelseapiers.payment_accounts pac on pac.center = ar.center and pac.id = ar.id     
        -- link to the agreements on the subcription (if any) or the default agreement of the payer found above   
        LEFT JOIN
            payment_agreements pag
        ON
            ((sub.payment_agreement_center is not null and
            pag.center = sub.payment_agreement_center
        AND pag.id = sub.payment_agreement_id
        AND pag.subid = sub.payment_agreement_subid) or (
            sub.payment_agreement_center is null and
            pag.center = pac.active_agr_center
        AND pag.id = pac.active_agr_id
        AND pag.subid = pac.active_agr_subid
        ))
        
        
        
        JOIN
            products pd
        ON
            pd.center = sub.subscriptiontype_center
        AND pd.id = sub.subscriptiontype_id
        JOIN
            subscriptiontypes st
        ON
            st.center = pd.center
        AND st.id = pd.id
        WHERE
            sub.state IN (2,4,8)
          AND sub.center IN (:Scope)
        AND st.st_type > 0 ) s1
JOIN
    persons p
ON
    p.center = s1.owner_center
AND p.id = s1.owner_id
LEFT JOIN
    person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
JOIN
    centers c
ON
    s1.center = c.id
JOIN
    subscription_price sp
ON
    sp.subscription_center = s1.center
AND sp.subscription_id = s1.id
AND sp.from_date <= s1.nextDeductionDate
AND (
        sp.to_date IS NULL
    OR  sp.to_date >= s1.nextDeductionDate)
AND sp.cancelled = false   
JOIN
    persons p_sales
ON
    p_sales.center = s1.assigned_staff_center
AND p_sales.id = s1.assigned_staff_id
JOIN subscriptions subs on subs.center = sp.subscription_center and subs.id = sp.subscription_id
WHERE
    (
        s1.end_date IS NULL
    OR  s1.end_date >= s1.nextDeductionDate)
AND s1.nextDeductionDate <= add_months(to_date(TO_CHAR(longtodateC(FLOOR(extract(epoch FROM now())*
    1000),s1.center), 'YYYY-MM-DD'), 'YYYY-MM-DD'), 1)
    --and pag.individual_deduction_day in (2,3,4)
ORDER BY
    1,
    s1.nextDeductionDate,
    3


