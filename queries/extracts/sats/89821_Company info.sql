-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
     company_name,
     company_center||'p'||company_id AS company_id,
     company_registration,
 --    agreement_name,
 --    CompanyAgreement,
     COUNT(center)                 as customers_on_agreement_active_temp_inactive,
     COUNT(centerinactive)         as customers_on_agreement_inactive,
        manager_name as "key account manager"
  --   CASE  documentation_required  WHEN 1 THEN 'Yes'  WHEN 2 THEN --'No' END as documentation_required
-- Stop_new_joins_date
 FROM
     (
         SELECT DISTINCT
             comp.lastname                                  AS company_name,
             comp.center                                    AS company_center,
             comp.id                                        AS company_id,
             comp.ssn                                       AS company_registration,
             comp.Address1 || ' ' || comp.Address2          AS company_Address,
             comp.zipcode                                   AS company_zip,
      --       ca.name                                        AS agreement_name,
  --           ca.center || 'p' || ca.id || 'rpt' || ca.subid    CompanyAgreement,
-- ca.DOCUMENTATION_REQUIRED,
                   p.center,
             p.id,
             p2.center as centerinactive,
              manager.fullname                AS manager_name,
             manager.center||'p'||manager.id AS managerID
      --  ca.STOP_NEW_DATE as Stop_new_joins_date
         FROM
             persons comp
         LEFT JOIN
             relatives rel
         ON
             comp.center = rel.center
             AND comp.id = rel.id
             AND rel.rtype = 7 -- contact
             AND rel.status = 1
           
        
         LEFT JOIN
             relatives rel2
         ON
             comp.center = rel2.center
             AND comp.id = rel2.id
             AND rel2.rtype = 10 -- manager
             AND rel2.status = 1
         LEFT JOIN
             persons manager
         ON
             manager.center = rel2.RELATIVECENTER
             AND manager.id = rel2.RELATIVEID
        left JOIN
             companyagreements ca
         ON
             ca.center = comp.center
             AND ca.id = comp.id
             -- AND ca.state = 1 -- active
         LEFT JOIN
             RELATIVES rel3
         ON
             rel3.RELATIVECENTER = ca.CENTER
             AND rel3.RELATIVEID = ca.ID
             AND rel3.RELATIVESUBID = ca.SUBID
             AND rel3.RTYPE = 3
         LEFT JOIN
             persons p
         ON
             rel3.CENTER = p.CENTER
             AND rel3.ID = p.ID
             AND rel3.status IN (1) -- active
            AND p.STATUS IN (1,3)
             ----- Filter out free membership product groups ---
         LEFT JOIN
             persons p2
         ON
             rel3.CENTER = p2.CENTER
             AND rel3.ID = p2.ID
             AND rel3.status IN (1) -- active
            AND p2.STATUS IN (2)    
      
         WHERE
             comp.sex = 'C'
             AND comp.center IN ($$scope$$)
             ----- Filter out free memberships product group ----
             ) t
 GROUP BY
     company_name,
     company_center||'p'||company_id,
     company_registration,
     -- CompanyAgreement,
   --    agreement_name,
        manager_name,
     managerID
     --  documentation_required,
 --Stop_new_joins_date
  HAVING
     COUNT(center) >= 0 and
      COUNT(centerinactive) >= 0
 ORDER BY
     company_name,
     company_id
    -- agreement_name