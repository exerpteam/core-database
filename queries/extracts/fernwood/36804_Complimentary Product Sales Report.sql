-- The extract is extracted from Exerp on 2026-02-08
-- Shows all transactions for complimentary products within your specified date range and scope, including the employee who processed each transaction. 
WITH
params AS
(
    SELECT
        /*+ materialize */
        datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
        c.id AS CENTER_ID,
        CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
    FROM
        centers c
)
-- Subscription Sales for Complimentary Products
SELECT 
    c.shortname AS "Center Name",
    p.center || 'p' || p.id AS "Person ID",
    p.external_id AS "External ID",
    p.fullname AS "Member Name",
    'Subscription' AS "Transaction Type",
    prod.name AS "Product/Service Name",
    longtodatec(s.creation_time, p.center) AS "Transaction Date",
    CASE
        WHEN s.state = 2 THEN 'ACTIVE'
        WHEN s.state = 3 THEN 'ENDED'
        WHEN s.state = 4 THEN 'FROZEN'
        WHEN s.state = 7 THEN 'WINDOW'
        WHEN s.state = 8 THEN 'CREATED'
        ELSE 'UNKNOWN'
    END AS "Transaction Status",
    emp.center ||'emp'|| emp.id AS "Creator Employee ID",
    COALESCE(emps.center ||'emp'|| emps.id, emp.center ||'emp'|| emp.id) AS "Sales Employee ID",
    COALESCE(pes.fullname, pe.fullname) AS "Sales Employee Name",
    COALESCE(ss.price_period, sp.price) AS "Price Amount",
    CASE
        WHEN p.status = 0 THEN 'Lead'
        WHEN p.status = 1 THEN 'Active'
        WHEN p.status = 2 THEN 'Inactive'
        WHEN p.status = 3 THEN 'Temporary Inactive'
        WHEN p.status = 4 THEN 'Transferred'
        WHEN p.status = 5 THEN 'Duplicate'
        WHEN p.status = 6 THEN 'Prospect'
        WHEN p.status = 7 THEN 'Deleted'
        WHEN p.status = 8 THEN 'Anonymized'
        WHEN p.status = 9 THEN 'Contact'
        ELSE 'Unknown'
    END AS "Person Status",
    bi_decode_field('PERSONS', 'PERSONTYPE', p.persontype) AS "Person Type"
FROM
    subscriptions s        
JOIN
    subscriptiontypes st
    ON st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
JOIN
    products prod
    ON prod.center = st.center
    AND prod.id = st.id
JOIN
    product_and_product_group_link pgl
    ON pgl.product_center = prod.center  
    AND pgl.product_id = prod.id
JOIN
    product_group pg
    ON pg.id = pgl.product_group_id
    AND (LOWER(pg.name) LIKE '%complimentary%' OR pg.name = 'Complimentary Products')
JOIN
    persons p
    ON p.center = s.owner_center
    AND p.id = s.owner_id
JOIN
    centers c
    ON c.id = p.center
JOIN    
    employees emp
    ON emp.center = s.creator_center
    AND emp.id = s.creator_id
JOIN
    persons pe
    ON pe.center = emp.personcenter
    AND pe.id = emp.personid            
LEFT JOIN
    subscription_sales ss
    ON s.center = ss.subscription_center
    AND s.id = ss.subscription_id
LEFT JOIN     
    employees emps
    ON emps.center = ss.employee_center
    AND emps.id = ss.employee_id
LEFT JOIN
    persons pes
    ON pes.center = emps.personcenter
    AND pes.id = emps.personid
LEFT JOIN 
    person_ext_attrs peeaMobile
    ON peeaMobile.personcenter = p.center
    AND peeaMobile.personid = p.id
    AND peeaMobile.name = '_eClub_PhoneSMS' 
LEFT JOIN 
    person_ext_attrs peeaEmail
    ON peeaEmail.personcenter = p.center
    AND peeaEmail.personid = p.id
    AND peeaEmail.name = '_eClub_Email'
LEFT JOIN
    subscription_price sp
    ON sp.subscription_center = s.center
    AND sp.subscription_id = s.id
    AND s.start_date > sp.from_date
    AND (s.start_date < sp.to_date OR sp.to_date IS NULL)
JOIN 
    params 
    ON params.CENTER_ID = s.center  
