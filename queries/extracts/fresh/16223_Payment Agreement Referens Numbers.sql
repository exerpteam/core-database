
SELECT 
  p.CENTER || 'p' || p.ID AS "Member_ID", 
  p.FIRSTNAME || ' ' || p.LASTNAME "Full_Name", 
  pag.REF,
  DECODE(pag.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete',15,'Transfer',16,'Agreement Recreated',17, 'Signature missing', 'UNDEFINED') AS Payment_State,
  pag.ACTIVE
FROM
  PERSONS p
JOIN
  ACCOUNT_RECEIVABLES ar
ON 
  ar.CUSTOMERCENTER = p.CENTER and ar.CUSTOMERID = p.ID
JOIN
  PAYMENT_ACCOUNTS pac
ON 
  pac.center = ar.center AND pac.ID = ar.ID AND ar.AR_TYPE = 4
JOIN
  PAYMENT_AGREEMENTS pag
ON 
  pac.ACTIVE_AGR_CENTER = pag.center AND pac.ACTIVE_AGR_ID = pag.ID AND pac.ACTIVE_AGR_SUBID = pag.SUBID
WHERE
p.CENTER = (:scope)