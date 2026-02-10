-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        ar.customercenter||'p'||ar.customerid personid,
        longtodatec(art.trans_time,art.center) as trans_date,
        art.amount
FROM ar_trans art
JOIN account_receivables ar ON ar.center = art.center AND ar.id = art.id 
JOIN persons p ON ar.customercenter = p.center AND ar.customerid = p.id AND p.sex != 'C'
WHERE
        art.text like '%(Auto Renewal)' 
        AND art.status = 'NEW'
        AND art.due_date IS NULL