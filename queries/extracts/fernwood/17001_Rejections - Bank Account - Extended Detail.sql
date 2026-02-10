-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-2347
Anthony's report
WITH
        maxcheckin AS
                (
                SELECT
                        ck.person_center
                        ,ck.person_id 
                        ,max(ck.checkin_time) AS latestcheckin
                FROM 
                        checkins CK
                WHERE 
                        ck.person_center in (:Scope)                
                GROUP BY
                        ck.person_center
                        ,ck.person_id
                ),
        totalvisit AS
                (
                SELECT
                        ck.person_center
                        ,ck.person_id 
                        ,count(ck.checkin_time) AS total
                FROM 
                        checkins ck
                WHERE 
                        ck.person_center in (:Scope)
                GROUP BY
                        ck.person_center
                        ,ck.person_id
                ), 
        revenue AS
                (
                SELECT
                        sum(pr.req_amount) AS totalrevenue
                        ,p.center
                        ,p.id
                FROM
                        payment_agreements pag 
                JOIN 
                        account_receivables ar 
                                ON ar.center = pag.center 
                                AND ar.id = pag.id
                JOIN 
                        persons p 
                                ON p.center = ar.customercenter 
                                AND p.id = ar.customerid 
                JOIN    
                        payment_requests pr 
                                ON pr.center = pag.center 
                                AND pr.id = pag.id 
                                AND pr.agr_subid = pag.subid
                                AND pr.state IN (3,4,18)
                WHERE 
                        p.center in (:Scope)                        
                GROUP BY 
                        p.center
                        ,p.id
                ),
        sao AS                
                (
                SELECT
                        s.owner_center
                        ,s.owner_id
                        ,sao.id
                FROM                        
                        subscriptions s

                JOIN
                        subscriptiontypes st
                                ON st.center = s.subscriptiontype_center
                                AND st.ID = s.subscriptiontype_id
                                AND st.st_type != 2                         
                JOIN 
                        subscription_addon sao 
                                ON sao.subscription_center = s.center 
                                AND sao.subscription_id = s.id
                                AND (sao.end_date IS NULL OR sao.end_date > current_date)                        
                WHERE
                        s.state in (2,4,7,8)
                ),
        PTBalance AS
                (
                SELECT 
                        SUM(cc.clips_left) AS balance
                        ,cc.owner_center
                        ,cc.owner_id 
                FROM 
                        clipcards cc 
                JOIN 
                        products pro 
                                ON pro.center = cc.center
                                AND pro.id = cc.ID
                JOIN
                        product_and_product_group_link pg
                                ON pro.center = pg.product_center
                                AND pro.id = pg.product_id
                                AND pg.product_group_id = 214	 
                WHERE
                        cc.cancelled = 'false' 
                        AND 
                        cc.finished = 'false' 
                        AND 
                        cc.blocked = 'false'
                        AND 
                        cc.owner_center in (:Scope)                
                GROUP BY
                        cc.owner_center
                        ,cc.owner_id
                ), 
        open_invoices AS
                (
                SELECT 
                        COUNT(*) As total
                        ,MIN(art.due_date) as MinDue
                        ,ar.center
                        ,ar.id
                FROM
                        account_receivables ar
                JOIN
                        ar_trans art   
                                ON art.center = ar.center    
                                AND art.id = ar.id        
                
                WHERE
                        ar.ar_type = 4
                        AND
                        art.status IN ('OPEN','NEW')
                        AND
                        art.due_date < current_date
                        AND
                        ar.balance < 0
                GROUP BY
                        ar.center
                        ,ar.id   
                )                                                             
        
