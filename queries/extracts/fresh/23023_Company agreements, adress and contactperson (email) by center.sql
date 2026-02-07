 Select
     ca.center                           as agreement_company_center,
     ca.id                               as agreement_company_id,
     ca.subid                            as agreement_sub_ID,
     p2.lastname                         as company_name,
     persons.firstname                   as Contact_first_name,
     persons.lastname                    as Contact_last_name,
     p2.Address1 || ' ' || p2.Address2 as company_Address,
     p2.zipcode as company_zip,
     ca.name as agreement,
     email.txtvalue as contact_email
 FROM
     companyagreements ca
 LEFT JOIN
     Person_Ext_Attrs Email
     ON
     ca.contactcenter = Email.PersonCenter
     AND ca.contactid = Email.PersonId
     AND Email.Name   = '_eClub_Email'
 JOIN
     persons p2
     ON
     ca.center = p2.Center
     AND ca.ID = p2.ID
 LEFT JOIN
     persons
     ON
     ca.contactcenter = persons.Center
     AND ca.contactID = persons.ID
 LEFT JOIN
     RELATIVES rel
     ON
     persons.CENTER = rel.RELATIVECENTER
     AND persons.ID = rel.RELATIVEID
     and rel.RTYPE  = 7
 WHERE
     p2.SEX        = 'C'
     and ca.state  = 1
 and ca.center >= :fromCenter and
  ca.center <= :toCenter
 GROUP by
     ca.center,
     ca.id,
     ca.subid,
     p2.lastname,
     persons.firstname,
     persons.lastname,
     p2.Address1 || ' ' || p2.Address2,
     p2.zipcode,
     ca.name,
     email.txtvalue
 ORDER BY
     ca.center,
     ca.id,
     ca.subid
