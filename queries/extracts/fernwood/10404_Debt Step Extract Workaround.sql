-- The extract is extracted from Exerp on 2026-02-08
-- 
SELECT 
        p.external_id AS "External ID"
        ,p.fullname AS "Debtor Name"
        ,-cc.amount AS "Debt Value"
        ,peeaMobile.txtvalue AS "Mobile"
        ,c.name AS "Center Name"
        ,ceatb.txt_value AS "TALKBOX ID"
--        ,ceadc.txt_value AS "Member Admin Team Member Name"
--        ,ceame.txt_value AS "Member Admin Team Email Address"
--        ,ceamn.txt_value AS "Member Admin Number"
--        ,CASE
--                WHEN cc.currentstep_type = -1 THEN 'No Debt step configured '||cc.currentstep
--                WHEN cc.currentstep_type = 0 THEN 'Debt step Message '||cc.currentstep
--                WHEN cc.currentstep_type = 1 THEN 'Debt step Reminder '||cc.currentstep
--                WHEN cc.currentstep_type = 2 THEN 'Debt step Block '||cc.currentstep
--                WHEN cc.currentstep_type = 3 THEN 'Debt step Request And Stop '||cc.currentstep
--                WHEN cc.currentstep_type = 4 THEN 'Debt step Cash Collection '||cc.currentstep
--                WHEN cc.currentstep_type = 5 THEN 'Debt step Close '||cc.currentstep
--                WHEN cc.currentstep_type = 6 THEN 'Debt step Wait '||cc.currentstep
--                WHEN cc.currentstep_type = 7 THEN 'Debt step Request Buyout And Stop '||cc.currentstep
--                WHEN cc.currentstep_type = 8 THEN 'Debt step Push '||cc.currentstep
--        END AS "Debt Step" 
--        ,email.txtvalue AS "Member Email"        
--        ,p.center||'p'||p.id  AS "Person ID" 
--        ,ar.balance AS "Account Balance"                  
FROM
        persons p
JOIN
        centers c
        ON c.id = p.center
LEFT JOIN
        center_ext_attrs ceatb
        ON ceatb.center_id = c.id
        AND ceatb.name = 'TALKBOXID' 
LEFT JOIN
        person_ext_attrs peeaMobile
        ON peeaMobile.personcenter = p.center
        AND peeaMobile.personid = p.id
        AND peeaMobile.name = '_eClub_PhoneSMS' 
JOIN         
        account_receivables ar
        ON ar.customercenter = p.center
        AND ar.customerid = p.id
        AND ar.ar_type = 4 
LEFT JOIN
        center_ext_attrs ceadc
        ON ceadc.center_id = c.id
        AND ceadc.name = 'DebtCollector'  
LEFT JOIN
        center_ext_attrs ceame
        ON ceame.center_id = c.id
        AND ceame.name = 'MemberAdminEmail'    
LEFT JOIN
        center_ext_attrs ceamn
        ON ceamn.center_id = c.id
        AND ceamn.name = 'MemberAdminNumber'   
JOIN
        cashcollectioncases cc
        ON cc.personcenter = p.center
        AND cc.personid = p.id
        AND cc.closed IS FALSE
        AND cc.missingpayment IS TRUE 
LEFT JOIN
        person_ext_attrs email
        ON email.personcenter = p.center
        AND email.personid = p.id
        AND email.name = '_eClub_Email'                                            
WHERE
        ar.balance < 0
        AND
        p.center NOT IN (204,206,303,305,309,311,314,320,321,503,601,602,702,707,801)
        AND
        (
                cc.startdate = CURRENT_DATE
                OR
                cc.currentstep_date = CURRENT_DATE
        )  