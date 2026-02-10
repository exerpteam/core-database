-- The extract is extracted from Exerp on 2026-02-08
--  
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
SELECT DISTINCT
        p.center||'p'||p.id AS "Member id"
        ,p.fullname AS "Member name"
        ,prod.name AS "Subscription name"
        ,s.start_date AS "Subscription start date"
        ,oldend.effect_date AS "Original end date"
        ,sc.effect_date AS "New end date"
        ,CASE
                WHEN s.sub_state = 8 THEN 'Delete'
                Else 'Stop'
        END AS "Type"
        ,CASE -- SHOULD BE UPDATES ONCE CONFIGURED IN PRODUCTION
              WHEN qa.result_code = 'DUP' THEN 'Duplicate payment'
              WHEN qa.result_code = 'CLOSE' THEN 'Club closed or converted'
              WHEN qa.result_code = 'HEALTH' THEN 'Health issues/deceased'
              WHEN qa.result_code = 'PT' THEN 'PT classes not conducted/club reason' 
              WHEN qa.result_code = 'AGE' THEN 'Age related issues'  
              WHEN qa.result_code = 'LEGAL' THEN 'Disciplinary/Legal Status issues'  
              WHEN qa.result_code = 'CORP' THEN 'Corporate related issues'  
              WHEN qa.result_code = 'OTHER' THEN 'Other issues'                 
              Else qa.result_code
        END AS "Reason"
        ,CASE
                WHEN creditnote.total_amount IS NOT NULL THEN creditnote.total_amount
                ELSE 0
        END AS "Credit amount"
        ,TO_CHAR(longtodate(sc.change_time),'yyyy-MM-dd') AS "Date processed"
        ,empp.fullname AS "Employee"
        ,CASE
                WHEN spempp2.fullname IS NOT NULL THEN spempp2.fullname 
                ELSE spempp.fullname 
        END AS "Original sales employee"      
FROM
        leejam.subscriptions s 
JOIN
        leejam.subscription_change sc
        ON sc.old_subscription_center = s.center
        AND sc.old_subscription_id = s.id
        AND sc.type = 'END_DATE'
        AND sc.cancel_time IS NULL
JOIN
        (SELECT
                max(sco.id) AS ID
                ,sco.old_subscription_center
                ,sco.old_subscription_id
        FROM
                leejam.subscription_change sco  
        WHERE
                sco.type = 'END_DATE'
                AND
                sco.cancel_time IS NOT NULL
        GROUP BY
                sco.old_subscription_center
                ,sco.old_subscription_id
        )prev
        ON prev.old_subscription_center = sc.old_subscription_center
        AND prev.old_subscription_id = sc.old_subscription_id
JOIN
        leejam.subscription_change oldend
        ON oldend.id = prev.ID
        AND oldend.old_subscription_center = prev.old_subscription_center 
        AND oldend.old_subscription_id = prev.old_subscription_id
JOIN
        leejam.persons p                                       
        ON p.center = s.owner_center
        AND p.id = s.owner_id
JOIN
        leejam.subscriptiontypes st
        ON s.subscriptiontype_center = st.center
        AND s.subscriptiontype_id = st.id                        
JOIN                        
        leejam.products prod
        ON st.center = prod.center
        AND st.id = prod.id
JOIN
        leejam.employees emp
        ON emp.center = sc.employee_center
        AND emp.id = sc.employee_id
JOIN
        leejam.persons empp
        ON empp.center = emp.personcenter
        AND empp.id = emp.personid
JOIN
        leejam.employees spemp
        ON spemp.center = s.creator_center
        AND spemp.id = s.creator_id
JOIN
        leejam.persons spempp
        ON spempp.center = spemp.personcenter
        AND spempp.id = spemp.personid
LEFT JOIN
        leejam.subscription_sales ss
        ON ss.subscription_center = s.center
        AND ss.subscription_id = s.id
LEFT JOIN
        leejam.employees spemp2
        ON spemp2.center = ss.employee_center
        AND spemp2.id = ss.employee_id
LEFT JOIN
        leejam.persons spempp2
        ON spempp2.center = spemp2.personcenter
        AND spempp2.id = spemp2.personid
LEFT JOIN
        (SELECT
                cnl.total_amount
                ,cn.trans_time
                ,s.center
                ,s.id                
        FROM
                leejam.credit_notes cn
        JOIN
                leejam.credit_note_lines_mt cnl
                ON cn.center = cnl.center
                AND cn.id = cnl.id 
        JOIN
                leejam.spp_invoicelines_link sppinvlnk
                ON sppinvlnk.invoiceline_center = cnl.invoiceline_center
                AND sppinvlnk.invoiceline_id = cnl.invoiceline_id
                AND sppinvlnk.invoiceline_subid = cnl.invoiceline_subid        
        JOIN
                subscriptionperiodparts spp
                ON spp.center = sppinvlnk.period_center
                AND spp.id = sppinvlnk.period_id
                AND spp.subid = sppinvlnk.period_subid
        JOIN
                leejam.subscriptions s                
                ON s.center = spp.center
                AND s.id = spp.id
        JOIN 
                params 
                ON params.CENTER_ID = cn.center                
        WHERE
                cnl.reason IN (8,14)
                AND
                cn.trans_time BETWEEN params.FromDate AND params.ToDate
        )creditnote
        ON creditnote.center = s.center
        AND creditnote.id = s.id
        AND TO_CHAR(longtodate(creditnote.trans_time),'yyyy-MM-dd') =  TO_CHAR(longtodate(sc.change_time),'yyyy-MM-dd')
JOIN 
        params 
        ON params.CENTER_ID = p.center
JOIN
        journalentries jrn
        ON jrn.person_center = p.center
        AND jrn.person_id = p.id
        AND jrn.jetype = 18
        AND TO_CHAR(longtodate(jrn.creation_time),'yyyy-MM-dd') =  TO_CHAR(longtodate(sc.change_time),'yyyy-MM-dd')
LEFT JOIN
        (SELECT Max(Subid) as maxid,center,id 
        FROM questionnaire_answer
        WHERE questionnaire_campaign_id = 1 -- SHOULD BE UPDATES ONCE CONFIGURED IN PRODUCTION 
        GROUP BY center,id) q
        ON q.center = p.center
        AND q.id = p.id
LEFT JOIN 
        questionnaire_answer qa
        ON qa.center = q.center
        AND qa.id = q.id
        AND qa.subid = q.maxid                
WHERE
        sc.employee_center ||'emp'||sc.employee_id != '100emp1'
        AND
        sc.change_time BETWEEN params.FromDate AND params.ToDate
        AND
        p.center in (:Scope)