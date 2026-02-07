WITH
        max_sub AS
                (
                SELECT 
                        max(s.id) AS LastID
                        ,s.center AS MaxCenter
                        ,s.owner_center AS MaxOwnerCenter
                        ,s.owner_id AS MaxOwnerID
                FROM 
                        subscriptions s
                JOIN
                        subscriptiontypes st
                        ON st.center = s.subscriptiontype_center
                        AND st.id = s.subscriptiontype_id 
                        AND st.st_type != 2                     
                GROUP BY
                        s.center,s.owner_center,s.owner_id
                ), 
        age AS
                (
                SELECT 
                        max_sub.MaxOwnerCenter
                        ,max_sub.MaxOwnerID
                        ,sub.start_date
                FROM
                        max_sub
                JOIN                        
                        fernwood.subscriptions sub
                        ON max_sub.LastID = sub.id
                        AND max_sub.MaxCenter = sub.center  
                        AND max_sub.MaxOwnerCenter = sub.owner_center   
                        AND max_sub.MaxOwnerID = sub.owner_id
                ),
        open_task AS
                (
                SELECT 
                        p.external_id
                FROM 
                        tasks task
                JOIN
                        task_types tt
                        ON tt.id = task.type_id
                        AND tt.external_id = 'DM_NEW' 
                JOIN
                        persons p
                        ON p.center = task.person_center
                        AND p.id = task.person_id                                               
                WHERE 
                        task.status NOT IN ('CLOSED','DELETED')  
                )                                                                                       
SELECT
        t."External_ID"
        ,t."CRM_External_ID"
        ,t."Clearing_house"||' '||t."Collection_date"||' - '||t."Reject_Reason"||t."Age" AS "Title"
        ,t."Assignee_External_ID"
        ,t.PersonID
FROM
        (        
        SELECT DISTINCT
                p.external_id AS "External_ID"
                ,p.center||'p'||p.id as PersonID
                ,'DM_NEW' AS "CRM_External_ID"
                ,cea.txt_value AS "Assignee_External_ID"
                ,c.id
                ,c.name
                ,CASE
                        WHEN -(date_part('year',age(p.birthdate, age.start_date))) < 18 THEN ' - (MINOR)'
                        ELSE ''
                END AS "Age"
                ,CASE
                        WHEN pag.clearinghouse = 1 THEN 'BA'
                        WHEN pag.clearinghouse = 2 THEN 'CC'
                END AS "Clearing_house" 
                ,CASE
                        WHEN pag.individual_deduction_day = 11 THEN 'BIG'
                        WHEN pag.individual_deduction_day = 4 THEN 'SML'
                END AS "Collection_date"                
                ,CASE
                        WHEN pr.xfr_info IS NULL THEN 'PS_FAIL_NO_CREDITOR'
                        ELSE pr.xfr_info
                END AS "Reject_Reason"
        FROM
                payment_agreements pag 
        JOIN 
                account_receivables ar 
                ON ar.center = pag.center 
                AND ar.id = pag.id
                AND ar.balance < 0
        JOIN 
                persons p 
                ON p.center = ar.customercenter 
                AND p.id = ar.customerid 
        JOIN 
                fernwood.payment_requests pr 
                ON pr.center = pag.center 
                AND pr.id = pag.id 
                AND pr.agr_subid = pag.subid
        JOIN
                fernwood.payment_request_specifications prs
                ON pr.INV_COLL_CENTER = prs.CENTER
                AND pr.INV_COLL_ID = prs.ID
                AND pr.INV_COLL_SUBID = prs.SUBID 
        JOIN 
                centers c 
                ON c.id = pr.center
        LEFT JOIN
                center_ext_attrs cea
                ON c.id = cea.center_id
                AND cea.name = 'MemberAdmin'
        LEFT JOIN
                age
                ON age.MaxOwnerCenter = p.center
                AND age.MaxOwnerID = p.id   
        LEFT JOIN
                open_task op
                ON op.external_id = p.external_id                                                                          
        WHERE 
                (
                pr.rejected_reason_code IS NOT NULL 
                OR 
                (pr.xfr_info = '' AND pr.state IN (17,7))
                OR
                (pr.xfr_info IS NULL AND pr.state = 12)
                )
                AND
                pr.due_date BETWEEN (TO_DATE(getcentertime(c.id),'YYYY-MM-DD')-7) AND TO_DATE(getcentertime(c.id),'YYYY-MM-DD') 
                AND 
                p.center in (:scope) 
                AND
                p.center NOT IN (204,303,305,309,311,314,320,321,601,602,702,327,704)  
                AND
                op.external_id IS NULL
        )t                        