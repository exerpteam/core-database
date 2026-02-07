WITH
        params AS MATERIALIZED
        (
                SELECT
                  /*+ materialize */
                  datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                  c.id AS CENTER_ID,
                  CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate         
                FROM
                  centers c
        ),
        signed_doc AS
        (
                SELECT DISTINCT
                    p.center
                    ,p.id
                    ,longtodatec(je.creation_time,p.center)::DATE AS "Document Creation Date"
                FROM
                    evolutionwellness.journalentries je
                LEFT JOIN
                    evolutionwellness.journalentry_signatures js
                ON
                    js.journalentry_id = je.id
                JOIN
                    evolutionwellness.persons p
                ON
                    p.center = je.person_center
                AND p.id = je.person_id
                WHERE
                    js.signature_center IS NULL
                AND je.signable
                AND p.center IN (:scope)
                AND je.JETYPE = 1 
        ),
        missing_agreement AS
        (
                SELECT 
                        ccc.personcenter
                        ,ccc.personid
                FROM
                        evolutionwellness.cashcollectioncases ccc
                WHERE
                        ccc.closed IS FALSE 
                        AND
                        ccc.missingpayment IS FALSE
                        AND
                        ccc.center IN (:scope) 
        )                           
                                           
SELECT DISTINCT 
        c.name AS "Club"
        ,c.id AS "Club Number"
        ,corp.fullname AS "Corporate Name"
        ,p.external_id AS "Member Number"
        ,p.fullname AS "Member Name"
        ,ss.sales_date AS "Join Date" 
        ,CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS "Membership Status"
        ,employee.fullname AS "Sales Person" 
        ,CASE s.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS "Change Type"
        ,longtodatec(s.creation_time,s.center) AS "Change Date"
        ,prod.name AS "Plan Name"
        ,NULL AS "Plan Class"
        ,THVetting1.txtvalue AS "Is the ID card or Passport unique in Exerp"
        ,THVetting2.txtvalue AS "Have the payment details passed the duplicate check"
        ,THVetting3.txtvalue AS " Has a Parental Consent form been uploaded for a member aged 20 or under"
        ,THVetting4.txtvalue AS "All scanned documents completed"
        ,THVetting5.txtvalue AS "Direct Debit - DD Mandate registered"
        ,THVetting6.txtvalue AS "Promotion"
        ,THVetting7.txtvalue AS "Other Notes"
        ,THVetting8.txtvalue AS "Comissionable"
        ,THVetting9.txtvalue AS "Vetting passed"
        ,CASE
                WHEN employee.fullname like '%API%' THEN 'Yes'
                ELSE 'No'
        END AS "Join Online"
        ,empvp.fullname AS "Last Edit by"
        ,longtodatec(pcl2.entry_time,pcl2.person_center) AS "Last edited"
        ,CASE
                WHEN sd.center IS NULL THEN 'No'
                ELSE 'Yes'
        END AS "Unsigned document"
        ,CASE
                WHEN ma.personcenter IS NULL THEN 'No'
                ELSE 'Yes'
        END AS "Missing agreement"                
FROM
        evolutionwellness.persons p
JOIN
        evolutionwellness.centers c
        ON c.id = p.center
LEFT JOIN
        evolutionwellness.relatives r
        ON r.relativecenter = p.center
        AND r.relativeid = p.id
        AND r.status < 2
		AND r.rtype = 2
LEFT JOIN
        evolutionwellness.persons corp
        ON corp.center = r.center
        AND corp.id = r.id        
JOIN
        evolutionwellness.subscriptions s
        ON s.owner_center = p.center
        AND s.owner_id = p.id   
JOIN
        evolutionwellness.subscription_sales ss
        ON ss.subscription_center = s.center
        AND ss.subscription_id = s.id
JOIN
        evolutionwellness.employees emp
        ON emp.center = ss.employee_center
        AND emp.id = ss.employee_id
JOIN
        evolutionwellness.persons employee
        ON employee.center = emp.personcenter
        AND employee.id = emp.personid 
