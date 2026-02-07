WITH
    params AS materialized
    (
        SELECT
            id                                                                     AS center_id,
            CAST(datetolongc(TO_CHAR(to_date(:From_Sale_Date,'YYYY-MM-DD'),'YYYY-MM-DD'),id) AS BIGINT) AS from_Date_ts,
            CAST(datetolongc(TO_CHAR(to_date(:To_Sale_Date,'YYYY-MM-DD'),'YYYY-MM-DD'),id) AS BIGINT) + 24*3600*1000 AS  to_date_ts,
            CAST(:From_Sale_Date AS DATE) AS from_sale_date,
            CAST(:To_Sale_Date AS DATE) to_sale_date   
        FROM
            centers
        WHERE 
            id in (:Scope)            
    ),
base_list as
(    
SELECT
    p.center,
    p.id,
    p.external_id          AS "External ID",
    p.center||'p'||p.id    AS "Member ID",
    p.fullname             AS "Member Name",
    CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS "Person Type",    
    TO_CHAR(longtodateC(je.creation_time, p.center),'MM/DD/YYYY')  AS "Contract Creation Date",
    je.ref_center||'ss'||je.ref_id   AS "Subscription ID",
    CASE WHEN jes.signature_center IS null 
         THEN 'No'
         ELSE 'Yes'
    END AS "Contract Signed", 
    TO_CHAR(longtodateC(si.creation_time, si.center),'MM/DD/YYYY') AS "Signature Date",
    TO_CHAR(s.start_date,'MM/DD/YYYY')                             AS "Start Date",
    TO_CHAR(ss.sales_date ,'MM/DD/YYYY')                           AS "Sale Date",
    pr.name        AS "Subscription Name",
    pg.name        AS "Primary Product Group",
    co.fullname    AS "Company Name",
    ca.name        AS "Company Aggrement",
    pe1.fullname   AS "Sales Associate",
    pe2.fullname   AS "Assigned Associate",
    COALESCE(op.center, p.center) ||'p'|| COALESCE(op.id,p.id) AS  "Payer"
FROM
    params
JOIN
    SUBSCRIPTIONS s
ON 
    params.center_id = s.center
JOIN
    subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
AND st.st_type < 2 -- only EFT CASH
JOIN
    products pr
ON
    st.center = pr.center
AND st.id = pr.id
JOIN
    SUBSCRIPTION_SALES ss
ON
    s.CENTER = ss.SUBSCRIPTION_CENTER
AND s.ID = ss.SUBSCRIPTION_ID
JOIN
    persons p
ON
    p.center = s.owner_center
AND p.id = s.owner_id
LEFT JOIN    
    journalentries je
ON
je.person_center = p.center
AND je.person_id = p.id    
AND je.ref_center = s.center
AND je.ref_id = s.id  
AND je.jetype = 1 -- Contracts
LEFT JOIN
    PERSONS P2
ON
    s.owner_center = P2.CENTER
AND s.owner_id = P2.ID
LEFT JOIN
    product_group pg
ON
    pr.primary_product_group_id = pg.id    
LEFT JOIN
    journalentry_signatures jes
ON
    je.id = jes.journalentry_id
LEFT JOIN
    signatures si
ON
    jes.signature_center = si.center
AND jes.signature_id = si.id
LEFT JOIN
    relatives rel
ON 
    rel.center = p.center
    AND rel.id = p.id
    AND rel.rtype = 3
    AND rel.status < 2
LEFT JOIN
    persons co
ON
    rel.relativecenter = co.center
    AND rel.relativeid = co.id
LEFT JOIN
     companyagreements ca
ON
     ca.center =  rel.relativecenter
     AND  ca.id =  rel.relativeid
     AND  ca.subid =  rel.relativesubid
LEFT JOIN
    EMPLOYEES emp
ON
    emp.CENTER = ss.EMPLOYEE_CENTER
AND emp.ID = ss.EMPLOYEE_ID
LEFT JOIN
     employees sae
ON
     s.creator_center = sae.center
     AND s.creator_id = sae.id
LEFT JOIN 
     persons pe1
ON 
     sae.personcenter = pe1.center
     AND sae.personid = pe1.id               
LEFT JOIN 
     persons pe2
ON 
     s.assigned_staff_center = pe2.center
     AND s.assigned_staff_id = pe2.id      
LEFT JOIN
     relatives op
ON 
    op.relativecenter = p.center
    AND op.relativeid = p.id
    AND op.rtype = 12 -- other payer
    AND op.status < 2             
WHERE
    ss.subscription_center IN (:Scope)
AND ss.SALES_DATE >= params.from_sale_date
AND ss.SALES_DATE <= params.to_sale_date
AND ss.TYPE = 1 -- only new ones
AND st.st_type < 2 -- only EFT & Cash
AND p.persontype <> 2  -- exclude staff
AND pg.id NOT IN (1003, 1604) -- not Complimentary Memberships, Trials
)
SELECT
        "Member ID",
        "External ID",
        "Member Name",
        "Person Type",
        "Contract Creation Date",
        "Subscription ID",
        "Contract Signed",
        "Signature Date",
        "Start Date",
        "Sale Date",
        "Subscription Name",
        "Primary Product Group",
        "Company Name",
        "Company Aggrement",
        "Sales Associate",
        "Assigned Associate",
        "Payer",
        STRING_AGG(discounts.name, ', ') AS "Discounts"
FROM 
   base_list b
LEFT JOIN 
   person_ext_attrs discounts
ON           
    b.center = discounts.personcenter
    AND b.id = discounts.personid
    AND 
  (discounts.name ilike '%masters%'
        or discounts.name ilike '%military%'
        or discounts.name ilike '%permier%'
        or discounts.name ilike '%student%'
        or discounts.name ilike '%travel%'
        or discounts.name ilike '%aupair%'
        or discounts.name ilike '%employeefriends%')        
   AND discounts.txtvalue = 'true'  
GROUP BY 
        "Member ID",
        "External ID",
        "Member Name",
        "Person Type",
        "Contract Creation Date",
        "Subscription ID",
        "Contract Signed",
        "Signature Date",
        "Start Date",
        "Sale Date",
        "Subscription Name",
        "Primary Product Group",
        "Company Name",
        "Company Aggrement",
        "Sales Associate",
        "Assigned Associate",
        "Payer"
ORDER BY
        "Payer"