WITH
params AS
        (
                SELECT
                        /*+ materialize */
                        datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                        c.id AS CENTER_ID,
                        CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
                FROM
                        centers c
        )
SELECT 
        longtodatec(s.creation_time,s.center) AS "Date"
        ,inv.coment AS "Receipt Number"
        ,inv.payer_center||'p'|| inv.payer_id AS "Exerp ID"
        ,c.name AS "Location"
        ,per.fullname AS "Member Name"
        ,inv.amount AS "Amount"
        ,'Online Join' AS "Purchase Type" -- 'Online Join', 'Online Shop', 'Debt Payment'
        ,p.name AS "Purchase information"
        ,email.txtvalue AS "Email"
FROM
        fernwood.subscription_sales ss
JOIN
        fernwood.subscriptiontypes st
        ON st.center = ss.subscription_type_center 
        AND st.id = ss.subscription_type_id
JOIN
        fernwood.subscriptions s
        ON s.center = ss.subscription_center
        AND s.id = ss.subscription_id       
JOIN
        fernwood.products p
        ON p.center = st.center
        AND p.id = st.id              
JOIN        
        (
        SELECT 
                inv.center
                ,inv.id
                ,crt.coment
                ,sum(invl.total_amount) AS amount
                ,inv.payer_center
                ,inv.payer_id
        FROM                
                fernwood.invoices inv
        JOIN
                fernwood.invoice_lines_mt invl
                ON inv.center = invl.center
                AND inv.id = invl.id  
        LEFT JOIN
                fernwood.cashregistertransactions crt
                ON inv.paysessionid = crt.paysessionid
                AND inv.cashregister_center = crt.center
                AND inv.cashregister_id = crt.id         
        WHERE
                inv.employee_center = 100
                AND
                inv.employee_id = 19603
                AND
                invl.reason = 30 
        GROUP BY
                inv.center
                ,inv.id
                ,inv.payer_center
                ,inv.payer_id 
                ,crt.coment               
        )inv
        ON inv.center = s.invoiceline_center
        AND inv.id = s.invoiceline_id
JOIN
        fernwood.centers c
        ON c.id = inv.center   
JOIN
        fernwood.persons per
        ON per.center = inv.payer_center
        AND per.id = inv.payer_id
LEFT JOIN 
        fernwood.person_ext_attrs email
        ON email.personcenter = per.center
        AND email.personid = per.id 
        AND email.name = '_eClub_Email'  
JOIN    
        params
        ON params.center_id = c.id
WHERE
        ss.employee_center = 100
        AND
        ss.employee_id = 19603 
        AND
        s.creation_time BETWEEN params.FromDate AND ToDate 
UNION ALL
SELECT
        longtodatec(inv.trans_time,inv.center) AS "Date"
        ,crt.coment AS "Receipt Number"
        ,inv.payer_center||'p'|| inv.payer_id AS "Exerp ID"
        ,c.name AS "Location"
        ,per.fullname AS "Member Name"
        ,invl.total_amount AS "Amount"
        ,'Online Shop' AS "Purchase Type" -- 'Online Join', 'Online Shop', 'Debt Payment'
        ,invl.text AS "Purchase information"
        ,email.txtvalue AS "Email"
FROM
        fernwood.invoices inv
JOIN
        fernwood.invoice_lines_mt invl
        ON inv.center = invl.center
        AND inv.id = invl.id
JOIN
        fernwood.centers c
        ON c.id = inv.center
JOIN
        fernwood.persons per
        ON per.center = inv.payer_center
        AND per.id = inv.payer_id   
LEFT JOIN 
        fernwood.person_ext_attrs email
        ON email.personcenter = per.center
        AND email.personid = per.id 
        AND email.name = '_eClub_Email' 
LEFT JOIN
        fernwood.cashregistertransactions crt
        ON inv.paysessionid = crt.paysessionid
        AND inv.cashregister_center = crt.center
        AND inv.cashregister_id = crt.id            
JOIN
        params
        ON params.center_id = c.id                                   
WHERE
        inv.employee_center = 100
        AND
        inv.employee_id = 19603
        AND 
        invl.reason = 31
        AND
        invl.total_amount != 0  
        AND
        inv.trans_time BETWEEN params.FromDate AND ToDate    
UNION ALL
SELECT 
        longtodatec(art.trans_time,art.center) AS "Date"
        ,art.info AS "Receipt Number"
        ,per.center||'p'|| per.id AS "Exerp ID"
        ,c.name AS "Location"
        ,per.fullname AS "Member Name"
        ,art.amount AS "Amount"
        ,'Debt Payment' AS "Purchase Type" -- 'Online Join', 'Online Shop', 'Debt Payment'
        ,'Debt Payment' AS "Purchase information"
        ,email.txtvalue AS "Email"
FROM
        fernwood.ar_trans art
JOIN
        fernwood.account_trans act
        ON act.center = art.ref_center
        AND act.id = art.ref_id
        AND act.subid = art.ref_subid
JOIN
        fernwood.account_receivables ar
        ON ar.center = art.center
        AND ar.id = art.id
JOIN
        fernwood.persons per
        ON per.center = ar.customercenter
        AND per.id = ar.customerid  
LEFT JOIN 
        fernwood.person_ext_attrs email
        ON email.personcenter = per.center
        AND email.personid = per.id 
        AND email.name = '_eClub_Email'  
JOIN
        fernwood.centers c
        ON c.id = art.center  
JOIN
        params
        ON params.center_id = c.id                                          
WHERE   
        art.employeecenter = 100
        AND
        art.employeeid = 19603 
        AND
        art.ref_type = 'ACCOUNT_TRANS'
        AND
        art.amount > 0   
        AND
        art.trans_time BETWEEN params.FromDate AND ToDate                                         