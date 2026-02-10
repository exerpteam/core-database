-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    per.center || 'p' || per.id              AS company_ID,
    per."LASTNAME"                           AS company_name,
    per.Address1|| ' ' ||per.Address2        as company_Address, 
    per.zipcode                              as company_zip,
    per.status				    			 as company_state,	
    per.ssn                                  as company_CVR,
	per.co_name								 as "C/O Name",
    email.txtvalue                           as contact_email,
    Kommentar.txtvalue                       as Kommentar,
    contact.CENTER||'p'||contact.id          as contact_Id,
    contact.FIRSTNAME||' '||contact.LASTNAME as Contact_name,
    manager.center||'p'||manager.id          AS managerID,
    manager.Firstname||' '||manager.lastname AS managerName,
 billingNo.txtvalue as BillingNo
     
FROM
    fw.persons per
LEFT JOIN fw.relatives rel
    ON
        per.center = rel.center
    AND per.id = rel.id
    AND rel.rtype = 7
    and rel.status = 1
LEFT JOIN fw.PERSONS contact
    ON
        contact.center = rel.RELATIVECENTER
    AND contact.id = rel.RELATIVEID
LEFT JOIN fw.relatives rel2
    ON
        per.center = rel2.center
    AND per.id = rel2.id
    AND rel2.rtype = 10
    and rel2.status = 1
LEFT JOIN fw.PERSONS manager
    ON
        manager.center = rel2.RELATIVECENTER
    AND manager.id = rel2.RELATIVEID
LEFT JOIN fw.Person_Ext_Attrs Email 
    ON 
        contact.center = Email.PersonCenter 
    AND contact.id = Email.PersonId 
    AND Email.Name  = '_eClub_Email' 
LEFT JOIN fw.PERSON_EXT_ATTRS Kommentar 
    ON 
        Kommentar.personcenter = per.center 
    and Kommentar.personid = per.id 
    and Kommentar.name  = '_eClub_Comment' 
LEFT JOIN fw.PERSON_EXT_ATTRS billingNo 
    ON 
        billingNo.personcenter = per.center 
    and billingNo.personid = per.id 
    and billingNo.name  = '_eClub_BillingNumber' 
WHERE
     per.sex = 'C'
order by
     per.center || 'p' || per.id