JOIN
        evolutionwellness.subscriptiontypes st
        ON st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
JOIN
        evolutionwellness.products prod
        ON prod.center = st.center
        AND prod.id = st.id    
JOIN
        params 
        ON params.center_id = ss.subscription_center    
LEFT JOIN
        evolutionwellness.person_ext_attrs THVetting1 -- Is the ID card or Passport unique in Exerp?
        ON THVetting1.personcenter = p.center
        AND THVetting1.personid = p.id
        AND THVetting1.name = 'THVetting1'          
LEFT JOIN
        evolutionwellness.person_ext_attrs THVetting2 -- Have the payment details passed the duplicate check
        ON THVetting2.personcenter = p.center
        AND THVetting2.personid = p.id
        AND THVetting2.name = 'THVetting2'        
LEFT JOIN
        evolutionwellness.person_ext_attrs THVetting3-- Has a Parental Consent form been uploaded for a member aged 20 or under
        ON THVetting3.personcenter = p.center
        AND THVetting3.personid = p.id
        AND THVetting3.name = 'THVetting3'          
LEFT JOIN
        evolutionwellness.person_ext_attrs THVetting4--All scanned documents completed
        ON THVetting4.personcenter = p.center
        AND THVetting4.personid = p.id
        AND THVetting4.name = 'THVetting4'  
LEFT JOIN
        evolutionwellness.person_ext_attrs THVetting5--Direct Debit - DD Mandate registered
        ON THVetting5.personcenter = p.center
        AND THVetting5.personid = p.id
        AND THVetting5.name = 'THVetting5'     
LEFT JOIN
        evolutionwellness.person_ext_attrs THVetting6--Promotion
        ON THVetting6.personcenter = p.center
        AND THVetting6.personid = p.id
        AND THVetting6.name = 'THVetting6'   
LEFT JOIN
        evolutionwellness.person_ext_attrs THVetting7--Other Notes
        ON THVetting7.personcenter = p.center
        AND THVetting7.personid = p.id
        AND THVetting7.name = 'THVetting7'  
LEFT JOIN
        evolutionwellness.person_ext_attrs THVetting8-- Comissionable
        ON THVetting8.personcenter = p.center
        AND THVetting8.personid = p.id
        AND THVetting8.name = 'THVetting8'                
LEFT JOIN
        evolutionwellness.person_ext_attrs THVetting9--Vetting passed
        ON THVetting9.personcenter = p.center
        AND THVetting9.personid = p.id
        AND THVetting9.name = 'THVetting9'  
LEFT JOIN
        (
        SELECT MAX(pcl.entry_time) as maxtime, pcl.person_center,pcl.person_id 
        FROM evolutionwellness.person_change_logs pcl 
        WHERE pcl.change_attribute IN ('THVetting1','THVetting2','THVetting3','THVetting4','THVetting5','THVetting6','THVetting7','THVetting8','THVetting9','THVetting10')
        GROUP BY pcl.person_center,pcl.person_id
        )pcl
        ON pcl.person_center = p.center
        AND pcl.person_id = p.id 
LEFT JOIN
        evolutionwellness.person_change_logs pcl2
        ON pcl.person_center = pcl2.person_center
        AND pcl.person_id = pcl2.person_id
        AND pcl2.entry_time = pcl.maxtime
LEFT JOIN
        evolutionwellness.employees empv
        ON empv.center = pcl2.employee_center
        AND empv.id = pcl2.employee_id 
LEFT JOIN
        evolutionwellness.persons empvp
        ON empvp.center = empv.personcenter
        AND empvp.id = empv.personid
LEFT JOIN
        signed_doc sd
        ON sd.center = p.center
        AND sd.id = p.id
        AND sd."Document Creation Date" = longtodatec(s.creation_time,s.center)::DATE
LEFT JOIN
        missing_agreement ma
        ON ma.personcenter = p.center
        AND ma.personid = p.id                                       
WHERE
        p.center IN (:scope)
	AND 
	s.creation_time BETWEEN params.FromDate AND params.ToDate
	AND
	p.sex != 'C'