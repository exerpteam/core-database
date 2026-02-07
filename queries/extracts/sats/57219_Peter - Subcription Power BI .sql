SELECT

-- Company -- 9
  --subscription_id								AS "Subscription ID",
 -- company_center||'p'||company_id                 AS "Company ID",
 -- company_external_id                             AS "Company External ID",
 -- company_country						  			AS Visiting_Country,
 -- company_emp_target			          			AS Company_Target,

--  mother_company				          AS Mother_Company,
 -- mother_id						          AS Mother_Company_ID,
 -- mother_status							  AS Mother_Status,

-- Contact -- 7

  --contact_fullname				          AS Company_Contact_Fullname,
  --contact_firstname				          AS Company_Contact_Firstname,
  --contact_middlename			          AS Company_Contact_Middlename,
  --contact_lastname				          AS Company_Contact_Lastname,
  --contact_id						      AS Company_Contact_ID,
  --contact_phone					          AS Company_Contact_Phone,
 -- contact_email					          AS Company_Contact_Email,


-- Agreement -- 5

  agreement_ref_id                                AS "Agreement Ref ID",
 -- agreement_name                                  AS "Agreement Name",
  --agreement_code								  AS "Agreement External ID",
  company_agreement                               AS "Agreement ID",
 -- agreement_status                                AS "Agreement Status",
 -- agreement_STOP_NEW_DATE                         AS "Agreement Stop New Date",
--  count(center)                                   AS "Active Members On Agreement",
 -- agreement_blocked                               AS "Agreement Blocked",
--  documentation_required                          AS "Documentation Required",
 -- documentation_interval_unit                     AS "Documentation Interval Unit",
--  documentation_interval                          AS "Documentation Interval",
 -- EMPLOYEE_NUMBER_REQUIRED                        AS "Employee Number Required",
  
  

/*
  rolename                                         AS "Rolename",
  center                                           AS "Customers On Agreement",
*/
 -- privilege_set_name	        		           AS "Privilege Set Name",
 -- sponsorship_name                                 AS "Sponsorship Name",
 -- sponsorship_amount                               AS "Amount / Percentage",
 -- privilege_set_id	        		           AS "Privilege Set Id",


-- Manager -- 5

-- manager_fullname				          AS KAM_Fullname,
--  manager_firstname				          AS KAM_Firstname,
--  manager_middlename			          AS KAM_middlename,
--  manager_lastname				          AS KAM_Lastname
--  manager_id	

