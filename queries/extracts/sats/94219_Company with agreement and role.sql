      SELECT distinct
           cag.CENTER || 'p' || cag.ID                            AS CompanyId,      
           comp.FULLNAME                                          AS CompanyName,
             cag.NAME                                            AS CompanyAgreementName,          
         --  cag.CENTER || 'p' || cag.ID || 'rpt' || cag.SUBID      AS CompanyAgreementId,
           CASE cag.STATE  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'STOP_NEW'  ELSE 'UNKNOWN' END AS AgreementStatus,
           r.rolename as "Required role name"
         
         FROM
             PERSONS comp
         
         JOIN
             COMPANYAGREEMENTS cag
         ON
            
             comp.CENTER = cag.CENTER
             AND comp.ID = cag.ID
        left join roles r
        on
        r.id = cag.roleid
        
        
       
         WHERE
            comp.center IN ($$Scope$$)
            
            AND cag.STATE IN (1)
           
 