WHERE 
    s.creation_time BETWEEN params.FromDate AND params.ToDate 
    AND s.center IN (:Scope)

UNION ALL

-- Clipcard Sales for Complimentary Products
SELECT
    c.shortname AS "Center Name",
    p.center ||'p'|| p.id AS "Person ID",
    p.external_id AS "External ID",
    p.fullname AS "Member Name",
    'Clipcard' AS "Transaction Type",
    prod.name AS "Product/Service Name",
    longtodatec(inv.trans_time, inv.center) AS "Transaction Date",
    CASE
        WHEN cc.cancelled = true THEN 'CANCELLED'
        WHEN cc.blocked = true THEN 'BLOCKED'
        ELSE 'ACTIVE'
    END AS "Transaction Status",
    emp.center ||'emp'|| emp.id AS "Creator Employee ID",
    COALESCE(emps.center ||'emp'|| emps.id, emp.center ||'emp'|| emp.id) AS "Sales Employee ID",
    COALESCE(pemps.fullname, pemp.fullname) AS "Sales Employee Name",
    invl.total_amount AS "Price Amount",
    CASE
        WHEN p.status = 0 THEN 'Lead'
        WHEN p.status = 1 THEN 'Active'
        WHEN p.status = 2 THEN 'Inactive'
        WHEN p.status = 3 THEN 'Temporary Inactive'
        WHEN p.status = 4 THEN 'Transferred'
        WHEN p.status = 5 THEN 'Duplicate'
        WHEN p.status = 6 THEN 'Prospect'
        WHEN p.status = 7 THEN 'Deleted'
        WHEN p.status = 8 THEN 'Anonymized'
        WHEN p.status = 9 THEN 'Contact'
        ELSE 'Unknown'
    END AS "Person Status",
    bi_decode_field('PERSONS', 'PERSONTYPE', p.persontype) AS "Person Type"
FROM
    clipcards cc 
JOIN
    persons p
    ON p.center = cc.owner_center
    AND p.id = cc.owner_id
JOIN 
    products prod 
    ON prod.center = cc.center
    AND prod.id = cc.id
JOIN
    product_and_product_group_link pgl
    ON pgl.product_center = prod.center  
    AND pgl.product_id = prod.id
JOIN
    product_group pg
    ON pg.id = pgl.product_group_id
    AND (LOWER(pg.name) LIKE '%complimentary%' OR pg.name = 'Complimentary Products')
JOIN                                                 
    invoices inv
    ON inv.center = cc.invoiceline_center
    AND inv.id = cc.invoiceline_id								
JOIN
    invoice_lines_mt invl
    ON cc.invoiceline_center = invl.center
    AND cc.invoiceline_id = invl.id
    AND cc.invoiceline_subid = invl.subid                                     
JOIN
    employees emp
    ON emp.center = inv.employee_center
    AND emp.id = inv.employee_id
JOIN
    persons pemp
    ON pemp.center = emp.personcenter
    AND pemp.id = emp.personid
LEFT JOIN
    invoice_sales_employee ise
    ON ise.invoice_center = inv.center
    AND ise.invoice_id = inv.id
LEFT JOIN
    employees emps
    ON emps.center = ise.sales_employee_center
    AND emps.id = ise.sales_employee_id
LEFT JOIN
    persons pemps
    ON pemps.center = emps.personcenter
    AND pemps.id = emps.personid
JOIN
    centers c
    ON c.id = p.center
LEFT JOIN
    person_ext_attrs peeaMobile
    ON peeaMobile.personcenter = p.center
    AND peeaMobile.personid = p.id
    AND peeaMobile.name = '_eClub_PhoneSMS'
LEFT JOIN
    person_ext_attrs peeaEmail
    ON peeaEmail.personcenter = p.center
    AND peeaEmail.personid = p.id
    AND peeaEmail.name = '_eClub_Email'
JOIN 
    params 
    ON params.CENTER_ID = p.center
WHERE 
    inv.trans_time BETWEEN params.FromDate AND params.ToDate 
    AND p.center IN (:Scope)
    AND (inv.paysessionid IS NOT NULL OR inv.employee_center||'emp'||inv.employee_id IN ('100emp2202', '100emp409'))

ORDER BY "Transaction Date" DESC, "Center Name", "Member Name"