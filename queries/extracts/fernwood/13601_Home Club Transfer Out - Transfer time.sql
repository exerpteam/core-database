-- The extract is extracted from Exerp on 2026-02-08
-- Home Club Transfer Out - Transfer time
SELECT
            newp.external_id AS "External ID"
            ,oldp.center || 'p' || oldp.id AS "Old Person ID"
            ,newp.center || 'p' || newp.id AS "New Person ID"
            ,CASE newp.status
                WHEN 0 THEN 'Lead'
                WHEN 1 THEN 'Active'
                WHEN 2 THEN 'Inactive'
                WHEN 3 THEN 'Temporary Inactive'
                WHEN 4 THEN 'Transfered'
                WHEN 5 THEN 'Duplicate'
                WHEN 6 THEN 'Prospect'
                WHEN 7 THEN 'Deleted'
                WHEN 8 THEN 'Anonymized'
                WHEN 9 THEN 'Contact'
                ELSE 'Unknown'
            END AS "Status"
            ,oldp.firstname AS "first Name"
            ,oldp.lastname AS "Last Name"
            ,fromcenter.Name AS "Transferred From"
            ,tocenter.Name AS "Transferred To"
            ,pold.name AS "Old Subscription"
            ,pnew.name AS "New Subscription"
            ,trd.txtvalue AS "Date of Transfer"
            ,TO_CHAR(longtodatec(pcl.entry_time,pcl.person_center),'HH24:MI') AS "Time of Transfer"
            ,emp.center || 'emp' || emp.id AS "Employee ID"
            ,empp.fullname AS "Employee Name"
            ,pro.name AS "Clip Card Name at time of transfer"
            ,-ccu.clips AS "Number of Clips"
FROM
        persons oldp
JOIN
        PERSON_EXT_ATTRS pea
                ON pea.PERSONCENTER= oldp.CENTER
                AND pea.PERSONID= oldp.ID
                AND pea.NAME = '_eClub_TransferredToId'
JOIN
        PERSON_EXT_ATTRS trd
                ON trd.PERSONCENTER= oldp.CENTER
                AND trd.PERSONID= oldp.ID
                AND trd.NAME = '_eClub_TransferDate'
JOIN
        persons newp
                ON newp.center || 'p' || newp.id = pea.txtvalue
                AND newp.STATUS IN (1,3)
JOIN
        centers fromcenter
                ON fromcenter.ID=oldp.center
JOIN
        centers tocenter
                ON tocenter.ID=newp.center
LEFT JOIN
        subscriptions olds
                ON olds.owner_center = oldp.center
                AND olds.owner_id = oldp.id
                and olds.sub_state = 6
LEFT JOIN
        products pold
                ON pold.center = olds.subscriptiontype_center
                AND pold.id = olds.subscriptiontype_id              
LEFT JOIN
        subscriptions news
                ON news.owner_center = newp.center
                AND news.owner_id = newp.id
                AND news.invoiceline_center = oldp.center
LEFT JOIN
        products pnew
                ON pnew.center = news.subscriptiontype_center
                AND pnew.id = news.subscriptiontype_id 
JOIN
        person_change_logs pcl
                ON pcl.person_center = oldp.center
                AND pcl.person_id = oldp.id
                AND pcl.change_attribute = '_eClub_TransferredToId'
JOIN
        employees emp
                ON emp.center = pcl.employee_center
                AND emp.id = pcl.employee_id
JOIN
        persons empp
                ON emp.personcenter = empp.center
                AND emp.personid = empp.id   
LEFT JOIN
        clipcards cc
                ON cc.owner_center = oldp.center
                AND cc.owner_id = oldp.id
                AND trd.txtvalue = TO_CHAR(longtodateC(cc.valid_until,cc.center),'YYYY-MM-DD')  
LEFT JOIN
        card_clip_usages ccu
                ON ccu.card_center = cc.center
                AND ccu.card_id = cc.id
                AND ccu.card_subid = cc.subid 
                AND ccu.type = 'TRANSFER_FROM'                           
LEFT JOIN
        products pro 
                ON pro.center = cc.center
                AND pro.id = cc.ID                                                                                                                                                                                                                                                      
WHERE
        oldp.center in (:Scope)
        AND
        trd.txtvalue >= :FROM 
	AND 
	trd.txtvalue <= :TO

