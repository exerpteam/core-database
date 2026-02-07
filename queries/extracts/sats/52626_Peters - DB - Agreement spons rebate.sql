SELECT

-- Company -- 9

  company_center||'p'||company_id                 AS "Company ID",
  company_external_id                             AS "Company External ID",


-- Agreement -- 5

  agreement_ref_id                                AS "Agreement Ref ID",
  agreement_name                                  AS "Agreement Name",
  company_agreement                               AS "Company Agreement",
  agreement_status                                AS "Agreement Status",
  agreement_STOP_NEW_DATE                         AS "Agreement Stop New Date",
  count(center)                                   AS "Active Members On Agreement",
  agreement_blocked                               AS "Agreement Blocked",
  documentation_required                          AS "Documentation Required",
  documentation_interval_unit                     AS "Documentation Interval Unit",
  documentation_interval                          AS "Documentation Interval",
  EMPLOYEE_NUMBER_REQUIRED                        AS "Employee Number Required",
  
  

/*
  rolename                                         AS "Rolename",
  center                                           AS "Customers On Agreement",
*/
  privilege_set_name	        		           AS "Privilege Set Name",
  sponsorship_name                                 AS "Sponsorship Name",
  sponsorship_amount                               AS "Amount / Percentage",


-- Manager -- 5

  manager_fullname				          AS KAM_Fullname,
--  manager_firstname				          AS KAM_Firstname,
--  manager_middlename			          AS KAM_middlename,
--  manager_lastname				          AS KAM_Lastname
  manager_id	

FROM

  (
    SELECT DISTINCT

-- Company -- 3

      comp.center                                   AS company_center,
      comp.id                                       AS company_id,
      comp.external_id                              AS company_external_id,

-- Agreement -- 

    ca.name                                                         AS agreement_name,
    ca.ref                                                            AS agreement_ref_id,
    ca.center || 'p' || ca.id || 'rpt' || ca.subid                  AS company_agreement,
    ca.blocked                                                      AS agreement_blocked,
    DECODE(ca.STATE, 0, 'Lead', 1, 'Active', 2, 'Stop new', 3, 'Old', 4, 'Awaiting activation', 5, 'Blocked', 6, 'Deleted')                                                          AS agreement_status,
    ca.stop_new_date                                                AS agreement_STOP_NEW_DATE,
    p.center                                                        AS center,
	p.id,
    DECODE(ca.documentation_required, 0,'NO', 1,'Yes')              AS documentation_required,
    DECODE(ca.DOCUMENTATION_INTERVAL_UNIT, 0, 'DAY', 1, 'WEEK', 2, 'MONTH', 3, 'YEAR')                                                                                                              AS documentation_interval_unit,
    ca.DOCUMENTATION_INTERVAL                                       AS documentation_interval,
    ca.EMPLOYEE_NUMBER_REQUIRED                                     AS EMPLOYEE_NUMBER_REQUIRED,
  /*    ro.ROLENAME                                       AS rolename,
      p.center                                   AS center,
   --   p.id                                              AS id,
*/
      pg.sponsorship_name                               AS sponsorship_name,
      pg.sponsorship_amount                             AS sponsorship_amount,
      ps.name                                           AS privilege_set_name,


-- Manager -- 5   

      manager.fullname            			      AS manager_fullname,
      manager.firstname            			      AS manager_firstname,
      manager.middlename            			  AS manager_middlename,
      manager.lastname            			      AS manager_lastname,
      manager.center||'p'||manager.id             AS manager_id

    FROM
      sats.persons comp

-- Agreements --

        JOIN
            sats.companyagreements ca
        ON
            ca.center = comp.center
            AND ca.id = comp.id
            -- AND ca.state = 1 -- active
        LEFT JOIN
            SATS.RELATIVES rel3
        ON
            rel3.RELATIVECENTER = ca.CENTER
            AND rel3.RELATIVEID = ca.ID
            AND rel3.RELATIVESUBID = ca.SUBID
            AND rel3.RTYPE = 3
        LEFT JOIN
            sats.persons p
        ON
            rel3.CENTER = p.CENTER
            AND rel3.ID = p.ID
            AND rel3.status IN (1) -- active
            AND p.STATUS IN (1,3)



            ----- Filter out free membership product groups ----
        LEFT JOIN
            subscriptions freesub
        ON
            freesub.OWNER_CENTER = p.center
            AND p.id = freesub.OWNER_ID
        LEFT JOIN
            products subfree
        ON
            freesub.SUBSCRIPTIONTYPE_CENTER = subfree.CENTER
            AND freesub.SUBSCRIPTIONTYPE_ID = subfree.ID
        LEFT JOIN
            SATS.PRODUCT_AND_PRODUCT_GROUP_LINK papg
        ON
            papg.PRODUCT_CENTER = subfree.CENTER
            AND papg.PRODUCT_ID = subfree.ID
        LEFT JOIN
            SATS.PRODUCT_GROUP freepg
        ON
            freepg.ID = papg.PRODUCT_GROUP_ID
            ----- Filter out free membership product groups ----
        LEFT JOIN
            SATS.PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_SERVICE = 'CompanyAgreement'
            AND pg.GRANTER_CENTER = ca.CENTER
            AND pg.GRANTER_ID = ca.ID
            AND pg.GRANTER_SUBID = ca.SUBID
            AND pg.VALID_FROM <= exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI'))
            AND (
                pg.VALID_TO IS NULL
                OR pg.VALID_TO > exerpro.dateToLong(TO_CHAR(exerpsysdate(), 'YYYY-MM-dd HH24:MI')) )
        LEFT JOIN
            SATS.PRIVILEGE_SETS ps
        ON
            pg.PRIVILEGE_SET = ps.ID and ps.STATE = 'ACTIVE'
     /*   LEFT JOIN
            SATS.ROLES ro
*/

-- Manager --

    LEFT JOIN
      sats.relatives rel2
    ON
      comp.center = rel2.center
    AND
      comp.id = rel2.id
    AND
      rel2.rtype = 10 -- manager
    AND
      rel2.status = 1
      
    LEFT JOIN
      sats.persons manager
    ON
      manager.center = rel2.RELATIVECENTER
    AND 
      manager.id = rel2.RELATIVEID

    WHERE
      comp.sex = 'C' 
    AND comp.center IN ($$scope$$)
    ) 

GROUP BY

-- Company -- 9

    company_center||'p'||company_id, 
    company_external_id,

-- Agreement --

company_center||'p'||company_id, 
company_external_id, agreement_ref_id, 
agreement_name, company_agreement, 
agreement_status, 
agreement_STOP_NEW_DATE, 
agreement_blocked, 
documentation_required, 
documentation_interval_unit, 
documentation_interval, 
EMPLOYEE_NUMBER_REQUIRED,


-- Manager -- 5

	manager_fullname,
    manager_firstname,
  	manager_middlename,
  	manager_lastname,
    manager_id,


       /*rolename, 
    center
  */  
 
    privilege_set_name, 
    sponsorship_name,
    sponsorship_amount


ORDER BY
    company_center||'p'||company_id,
agreement_name