SELECT
        t1.center
        ,t1.id
        ,t1."PersonID"
        ,p.external_id AS "External ID"
        ,t1."Club"
        ,t1."First Name"
        ,t1."Last Name"
        ,t1."Clearing House ID"
        ,t1."Request Date"
        ,t1."Amount"
        ,t1."Clearing House"
        ,t1."Rejection Info"
        ,t1."Rejection Reason"
        ,t1."Person Type"
        ,t1."Person Status" 
        ,t1."Member Balance"
        ,t1."Payment Agreement State"
        ,t1."Payment Agreement Cancel Reason"    
        ,t1."Last Visit"
        ,t1."Total Visits" 
        ,t1."LTD $ Revenue"
        ,t1."Add on Yes/No" 
        ,t1."PT Clip Balance" 
        ,t1."Email address"  
        ,t1."Mobile number"  
        ,journals.comment1 AS "Comment 1"
        ,journals.comment2 AS "Comment 2"
        ,journals.comment3 AS "Comment 3"
        ,journals.comment4 AS "Comment 4"
        ,journals.comment5 AS "Comment 5"
        ,journals.comment6 AS "Comment 6"
        ,journals.comment7 AS "Comment 7"
        ,journals.comment8 AS "Comment 8"
        ,journals.comment9 AS "Comment 9"
        ,journals.comment10 AS "Comment 10"
        ,t1."Total Overdue Transactions"
        ,t1."Oldest Debt"                                                   
