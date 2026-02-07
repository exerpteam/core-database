 SELECT
 -- Company -- 9
   company_name                                            AS Company_Name,
   company_center||'p'||company_id         AS Company_ID,
 --  company_status                          AS Company_Status,
 --  company_external_id                               AS Company_External_ID,
   company_registration                            AS Corprate_Identity,
   company_email                                           AS Company_Email,
   company_phone                                           AS Company_Phone,
   company_comment                                             AS Company_Comment,
   company_emp_target                              AS Company_Target,
 -- Visiting Adress -- 6
   company_co_name                                     AS Visiting_CO_Name,
   company_address1                                        AS Visiting_Address1,
   company_address2                                        AS Visiting_Address2,
   company_zip                                                 AS Visiting_Postal_Code,
   company_city                                            AS Visiting_City,
   company_country                                                 AS Visiting_Country,
 -- Invoice Adress -- 8
   company_invoice_co_name                                 AS Invoice_CO_Name,
   company_invoice_adress1                                 AS Invoice_Adress1,
   company_invoice_adress2                                 AS Invoice_Adress2,
   company_invoice_zipcode                                 AS Invoice_Zipcode,
   company_invoice_city                                    AS Invoice_City,
   company_invoice_country                                 AS Invoice_Ccountry,
   company_invoice_email                                   AS Invoice_Email,
 --  company_billing_id                                AS Invoice_Billing_ID,
 -- Manager -- 5
   manager_fullname                                        AS KAM_Fullname,
 --  manager_firstname                                     AS KAM_Firstname,
 --  manager_middlename                            AS KAM_middlename,
 --  manager_lastname                                      AS KAM_Lastname,
   manager_id                                                  AS Key_Account_ID,
 -- Mother Company -- 3
   mother_company                                          AS Mother_Company,
   mother_id                                                       AS Mother_Company_ID,
   mother_status                                                   AS Mother_Status,
 -- Contact -- 7
   contact_fullname                                        AS Company_Contact_Fullname,
   contact_firstname                                       AS Company_Contact_Firstname,
   contact_middlename                              AS Company_Contact_Middlename,
   contact_lastname                                        AS Company_Contact_Lastname,
   contact_id                                                  AS Company_Contact_ID,
   contact_phone                                           AS Company_Contact_Phone,
   contact_email                                           AS Company_Contact_Email
 FROM
   (
     SELECT DISTINCT
 -- Company -- 9
       comp.lastname                               AS company_name,
       comp.center                                 AS company_center,
       comp.id                                     AS company_id,
       comp.status                                 AS company_status,
       comp.external_id                            AS company_external_id,
       comp.ssn                                    AS company_registration,
       Company_email.TxtValue                      AS company_email,
       Company_phone.TxtValue                      AS company_phone,
       Company_comment.TXTVALUE                    AS company_comment,
       Company_emp_num.TXTVALUE                    AS company_emp_target,
 -- Visitng Adress -- 6
       comp.co_name                                                                AS company_co_name,
       comp.Address1                                                       AS company_address1,
       comp.Address2                                                       AS company_address2,
       comp.zipcode                                AS company_zip,
       comp.city                                   AS company_city,
           comp.country                                                            AS company_country,
 -- Invoice adress -- 8
           invoice_adress.TxtValue                                         AS company_invoice_adress1,
           invoice_adress2.TxtValue                                        AS company_invoice_adress2,
           invoice_adress5.TxtValue                                        AS company_invoice_zipcode,
           invoice_zipcode.city                                            AS company_invoice_city,
           invoice_adress3.TxtValue                                        AS company_invoice_co_name,
           invoice_adress4.TxtValue                                        AS company_invoice_country,
           invoice_adress6.TxtValue                                        AS company_invoice_email,
       Company_billing_id.TXTVALUE                 AS company_billing_id,
 -- Manager -- 5
       manager.fullname                                        AS manager_fullname,
       manager.firstname                                       AS manager_firstname,
       manager.middlename                                  AS manager_middlename,
       manager.lastname                                        AS manager_lastname,
       manager.center||'p'||manager.id             AS manager_id,
 -- Mother Company -- 3
       mc.LASTNAME                                                         AS mother_company,
       mc.status                                               AS mother_status,
       mc.center||'p'||mc.id                               AS mother_id,
 -- Contact -- 7
       contact.fullname                            AS contact_fullname,
       contact.firstname                           AS contact_firstname,
       contact.middlename                          AS contact_middlename,
       contact.lastname                            AS contact_lastname,
       contact.CENTER||'p'||contact.id             AS contact_id,
       contact_phone.TxtValue                      AS contact_phone,
       Contact_email.TxtValue                      AS contact_email
     FROM
       persons comp
 -- Mother Company --
     LEFT JOIN
       relatives rel4
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
       persons mc
     ON
       mc.CENTER = rel4.CENTER AND
       mc.id = rel4.ID
 -- Contact --
    LEFT JOIN
       relatives rel
     ON
       comp.center = rel.center
     AND
       comp.id = rel.id
     AND
       rel.rtype = 7 -- contact
     AND
       rel.status = 1
     LEFT JOIN
       persons contact
     ON
       contact.center = rel.RELATIVECENTER
     AND
       contact.id = rel.RELATIVEID
    LEFT JOIN
       person_Ext_Attrs Contact_phone
     ON
       contact.center = contact_phone.personCenter
     AND
       contact.id = contact_phone.personId
     AND
       contact_phone.Name = '_eClub_PhoneWork'
     LEFT JOIN
       person_Ext_Attrs Contact_email
     ON
       contact.center = contact_email.personCenter
     AND
       contact.id = contact_email.personId
     AND
       contact_email.Name = '_eClub_Email'
 -- Invoice --
    LEFT JOIN
       person_Ext_Attrs invoice_adress
     ON
       comp.center = invoice_adress.personCenter
     AND
       comp.id = invoice_adress.personId
     AND
       invoice_adress.Name = '_eClub_InvoiceAddress1'
    LEFT JOIN
       person_Ext_Attrs invoice_adress2
     ON
       comp.center = invoice_adress2.personCenter
     AND
       comp.id = invoice_adress2.personId
     AND
       invoice_adress2.Name = '_eClub_InvoiceAddress2'
    LEFT JOIN
       person_Ext_Attrs invoice_adress3
     ON
       comp.center = invoice_adress3.personCenter
     AND
       comp.id = invoice_adress3.personId
     AND
       invoice_adress3.Name = '_eClub_InvoiceCoName'
    LEFT JOIN
       person_Ext_Attrs invoice_adress4
     ON
       comp.center = invoice_adress4.personCenter
     AND
       comp.id = invoice_adress4.personId
     AND
       invoice_adress4.Name = '_eClub_InvoiceCountry'
   LEFT JOIN
       person_Ext_Attrs invoice_adress5
     ON
       comp.center = invoice_adress5.personCenter
     AND
       comp.id = invoice_adress5.personId
     AND
       invoice_adress5.Name = '_eClub_InvoiceZipCode'
   LEFT JOIN
           ZIPCODES invoice_zipcode
     ON
           invoice_zipcode.zipcode = invoice_adress5.TxtValue
         AND
           invoice_zipcode.country = comp.country
   LEFT JOIN
       person_Ext_Attrs invoice_adress6
     ON
       comp.center = invoice_adress6.personCenter
     AND
       comp.id = invoice_adress6.personId
     AND
       invoice_adress6.Name = '_eClub_InvoiceEmail'
 -- Ext attributes Company --
     LEFT JOIN
       person_Ext_Attrs Company_comment
     ON
       comp.center = Company_comment.personCenter
     AND
       comp.id = Company_comment.personId
     AND
       Company_comment.Name = '_eClub_Comment'
     LEFT JOIN
       person_Ext_Attrs Company_billing_id
     ON
       comp.center = Company_billing_id.personCenter
     AND
       comp.id = Company_billing_id.personId
     AND
       Company_billing_id.Name = '_eClub_BillingNumber'
     LEFT JOIN
       person_Ext_Attrs Company_email
     ON
       comp.center = Company_email.personCenter
     AND
       comp.id = Company_email.personId
     AND
       Company_email.Name = '_eClub_Email'
     LEFT JOIN
       person_Ext_Attrs Company_phone
     ON
       comp.center = Company_phone.personCenter
     AND
       comp.id = Company_Phone.personId
     AND
       Company_Phone.Name = '_eClub_PhoneSMS'
     LEFT JOIN
       person_Ext_Attrs Company_emp_num
     ON
       comp.center = Company_emp_num.personCenter
     AND
       comp.id = Company_emp_num.personId
     AND
       Company_emp_num.Name = '_eClub_TargetNumberOfEmployees'
 -- Manager --
     LEFT JOIN
       relatives rel2
     ON
       comp.center = rel2.center
     AND
       comp.id = rel2.id
     AND
       rel2.rtype = 10 -- manager
     AND
       rel2.status = 1
     LEFT JOIN
       persons manager
     ON
       manager.center = rel2.RELATIVECENTER
     AND
       manager.id = rel2.RELATIVEID
     WHERE
       comp.sex = 'C'
     AND comp.center IN ($$scope$$)
     ) t1
 GROUP BY
 -- Company -- 9
     company_name,
     company_center||'p'||company_id,
     company_status,
         company_external_id,
     company_registration,
     company_email,
     company_phone,
         company_comment,
     company_emp_target,
 -- Visiting Adress -- 6
     company_co_name,
     company_address1,
     company_address2,
     company_zip,
     company_city,
         company_country,
 -- Invoice Adress -- 8
     company_invoice_co_name,
     company_invoice_adress1,
     company_invoice_adress2,
     company_invoice_zipcode,
     company_invoice_city,
     company_invoice_country,
     company_invoice_email,
         company_billing_id,
 -- Manager -- 5
         manager_fullname,
     manager_firstname,
         manager_middlename,
         manager_lastname,
     manager_id,
 -- Mother Company -- 3
     mother_company,
     mother_id,
     mother_status,
 -- Contact -- 7
     contact_fullname,
     contact_firstname,
     contact_middlename,
     contact_lastname,
     contact_id,
     contact_phone,
     contact_email
 ORDER BY
     company_name,
     mother_id,
     company_id
