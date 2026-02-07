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
          )
SELECT 
        c.name AS "Club"
        ,c.id AS "Club Number"
        ,NULL AS "Club Code"
        ,corp.fullname AS "Corporate Name"
        ,p.external_id AS "Member Number"
        ,p.fullname AS "Member Name"
        ,ss.sales_date AS "Join Date" 
        ,CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS "Membership Status"
        ,NULL AS "Payment Status"
        ,employee.fullname AS "Sales Person" 
        ,CASE s.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS "Change Type"
        ,longtodatec(s.creation_time,s.center) AS "Change Date"
        ,current_date - longtodatec(s.creation_time,s.center) AS "Days Since Change"
        ,NULL AS "Confirmation Type"
        ,NULL AS "Package Name"
        ,prod.name AS "Plan Name"
        ,NULL AS "Payment Method"
        ,NULL AS "Card Type"
        ,NULL AS "Funding Source"
        ,NULL AS "Plan Class"
        ,NULL AS "Is Personal Trainer"
        ,IDVetting1.txtvalue AS "Is the National ID or Passport unique in system"
        ,IDVetting10.txtvalue AS "Has the correct promotion applied with valid proof"
        ,IDVetting11.txtvalue AS "Has a Corporate proof been uploaded (If applicable)"
        ,IDVetting12.txtvalue AS "Has the Family add-on proof provided (Proof of Family Card or Marriage Certificate)"
        ,IDVetting13.txtvalue AS "Has a Physician Approval Form been supplied (if applicable)"
        ,IDVetting14.txtvalue AS "Manual Forms - Has the Statement Letter been uploaded"
        ,IDVetting15.txtvalue AS "Manual Forms - Has the required documents been uploaded"
        ,IDVetting16.txtvalue AS "Manual Forms - Do all details keyed match the Manual Forms"
        ,IDVetting17.txtvalue AS "WWYB Joiner"
        ,IDVetting18.txtvalue AS "All scanned documents readable"
        ,IDVetting19.txtvalue AS "Additional FV Reason"
        ,IDVetting2.txtvalue AS "Is the member name as per National ID and address full and complete"
        ,IDVetting20.txtvalue AS"POS PT Sales Sold"
        ,IDVetting21.txtvalue AS "Comissionable"
        ,IDVetting22.txtvalue AS "Vetting Passed"
        ,IDVetting3.txtvalue AS "Has a Parental Consent form been uploaded for a member aged 18 or under"
        ,IDVetting4.txtvalue AS "In the event of third party payer, does the payer National ID/Passport details matched & uploaded" 
        ,IDVetting5.txtvalue AS "Have the payment details passed the duplicate check"
        ,IDVetting6.txtvalue AS "Has a credit card front page or DD Mini Statement been uploaded"
        ,IDVetting7.txtvalue AS "Has a DD/CC Local Card Mandate form been uploaded"
        ,IDVetting8.txtvalue AS "Has the DD/CC Local Card Mandate been completed correctly"
        ,IDVetting9.txtvalue AS "Do the billing details match the supporting documents"
        ,CASE
                WHEN employee.fullname like '%API%' THEN 'Yes'
                ELSE 'No'
        END AS "Join Online"
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
        evolutionwellness.person_ext_attrs IDVetting1 -- Is the National ID or Passport unique in system
        ON IDVetting1.personcenter = p.center
        AND IDVetting1.personid = p.id
        AND IDVetting1.name = 'IDVetting1'          
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting10 -- Has the correct promotion applied with valid proof
        ON IDVetting10.personcenter = p.center
        AND IDVetting10.personid = p.id
        AND IDVetting10.name = 'IDVetting10'        
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting11--Has a Corporate proof been uploaded (If applicable)
        ON IDVetting11.personcenter = p.center
        AND IDVetting11.personid = p.id
        AND IDVetting11.name = 'IDVetting11'          
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting12--Has the Family add-on proof provided (Proof of Family Card or Marriage Certificate)
        ON IDVetting12.personcenter = p.center
        AND IDVetting12.personid = p.id
        AND IDVetting12.name = 'IDVetting12'  
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting13--Has a Physician Approval Form been supplied (if applicable)
        ON IDVetting13.personcenter = p.center
        AND IDVetting13.personid = p.id
        AND IDVetting13.name = 'IDVetting13'     
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting14--Manual Forms - Has the Statement Letter been uploaded
        ON IDVetting14.personcenter = p.center
        AND IDVetting14.personid = p.id
        AND IDVetting14.name = 'IDVetting14'   
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting15--Manual Forms - Has the required documents been uploaded
        ON IDVetting15.personcenter = p.center
        AND IDVetting15.personid = p.id
        AND IDVetting15.name = 'IDVetting15'  
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting16--Manual Forms - Do all details keyed match the Manual Forms
        ON IDVetting16.personcenter = p.center
        AND IDVetting16.personid = p.id
        AND IDVetting16.name = 'IDVetting16'                
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting17--WWYB Joiner
        ON IDVetting17.personcenter = p.center
        AND IDVetting17.personid = p.id
        AND IDVetting17.name = 'IDVetting17'    
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting18--All scanned documents readable
        ON IDVetting18.personcenter = p.center
        AND IDVetting18.personid = p.id
        AND IDVetting18.name = 'IDVetting18'    
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting19--Additional FV Reason
        ON IDVetting19.personcenter = p.center
        AND IDVetting19.personid = p.id
        AND IDVetting19.name = 'IDVetting19'    
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting2--Is the member name as per National ID and address full and complete
        ON IDVetting2.personcenter = p.center
        AND IDVetting2.personid = p.id
        AND IDVetting2.name = 'IDVetting2'   
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting20--POS PT Sales Sold
        ON IDVetting20.personcenter = p.center
        AND IDVetting20.personid = p.id
        AND IDVetting20.name = 'IDVetting20'           
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting21-- Comissionable
        ON IDVetting21.personcenter = p.center
        AND IDVetting21.personid = p.id
        AND IDVetting21.name = 'IDVetting21'    
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting22--Vetting Passed
        ON IDVetting22.personcenter = p.center
        AND IDVetting22.personid = p.id
        AND IDVetting22.name = 'IDVetting22'    
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting3--Has a Parental Consent form been uploaded for a member aged 18 or under
        ON IDVetting3.personcenter = p.center
        AND IDVetting3.personid = p.id
        AND IDVetting3.name = 'IDVetting3'    
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting4--In the event of third party payer, does the payer National ID/Passport details matched & uploaded
        ON IDVetting4.personcenter = p.center
        AND IDVetting4.personid = p.id
        AND IDVetting4.name = 'IDVetting4'   
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting5--Have the payment details passed the duplicate check
        ON IDVetting5.personcenter = p.center
        AND IDVetting5.personid = p.id
        AND IDVetting5.name = 'IDVetting5' 
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting6--Has a credit card front page or DD Mini Statement been uploaded
        ON IDVetting6.personcenter = p.center
        AND IDVetting6.personid = p.id
        AND IDVetting6.name = 'IDVetting6'   
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting7--Has a DD/CC Local Card Mandate form been uploaded
        ON IDVetting7.personcenter = p.center
        AND IDVetting7.personid = p.id
        AND IDVetting7.name = 'IDVetting7' 
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting8--Has the DD/CC Local Card Mandate been completed correctly
        ON IDVetting8.personcenter = p.center
        AND IDVetting8.personid = p.id
        AND IDVetting8.name = 'IDVetting8' 
LEFT JOIN
        evolutionwellness.person_ext_attrs IDVetting9--Do the billing details match the supporting documents
        ON IDVetting9.personcenter = p.center
        AND IDVetting9.personid = p.id
        AND IDVetting9.name = 'IDVetting9'                                                                                                                                                                                                                     
WHERE
        p.center IN (:Scope)
	AND 
	s.creation_time BETWEEN params.FromDate AND params.ToDate
		     