FROM
(        
        SELECT DISTINCT 
                p.center,
                p.id,
                p.center || 'p' || p.id AS "PersonID"
                ,c.name AS "Club"
                ,p.firstname AS "First Name"
                ,p.lastname AS "Last Name"
                ,pr.clearinghouse_id AS "Clearing House ID"
                ,pr.req_date AS "Request Date"
                ,pr.req_amount AS "Amount"
                ,ch.name AS "Clearing House"
                ,pr.xfr_info AS "Rejection Info"
                ,pr.rejected_reason_code AS "Rejection Reason"
                ,CASE
                        WHEN p.persontype = 0 THEN 'Private'
                        WHEN p.persontype = 1 THEN 'Student'
                        WHEN p.persontype = 2 THEN 'Staff'
                        WHEN p.persontype = 3 THEN 'Friend'
                        WHEN p.persontype = 4 THEN 'Corporate'
                        WHEN p.persontype = 5 THEN 'Onemancorporate'
                        WHEN p.persontype = 6 THEN 'Family'
                        WHEN p.persontype = 7 THEN 'Senior'
                        WHEN p.persontype = 8 THEN 'Guest'
                        WHEN p.persontype = 9 THEN 'Child'
                        WHEN p.persontype = 10 THEN 'External_Staff'
                        ELSE 'Unknown'
                END AS "Person Type"
                ,CASE
                        WHEN p.status = 0 THEN 'Lead'
                        WHEN p.status = 1 THEN 'Active'
                        WHEN p.status = 2 THEN 'Inactive'
                        WHEN p.status = 3 THEN 'Temporary Inactive'
                        WHEN p.status = 4 THEN 'Transfered'
                        WHEN p.status = 5 THEN 'Duplicate'
                        WHEN p.status = 6 THEN 'Prospect'
                        WHEN p.status = 7 THEN 'Deleted'
                        WHEN p.status = 8 THEN 'Anonymized'
                        WHEN p.status = 9 THEN 'Contact'
                        ELSE 'Unknown'
                END AS "Person Status" 
                ,ar.balance AS "Member Balance"
                ,CASE
                        WHEN pag.state = 1 THEN 'Created'
                        WHEN pag.state = 2 THEN 'Sent'
                        WHEN pag.state = 3 THEN 'Failed'
                        WHEN pag.state = 4 THEN 'OK'
                        WHEN pag.state = 5 THEN 'Ended by bank'
                        WHEN pag.state = 6 THEN 'Ended by clearing house'
                        WHEN pag.state = 7 THEN 'Ended by debtor'
                        WHEN pag.state = 8 THEN 'Cancelled, not sent'
                        WHEN pag.state = 9 THEN 'Cancelled, sent'
                        WHEN pag.state = 10 THEN 'Ended, creditor'
                        WHEN pag.state = 11 THEN 'No agreement (deprecated)'
                        WHEN pag.state = 12 THEN 'Cash payment (deprecated)'
                        WHEN pag.state = 13 THEN 'Agreement not needed (invoice payment)'
                        WHEN pag.state = 14 THEN 'Agreement information incomplete'
                        WHEN pag.state = 15 THEN 'Transfer'
                        WHEN pag.state = 16 THEN 'Agreement Recreated'
                        WHEN pag.state = 17 THEN 'Signature missing'
                        ELSE 'UNDEFINED'
                 END AS "Payment Agreement State"
                ,CASE
                        WHEN pag.state = 4 THEN NULL
                        ELSE pag.ended_reason_text
                END AS "Payment Agreement Cancel Reason"    
                ,longtodatec(maxcheckin.latestcheckin,maxcheckin.person_center) AS "Last Visit"
                ,totalvisit.total AS "Total Visits" 
                ,revenue.totalrevenue AS "LTD $ Revenue"
                ,CASE
                        WHEN sao.id IS NULL THEN 'No'
                        ELSE 'Yes'
                END AS "Add on Yes/No" 
                ,CASE
                        WHEN PTBalance.balance IS NULL THEN 0
                        ELSE PTBalance.balance
                END AS "PT Clip Balance" 
                ,peeaEmail.txtvalue AS "Email address"  
                ,peeaMobile.txtvalue AS "Mobile number"  
                ,open_invoices.total AS "Total Overdue Transactions"
                ,open_invoices.MinDue AS "Oldest Debt" 
        FROM 
                payment_agreements pag 
        JOIN 
                account_receivables ar 
                        ON ar.center = pag.center 
                        AND ar.id = pag.id
        JOIN 
                persons p 
                        ON p.center = ar.customercenter 
                        AND p.id = ar.customerid 
        JOIN 
                payment_requests pr 
                        ON pr.center = pag.center 
                        AND pr.id = pag.id 
                        AND pr.agr_subid = pag.subid
        JOIN 
                centers c 
                        ON c.id = pr.center
        JOIN 
                clearinghouses ch 
                        ON ch.id = pr.clearinghouse_id
        LEFT JOIN
                maxcheckin
                        ON maxcheckin.person_center = p.center
                        AND maxcheckin.person_id = p.id
        LEFT JOIN
                totalvisit
                        ON totalvisit.person_center = p.center
                        AND totalvisit.person_id = p.id
        LEFT JOIN
                revenue
                        ON revenue.center = p.center
                        AND revenue.id = p.id
        LEFT JOIN
                sao
                                                
                        ON sao.owner_center = p.center
                        AND sao.owner_id = p.id         
        LEFT JOIN
                PTBalance
                        ON PTBalance.owner_center = p.center
                        AND PTBalance.owner_id = p.id  
        LEFT JOIN
                person_ext_attrs peeaEmail
                        ON peeaEmail.personcenter = p.center
                        AND peeaEmail.personid = p.id
                        AND peeaEmail.name = '_eClub_Email'
        LEFT JOIN
                person_ext_attrs peeaMobile
                        ON peeaMobile.personcenter = p.center
                        AND peeaMobile.personid = p.id
                        AND peeaMobile.name = '_eClub_PhoneSMS'
        LEFT JOIN        
                open_invoices 
                        ON open_invoices.center = ar.center
                        AND open_invoices.id = ar.id                               
        WHERE 
                (pr.rejected_reason_code is not null OR (pr.xfr_info = '' AND pr.state IN (17,7)))
                and
                longToDate(pr.entry_time) between :BillingStart and :BillingEnd
                and 
                pr.clearinghouse_id  = 1
                and 
                p.center in (:Scope)
) t1
LEFT JOIN
    persons p ON p.center = t1.center AND p.id = t1.id
