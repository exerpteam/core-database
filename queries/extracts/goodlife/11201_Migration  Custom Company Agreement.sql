SELECT
		p.lastname AS "Company_Name",
     	p.external_id AS "Company_ID",
	    p.ssn AS "SalesForce_ID",
		ca.center || 'p' || ca.id || 'rpt' || ca.subid AS "Company_Agr_Nbr",
        (CASE 
                WHEN p.address1 IS NULL THEN
                        p.zipcode || ' ' || p.city || ' ' || p.country
                WHEN p.address2 IS NULL THEN
                        p.address1 || ' ' || p.zipcode || ' ' || p.city || ' ' || ct.name
                WHEN p.address3 IS NULL THEN
                        p.address1 || ' ' || p.address2 || ' ' || p.zipcode || ' ' || p.city || ' ' || ct.name
                ELSE
                        p.address1 || ' ' || p.address2  || p.address3 || ' ' || p.zipcode || ' ' || p.city || ' ' || ct.name
         END) AS "Address",
         inv_email.txtvalue AS "Invoice_Mail",
         commentt.txtvalue AS "Comment",
         accountManager.fullname AS "Key_Account_Manager",
         (CASE
                WHEN contactPerson.fullname IS NULL AND workPhoneContact.txtvalue IS NULL AND emailContact.txtvalue IS NULL THEN
                        NULL
                ELSE                     
                        contactPerson.fullname || ' ' || workPhoneContact.txtvalue || ' ' || emailContact.txtvalue
          END) AS "Contact",
          ca.stop_new_date AS "Stop_New_Date",
		  ca.cash_subscription_stop_date AS "Stop_New",
          string_agg(ps.name, ' - ') AS "Privilege_Set_Name",
		  pg.sponsorship_name AS "Sponsorship",
		  (pg.sponsorship_amount*100) AS "Sponsorship_Amount",
		  (CASE
		  		WHEN pg.sponsorship_rounding IS NULL 
		  		THEN 'No' 
		  		ELSE 'Yes' END) AS "Sponsorship_Rounding",
          compType.txtvalue AS "Company_Type",
          compStartD.txtvalue AS "Company_Start_Date",
          compCERTStart.txtvalue AS "Company_CERT_Start_Date",
          compAnniStart.txtvalue AS "Company_Anniversary_Date",
          certMethod.txtvalue AS "CERT_Auth_Method",
          certLongText.txtvalue AS "CERT_Auth_Long_Text",
          certShortText.txtvalue AS "CERT_Auth_Short_Text",
          certLongFrText.txtvalue AS "CERT_Auth_Long_French_Text",
          certShortFrText.txtvalue AS "CERT_Auth_Short_French_Text",
          certDomain.txtvalue AS "CERT_Domain_Auth",
           CASE ca.state
        WHEN 0
        THEN 'Under target'
        WHEN 1
        THEN 'Active'
        WHEN 2
        THEN 'Stop New'
        WHEN 3
        THEN 'Old'
        WHEN 4
        THEN 'Awaiting Activiation'
        WHEN 5
        THEN 'Blocked'
        WHEN 6
        THEN 'DELETED'
        ELSE 'UNKNOWN'
    END AS "Company Agreement Status",
    ca.documentation_required "Require Documentation",
    r.rolename AS "Required role",
    (CASE ca.family_corporate_status
        WHEN 0 THEN 'EMPLOYEES'
        WHEN 1 THEN 'EMPLOYEES_AND_CORPORATE_FAMILY'
        WHEN 2 THEN 'CORPORATE_FAMILY'
        ELSE NULL
     END) AS "Corporate relation",
     ca.max_family_corporate AS "Maximum family members",
     ca.require_other_payer "Require Other Payer"
FROM persons p
LEFT JOIN companyagreements ca
        ON ca.center = p.center
           AND ca.id = p.id   
LEFT JOIN goodlife.privilege_grants pg
        ON pg.granter_center = ca.center
           AND pg.granter_id = ca.id
           AND pg.granter_subid = ca.subid
           AND pg.valid_to IS NULL
