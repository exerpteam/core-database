-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
                t2."Person ID"
                ,t2."Member Name"
                ,t2."Home Club"
                ,t2."Subscription Name" 
                ,t2."Document type"                  
                ,t2."Contract Creation Date"    
                ,t2."Document Status" 
FROM        
        (
        SELECT  DISTINCT
                doc.person_center ||'p'|| doc.person_id AS "Person ID"
                ,p.fullname AS "Member Name"
                ,c.shortname AS "Home Club"
                ,pro.name AS "Subscription Name" 
                ,doc.name AS "Document type"                  
                ,TO_CHAR(longtodateC(doc.creation_time, doc.person_center),'DD-MM-YYYY HH24:MI') AS "Contract Creation Date"    
                ,CASE
                        WHEN t1.JournalID IS NULL THEN 'Signed Contract'
                        ELSE 'Unsigned Contract' 
                END AS "Document Status" 
                ,doc.id              
        FROM    
                journalentries doc
        LEFT JOIN    
                (
                SELECT DISTINCT
                        je.person_center AS PersonCenter 
                        ,je.person_id AS PersonID
                        ,je.id AS JournalID
                FROM journalentries je
                JOIN journalentry_signatures jes
                                ON je.id = jes.journalentry_id        
                                AND jes.signature_id IS NULL                                                                        
                WHERE 
                        je.jetype = 1
                        AND 
                        je.person_center in (:Scope)    
                )t1 
                        ON t1.PersonCenter = doc.person_center
                        AND t1.PersonID = doc.person_id
                        AND t1.JournalID = doc.id
        JOIN
                persons p
                        ON p.center = doc.person_center
                        AND p.id = doc.person_id                 
        JOIN    
                centers c
                        ON p.center = c.id
        JOIN 
                subscriptions s
                        ON doc.ref_center = s.center
                        AND doc.ref_id = s.id 
        JOIN
                products pro
                        ON pro.center = s.subscriptiontype_center
                        AND pro.id = s.subscriptiontype_id                
        WHERE 
                        doc.jetype = 1
                        AND 
                        doc.person_center in (:Scope)
        )t2
WHERE
        t2."Document Status"  = 'Unsigned Contract'                                                           