LEFT JOIN
(
        WITH entries AS 
        (
                SELECT
                        je.person_center,
                        je.person_id,
                        CASE
                                WHEN is_utf8_encoded(je.big_text) = 'true' THEN CAST(convert_from(je.big_text, 'UTF-8') AS TEXT)
                                ELSE je.name
                        END AS BigText,
                        je.name AS je_name,
                        je.creation_time
                FROM 
                       journalentries je
                WHERE
                       je.person_center in (:Scope)
        ),
        v_pivot AS
        (
               SELECT
                        entries.*,
                        LEAD(je_name,1) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS je_name2,
                        LEAD(BigText,1) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS BigText2,
                        LEAD(je_name,2) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS je_name3,
                        LEAD(BigText,2) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS BigText3,
                        LEAD(je_name,3) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS je_name4,
                        LEAD(BigText,3) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS BigText4, 
                        LEAD(je_name,4) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS je_name5,
                        LEAD(BigText,4) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS BigText5,  
                        LEAD(je_name,5) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS je_name6,
                        LEAD(BigText,5) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS BigText6,  
                        LEAD(je_name,6) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS je_name7,
                        LEAD(BigText,6) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS BigText7,  
                        LEAD(je_name,7) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS je_name8,
                        LEAD(BigText,7) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS BigText8,  
                        LEAD(je_name,8) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS je_name9,
                        LEAD(BigText,8) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS BigText9,  
                        LEAD(je_name,9) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS je_name10,
                        LEAD(BigText,9) OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS BigText10,                                                                                                                                                                         
                        ROW_NUMBER() OVER (PARTITION BY person_center, person_id ORDER BY creation_time DESC) AS JESEQ
               FROM 
                        entries
        )
        SELECT
                v_pivot.person_center,
                v_pivot.person_id,
                (CASE 
                        WHEN v_pivot.BigText IS NULL THEN v_pivot.je_name
                        WHEN v_pivot.BigText = '' THEN v_pivot.je_name
                        ELSE v_pivot.BigText
                END) AS Comment1,
                (CASE 
                        WHEN v_pivot.BigText2 IS NULL THEN v_pivot.je_name2
                        WHEN v_pivot.BigText2 = '' THEN v_pivot.je_name2
                        ELSE v_pivot.BigText2
                END) AS Comment2,
                (CASE 
                        WHEN v_pivot.BigText3 IS NULL THEN v_pivot.je_name3
                        WHEN v_pivot.BigText3 = '' THEN v_pivot.je_name3
                        ELSE v_pivot.BigText3
                END) AS Comment3,
                (CASE 
                        WHEN v_pivot.BigText4 IS NULL THEN v_pivot.je_name
                        WHEN v_pivot.BigText4 = '' THEN v_pivot.je_name
                        ELSE v_pivot.BigText4
                END) AS Comment4, 
                (CASE 
                        WHEN v_pivot.BigText5 IS NULL THEN v_pivot.je_name
                        WHEN v_pivot.BigText5 = '' THEN v_pivot.je_name
                        ELSE v_pivot.BigText5
                END) AS Comment5,
                (CASE 
                        WHEN v_pivot.BigText6 IS NULL THEN v_pivot.je_name
                        WHEN v_pivot.BigText6 = '' THEN v_pivot.je_name
                        ELSE v_pivot.BigText6
                END) AS Comment6, 
                (CASE 
                        WHEN v_pivot.BigText7 IS NULL THEN v_pivot.je_name
                        WHEN v_pivot.BigText7 = '' THEN v_pivot.je_name
                        ELSE v_pivot.BigText7
                END) AS Comment7,  
                (CASE 
                        WHEN v_pivot.BigText8 IS NULL THEN v_pivot.je_name
                        WHEN v_pivot.BigText8 = '' THEN v_pivot.je_name
                        ELSE v_pivot.BigText8
                END) AS Comment8,  
                (CASE 
                        WHEN v_pivot.BigText9 IS NULL THEN v_pivot.je_name
                        WHEN v_pivot.BigText9 = '' THEN v_pivot.je_name
                        ELSE v_pivot.BigText9
                END) AS Comment9,  
                (CASE 
                        WHEN v_pivot.BigText10 IS NULL THEN v_pivot.je_name
                        WHEN v_pivot.BigText10 = '' THEN v_pivot.je_name
                        ELSE v_pivot.BigText10
                END) AS Comment10                                                                                                                  
        FROM
                v_pivot
        WHERE
                JESEQ = 1
) journals
ON
        journals.person_center = t1.center
        AND journals.person_id = t1.id