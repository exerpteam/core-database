-- The extract is extracted from Exerp on 2026-02-08
-- List of members who have an existing instalment plan
SELECT
        t.*
FROM
        (                
                SELECT
                                t1.person_center ||'p'|| t1.person_id AS "Person ID"
                                ,t1."Old System ID"
                                ,t1."Installment Plan"
                                ,t1."Installment"
                                ,t1."Installment Type"
                                ,t1."Total Original Installment amount"
                                ,t1."Creation Date"
                                ,t1."Installment End Date"
                                ,t1.installements_count 
                                ,t1."Installment Plan Account Balance"
                                ,t1."Installment ID"
                                ,t1."External ID"
                                ,t1."Start Date"
                                ,sum(artb.amount) AS "Installemnt Plan open balance"
                FROM
                        (                
                        SELECT DISTINCT
                                ip.person_center 
                                ,ip.person_id
                                ,CASE
                                        WHEN ipc.installment_plan_type = 'SUBSCRIPTION' THEN sub.name||' - '|| ipc.name
                                        WHEN ipc.installment_plan_type = 'CLIPCARD' THEN cc.name||' - '|| ipc.name
                                        WHEN ipc.installment_plan_type = 'DEBT' THEN 'Installment Plan for '|| ipc.name 
                                END AS "Installment Plan"
                                ,pea.txtvalue AS "Old System ID"
                                ,ipc.name AS "Installment"
                                ,ipc.installment_plan_type "Installment Type"
                                ,ip.amount AS "Total Original Installment amount"
                                ,TO_CHAR(longtodateC(ip.creation_time,ip.person_center),'YYYY-MM-DD HH24:MI') AS "Creation Date"
                                ,ip.end_date AS "Installment End Date"
                                ,ip.installements_count 
                                ,ar.balance AS "Installment Plan Account Balance"
                                ,ip.id AS "Installment ID"
                                ,p.external_id AS "External ID"
                                ,min(art.due_date) AS "Start Date"
                                ,ar.center
                                ,ar.id
                        FROM 
                                installment_plans ip
                        JOIN
                                installment_plan_configs ipc
                                ON ipc.id = ip.ip_config_id
                        LEFT JOIN
                                person_ext_attrs pea
                                ON pea.personcenter = ip.person_center
                                AND pea.personid = ip.person_id 
                                AND pea.name = '_eClub_OldSystemPersonId' 
                        LEFT JOIN
                                account_receivables ar
                                ON ar.customercenter = ip.person_center
                                AND ar.customerid = ip.person_id 
                                AND ar.ar_type = 6
                        JOIN
                                persons p
                                ON p.center = ip.person_center
                                AND p.id = ip.person_id 
                        LEFT JOIN
                                ar_trans art   
                                ON art.center = ar.center    
                                AND art.id = ar.id
                                AND ip.id = art.installment_plan_id
                        LEFT JOIN 
                                (SELECT
                                        prod.name
                                        ,s.installment_plan_id
                                        ,s.owner_center
                                        ,s.owner_id
                                FROM
                                        subscriptions s
                                JOIN
                                        subscriptiontypes st
                                        ON st.center = s.subscriptiontype_center
                                        AND st.ID = s.subscriptiontype_id
                                JOIN
                                        products prod
                                        ON prod.center = st.center
                                        AND prod.id = st.id
                                )sub
                                        ON sub.installment_plan_id = ip.id
                                        AND sub.owner_center = p.center
                                        AND sub.owner_id = p.id
                LEFT JOIN
                                (SELECT 
                                        prod.name
                                        ,cc.owner_center
                                        ,cc.owner_id
                                        ,inl.installment_plan_id         
                                FROM
                                        clipcards cc
                                JOIN 
                                        products prod 
                                        ON prod.center = cc.center
                                        AND prod.id = cc.ID
                                JOIN
                                        invoice_lines_mt inl
                                        ON cc.invoiceline_center = inl.center
                                        AND cc.invoiceline_id = inl.id
                                        AND cc.invoiceline_subid = inl.subid
                                        AND inl.installment_plan_id IS NOT NULL
                                )cc      
                                        ON cc.installment_plan_id = ip.id
                                        AND cc.owner_center = p.center
                                        AND cc.owner_id = p.id                                                                                   
                        WHERE 
                                ip.person_center in (:Scope)
                                AND 
                                ar.balance != 0
                                AND 
                                ip.end_date >= current_date
                        GROUP BY
                                ip.person_center
                                ,ip.person_id 
                                ,pea.txtvalue 
                                ,ipc.name 
                                ,ipc.installment_plan_type 
                                ,ip.amount 
                                ,ip.creation_time
                                ,ip.person_center
                                ,ip.end_date 
                                ,ip.installements_count 
                                ,ar.balance
                                ,ip.id 
                                ,p.external_id 
                                ,ar.center
                                ,ar.id
                                ,sub.name
                                ,cc.name        
                        )t1
                LEFT JOIN
                        ar_trans artb   
                        ON artb.center = t1.center    
                        AND artb.id = t1.id
                        AND artb.installment_plan_id = t1."Installment ID"
                        AND status != 'CLOSED'      
                GROUP BY 
                        t1.person_center
                        ,t1.person_id
                        ,t1."Old System ID"
                        ,t1."Installment"
                        ,t1."Installment Type"
                        ,t1."Total Original Installment amount"
                        ,t1."Creation Date"
                        ,t1."Installment End Date"
                        ,t1.installements_count 
                        ,t1."Installment Plan Account Balance"
                        ,t1."Installment ID"
                        ,t1."External ID"
                        ,t1."Start Date"
                        ,t1."Installment Plan"   
        )t
WHERE   
        t."Installemnt Plan open balance" IS NOT NULL
        AND
        t."Installemnt Plan open balance" != 0                                       
           