FROM

  (
    SELECT DISTINCT

-- Company -- 3

      comp.center                                   AS company_center,
      comp.id                                       AS company_id,
      comp.external_id                              AS company_external_id,
	  comp.country								    AS company_country,

-- Contact -- 7

      contact.fullname                            AS contact_fullname,
      contact.firstname                           AS contact_firstname,
      contact.middlename                          AS contact_middlename,
      contact.lastname                            AS contact_lastname,
      contact.CENTER||'p'||contact.id             AS contact_id,
      contact_phone.TxtValue                      AS contact_phone,
      Contact_email.TxtValue                      AS contact_email,
 


-- Agreement -- 

    ca.name                                                         AS agreement_name,
	ca.external_id												    AS agreement_code,
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
      ps.id                                           AS privilege_set_id,





-- Manager -- 5   

      manager.fullname            			      AS manager_fullname,
      manager.firstname            			      AS manager_firstname,
      manager.middlename            			  AS manager_middlename,
      manager.lastname            			      AS manager_lastname,
      manager.center||'p'||manager.id             AS manager_id,

      Company_emp_num.TXTVALUE                    AS company_emp_target,

-- Mother Company -- 3     

      mc.LASTNAME						          AS mother_company,
      mc.status 			                      AS mother_status,
      mc.center||'p'||mc.id 			          AS mother_id

-- Subscritpion --

	--subscription.id								  AS subscription_id	

    FROM
      sats.persons comp

-- Contact --

   LEFT JOIN
      sats.relatives rel
    ON
      comp.center = rel.center
    AND 
      comp.id = rel.id
    AND 
      rel.rtype = 7 -- contact
    AND 
      rel.status = 1

    LEFT JOIN
      sats.persons contact
    ON
      contact.center = rel.RELATIVECENTER
    AND
      contact.id = rel.RELATIVEID
   LEFT JOIN
      sats.person_Ext_Attrs Contact_phone
    ON
      contact.center = contact_phone.personCenter
    AND
      contact.id = contact_phone.personId
    AND 
      contact_phone.Name = '_eClub_PhoneWork'

    LEFT JOIN
      sats.person_Ext_Attrs Contact_email
    ON
      contact.center = contact_email.personCenter
    AND
      contact.id = contact_email.personId
    AND
      contact_email.Name = '_eClub_Email'
-- Mother Company --

    LEFT JOIN 
      sats.relatives rel4 
    ON
      comp.CENTER = rel4.RELATIVECENTER
    AND
      comp.ID = rel4.RELATIVEID 
    AND
      --((rel4.RTYPE IS NULL) OR (rel4.RTYPE = 6 AND rel4.status = 1)) -- mother company
      --(rel4.RTYPE IS NOT NULL OR rel4.RTYPE = 6) -- mother company
      rel4.RTYPE = 6 -- mother company 
    AND 
      rel4.status = 1

    LEFT JOIN 
      sats.persons mc 
    ON
      mc.CENTER = rel4.CENTER AND
      mc.id = rel4.ID-- Mother Company --

    LEFT JOIN 
      sats.relatives rel4 
    ON
      comp.CENTER = rel4.RELATIVECENTER
    AND
      comp.ID = rel4.RELATIVEID 
    AND
      --((rel4.RTYPE IS NULL) OR (rel4.RTYPE = 6 AND rel4.status = 1)) -- mother company
      --(rel4.RTYPE IS NOT NULL OR rel4.RTYPE = 6) -- mother company
      rel4.RTYPE = 6 -- mother company 
    AND 
      rel4.status = 1

    LEFT JOIN 
      sats.persons mc 
    ON
      mc.CENTER = rel4.CENTER AND
      mc.id = rel4.ID


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



  /*          ----- Filter out free membership product groups ----
        LEFT JOIN
            subscriptions subscription
        ON
            subscription.OWNER_CENTER = p.center
            AND p.id = subscription.OWNER_ID
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

*/
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

-- Employee number --

    LEFT JOIN
      sats.person_Ext_Attrs Company_emp_num
    ON
      comp.center = Company_emp_num.personCenter
    AND
      comp.id = Company_emp_num.personId
    AND
      Company_emp_num.Name = '_eClub_TargetNumberOfEmployees'

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
	  --subscription_id,
    company_center||'p'||company_id, 
    company_external_id,
	company_country,

-- Agreement --

company_center||'p'||company_id, 
company_external_id, agreement_ref_id, 
agreement_name, company_agreement, agreement_code,
agreement_status, 
agreement_STOP_NEW_DATE, 
agreement_blocked, 
documentation_required, 
documentation_interval_unit, 
documentation_interval, 
EMPLOYEE_NUMBER_REQUIRED,
company_emp_target,

-- Manager -- 5

	manager_fullname,
    manager_firstname,
  	manager_middlename,
  	manager_lastname,
    manager_id,

-- Contact -- 7

    contact_fullname,
    contact_firstname,
    contact_middlename,
    contact_lastname,
    contact_id,
    contact_phone,
    contact_email,

-- Mother Company -- 3

    mother_company,
    mother_id,
    mother_status, 

       /*rolename, 
    center
  */  
 
    privilege_set_name, 
    sponsorship_name,
    sponsorship_amount,
privilege_set_id


ORDER BY
    company_center||'p'||company_id,
agreement_name