LEFT JOIN goodlife.privilege_sets ps 
        ON ps.id = pg.privilege_set  
LEFT JOIN countries ct
        ON ct.id = p.country    
LEFT JOIN person_ext_attrs inv_email
        ON inv_email.personcenter = p.center
           AND inv_email.personid = p.id
           AND inv_email.name = '_eClub_InvoiceEmail'
LEFT JOIN person_ext_attrs commentt
        ON commentt.personcenter = p.center
           AND commentt.personid = p.id
           AND commentt.name = '_eClub_Comment'
LEFT JOIN relatives relaccount
        ON relaccount.center = p.center
           AND relaccount.id = p.id
           AND relaccount.rtype=10
           AND relaccount.status = 1
LEFT JOIN persons accountManager
        ON accountManager.center = relaccount.relativecenter
           AND accountManager.id = relaccount.relativeid
LEFT JOIN relatives relcontact
        ON relcontact.center = p.center
           AND relcontact.id = p.id
           AND relcontact.rtype = 7
           AND relcontact.status = 1
LEFT JOIN persons contactPerson
        ON contactPerson.center = relcontact.relativecenter
           AND contactPerson.id = relcontact.relativeid
LEFT JOIN person_ext_attrs workPhoneContact
        ON workPhoneContact.personcenter = contactPerson.center
           AND workPhoneContact.personId = contactPerson.id
           AND workPhoneContact.name = '_eClub_PhoneWork'
LEFT JOIN person_ext_attrs emailContact
        ON emailContact.personcenter = contactPerson.center
           AND emailContact.personId = contactPerson.id
           AND emailContact.name = '_eClub_Email'
LEFT JOIN person_ext_attrs compType
        ON compType.personcenter = p.center
           AND compType.personid = p.id
           AND compType.name = 'COMPANYTYPE'
LEFT JOIN person_ext_attrs compStartD
        ON compStartD.personcenter = p.center
           AND compStartD.personid = p.id
           AND compStartD.name = 'COMPANYSTARTDATE'
LEFT JOIN person_ext_attrs compCERTStart
        ON compCERTStart.personcenter = p.center
           AND compCERTStart.personid = p.id
           AND compCERTStart.name = 'COMPANYCERTSTARTDATE'
LEFT JOIN person_ext_attrs compAnniStart
        ON compAnniStart.personcenter = p.center
           AND compAnniStart.personid = p.id
           AND compAnniStart.name = 'COMPANYANNIVERSARYDATE'
LEFT JOIN person_ext_attrs certMethod
        ON certMethod.personcenter = p.center
           AND certMethod.personid = p.id
           AND certMethod.name = 'CERTAUTHMETHOD'
LEFT JOIN person_ext_attrs certLongText
        ON certLongText.personcenter = p.center
           AND certLongText.personid = p.id
           AND certLongText.name = 'CERTAUTHLONGTEXT'         
LEFT JOIN person_ext_attrs certShortText
        ON certShortText.personcenter = p.center
           AND certShortText.personid = p.id
           AND certShortText.name = 'CERTAUTHSHORTTEXT'    
LEFT JOIN person_ext_attrs certLongFrText
        ON certLongFrText.personcenter = p.center
           AND certLongFrText.personid = p.id
           AND certLongFrText.name = 'CERTAUTHLONGTEXTFR'
LEFT JOIN person_ext_attrs certShortFrText
        ON certShortFrText.personcenter = p.center
           AND certShortFrText.personid = p.id
           AND certShortFrText.name = 'CERTAUTHSHORTTEXTFR'
LEFT JOIN person_ext_attrs certDomain
        ON certDomain.personcenter = p.center
           AND certDomain.personid = p.id
           AND certDomain.name = 'CERTDOMAINLIST'     
LEFT JOIN goodlife.roles r
        ON r.id = ca.roleid                
WHERE
        p.sex='C'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31