SELECT
  company_name 					          AS Company_Name,
  company_center||'p'||company_id AS Company_ID,
  company_external_id				 AS Company_External_ID,
  company_registration			      AS Corprate_Identity,
  company_address1				        AS Address_Row_1,
  company_address2				        AS Address_Row_2,
  company_zip						          AS Postal_Code,
  company_city					          AS City,
  company_country						  AS Company_Country,
  company_email					          AS Company_Email,
  comp_comment					          AS Company_Comment,
  emp_target						          AS Company_Target,
  manager_name					          AS Key_Account_Manager,
  manager_id						          AS Key_Account_ID,
  mother_company				          AS Mother_Company,
  mother_id						            AS Mother_Company_ID,
  contact_name					          AS Company_Contact,
  contact_id						          AS Company_Contact_ID,
  contact_phone					          AS Company_Contact_Phone,
  contact_email					          AS Company_Contact_Email
FROM
  (
    SELECT DISTINCT
      comp.lastname                               AS company_name,
      comp.center                                 AS company_center,
      comp.id                                     AS company_id,
      comp.external_id                              AS company_external_id,
      comp.ssn                                    AS company_registration,
      comp.Address1 							                AS company_address1,
      comp.Address2  								              AS company_address2,
      comp.zipcode                                AS company_zip,
      comp.city                                   AS company_city,
	  comp.country								  AS company_country,
      manager.fullname                			      AS manager_name,
      manager.center||'p'||manager.id             AS manager_id,
      contact.fullname                            AS contact_name,
      contact.CENTER||'p'||contact.id             AS contact_id,
      contact_phone.TxtValue                      AS contact_phone,
      Contact_email.TxtValue                      AS contact_email,
      Company_email.TxtValue                      AS company_email,
      Comp_comment.TXTVALUE                       AS comp_comment,
      Company_emp_num.TXTVALUE                    AS emp_target,
      mc.LASTNAME						                      AS mother_company,
      mc.center||'p'||mc.id 			                AS mother_id
    FROM
      sats.persons comp
    LEFT JOIN 
      sats.relatives rel4 
    ON
      rel4.RELATIVECENTER = comp.CENTER AND
      rel4.RELATIVEID = comp.ID
    LEFT JOIN 
      sats.persons mc 
    ON
      mc.CENTER = rel4.CENTER AND
      mc.id = rel4.ID
    AND
      (rel4.RTYPE IS NULL OR rel4.RTYPE = 6) -- mother company
    AND 
      rel4.status = 1
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

    LEFT JOIN
      sats.person_Ext_Attrs Comp_comment
    ON
      comp.center = Comp_comment.personCenter
    AND
      comp.id = Comp_comment.personId
    AND
      Comp_comment.Name = '_eClub_Comment'

    LEFT JOIN
      sats.person_Ext_Attrs Company_email
    ON
      comp.center = Company_email.personCenter
    AND
      comp.id = Company_email.personId
    AND
      Company_email.Name = '_eClub_Email'

    LEFT JOIN
      sats.person_Ext_Attrs Company_emp_num
    ON
      comp.center = Company_emp_num.personCenter
    AND
      comp.id = Company_emp_num.personId
    AND
      Company_emp_num.Name = '_eClub_TargetNumberOfEmployees'

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
/*  JOIN
      sats.companyagreements ca
    ON
      ca.center = comp.center
    AND
      ca.id = comp.id
    --AND ca.state = 1 -- active
    LEFT JOIN
      SATS.RELATIVES rel3
    ON
      rel3.RELATIVECENTER = ca.CENTER
    AND
      rel3.RELATIVEID = ca.ID
    AND
      rel3.RELATIVESUBID = ca.SUBID
    AND
      rel3.RTYPE = 3
    LEFT JOIN
      sats.persons p
    ON
      rel3.CENTER = p.CENTER
    AND
      rel3.ID = p.ID
    AND
      rel3.status IN (1) -- active
    AND
      p.STATUS IN (1,3)
      
    ----- Filter out free membership product groups ----
    
    LEFT JOIN
      subscriptions freesub
    ON
      freesub.OWNER_CENTER = p.center
    AND
      p.id = freesub.OWNER_ID
    
    LEFT JOIN
      products subfree
    ON
      freesub.SUBSCRIPTIONTYPE_CENTER = subfree.CENTER
    AND
      freesub.SUBSCRIPTIONTYPE_ID = subfree.ID
    LEFT JOIN
      SATS.PRODUCT_AND_PRODUCT_GROUP_LINK papg
    ON
      papg.PRODUCT_CENTER = subfree.CENTER
    AND
      papg.PRODUCT_ID = subfree.ID
    
    LEFT JOIN
      SATS.PRODUCT_GROUP freepg
    ON
      freepg.ID = papg.PRODUCT_GROUP_ID
    
    ----- Filter out free membership product groups ----
    
    LEFT JOIN
      SATS.PRIVILEGE_GRANTS pg
    ON
      pg.GRANTER_SERVICE = 'CompanyAgreement'
    AND
      pg.GRANTER_CENTER = ca.CENTER
    AND
      pg.GRANTER_ID = ca.ID
    AND
      pg.GRANTER_SUBID = ca.SUBID
    AND
      pg.VALID_FROM <= exerpro.dateToLong(TO_CHAR(SYSDATE, 'YYYY-MM-dd HH24:MI'))
    AND (
          pg.VALID_TO IS NULL
        OR 
          pg.VALID_TO > exerpro.dateToLong(TO_CHAR(SYSDATE, 'YYYY-MM-dd HH24:MI')) 
        )
    LEFT JOIN
      SATS.PRIVILEGE_SETS ps
    ON
      pg.PRIVILEGE_SET = ps.ID and ps.STATE = 'ACTIVE'
    LEFT JOIN
      SATS.ROLES ro
    ON
      ro.id = ca.ROLEID*/
    WHERE
      comp.sex = 'C' 
    AND comp.center IN ($$scope$$)
      
      ----- Filter out free memberships product group ---
      --AND freepg.ID ! = 127 
    )

--HAVING
--    COUNT(center) > 0

GROUP BY
    company_name,
    company_center||'p'||company_id, 
	company_external_id,
    company_registration,
    company_address1,
    company_address2,
    company_zip,
    company_city,
  	company_country,
    company_email,
    comp_comment,
    emp_target,
    manager_name,
    manager_id,
    mother_company,
    mother_id,
    contact_name,
    contact_id,
    contact_phone,
    contact_email
ORDER BY
    company_name