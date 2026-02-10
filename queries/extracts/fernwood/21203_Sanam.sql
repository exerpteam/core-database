-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t.*
FROM
        (                
                SELECT
                                t1.person_center ||'p'|| t1.person_id AS "Person ID"
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
                                ,sum(artb.amount) AS "Installemnt Plan open balance"
                                ,t1."Open Debt Case"
                FROM
                        (                
                        SELECT DISTINCT
                                ip.person_center 
                                ,ip.person_id
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
                                ,CASE
                                        WHEN cc.center IS NULL THEN 'No'
                                        ELSE 'Yes'
                                END AS "Open Debt Case"
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
                                cashcollectioncases cc
                                ON p.center = cc.personcenter
                                AND p.ID = cc.personid
                                AND cc.missingpayment = 1 
                                AND cc.closed IS FALSE 
                                AND cc.closed_datetime IS NULL                                                                                                     
                        WHERE 
                                ip.person_center in (:Scope)
                                AND 
                                ar.balance != 0
                                AND 
                                ip.end_date >= current_date
                                AND
                                p.id IN (7037,41641)
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
                                ,cc.center
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
                        ,t1."Open Debt Case"
        )t
WHERE   
        t."Installemnt Plan open balance" IS NOT NULL
        AND
        t."Installemnt Plan open balance" != 0                                       
           