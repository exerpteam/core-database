 SELECT per.center||'p'|| per.id "Person",
 CASE pag.STATE  WHEN 1 THEN 'CREATED'  WHEN 2 THEN 'SENT'  WHEN 3 THEN 'FAILED'  WHEN 4 THEN 'AGREEMENT CONFIRMED'  WHEN 5 THEN 
     'ENDED BY DEBITOR''S BANK'  WHEN 6 THEN 'ENDED BY THE CLEARING HOUSE'  WHEN 7 THEN 'ENDED BY DEBITOR'  WHEN 8 THEN 
     'SHAL BE CANCELLED'  WHEN 9 THEN 'END REQUEST SENT'  WHEN 10 THEN 'AGREEMENT ENDED BY CREDITOR'  WHEN 11 THEN 
     'NO AGREEMENT WITH DEBITOR'  WHEN 12 THEN 'DEPRICATED'  WHEN 13 THEN 'NOT NEEDED' WHEN 14 THEN 'INCOMPLETE' WHEN 15 THEN 'TRANSFERRED'
      ELSE 'UNKNOWN' END "State" ,
  TO_CHAR(longtodateTZ(pag.creation_time , 'Europe/Rome'),'DD-MM-YYYY')  "Creation Time"
 FROM
 persons per
 JOIN
 account_receivables acr
 ON
 acr.customercenter = per.center
 AND acr.customerid = per.id
 JOIN
 payment_agreements pag
 ON
 acr.id=pag.id
 AND acr.center=pag.center
 JOIN
 agreement_change_log acl
 ON
 acl.agreement_center = pag.center
 AND acl.agreement_id = pag.id
 and pag.subid = acl.AGREEMENT_SUBID
 WHERE
 acl.text = 'API'
 and acl.employee_id = '14202'
 and pag.creation_time > 1514761212000
