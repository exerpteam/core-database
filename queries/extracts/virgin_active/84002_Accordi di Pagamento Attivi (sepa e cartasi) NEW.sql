-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
   TO_CHAR(longtodateTZ(acl.entry_time, 'Europe/Rome'),'DD-MM-YYYY')  "Dt_act_PaymentAgreement",
 clh.name "Clearinghouse name",
     p.CENTER "Person center",
     p.ID "Person ID",
	 p.external_id,
     p.FULLNAME,
     pa.CENTER "Agreement Center" ,
     pa.ID "Agreement ID",
     pa.SUBID,
     --pa.BANK_NAME,
     --pa.BANK_CONTROL_DIGITS,
     --pa.BANK_ACCNO,
     --pa.BANK_ACCOUNT_HOLDER,
     --pa.IBAN,
     --pa.BIC,
     --pa.EXAMPLE_REFERENCE,
     --pa.REF,
     pa.NOTIFY_PAYMENT
 FROM
     PERSONS p
 LEFT JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = p.CENTER
 AND ar.CUSTOMERID = p.ID
 AND ar.AR_TYPE = 4
 LEFT JOIN
     PAYMENT_ACCOUNTS pac
 ON
     pac.CENTER = ar.CENTER
 AND pac.ID = ar.ID
 LEFT JOIN
     PAYMENT_AGREEMENTS pa
 ON
     pa.CENTER = pac.ACTIVE_AGR_CENTER
 AND pa.ID = pac.ACTIVE_AGR_ID
 AND pa.SUBID = pac.ACTIVE_AGR_SUBID
 JOIN
     AGREEMENT_CHANGE_LOG acl
 ON
     pa.id = acl.agreement_id
 AND pa.center = acl.agreement_center
 join clearinghouses clh
 on
 clh.id = pa.CLEARINGHOUSE
 WHERE
  p.center IN ($$Scope$$)
         AND LongTODate(acl.entry_time) >= $$FromDate$$
         AND LongTODate(acl.entry_time) <= $$ToDate$$
 and
     p.CENTER IN
     (
         SELECT
             c.ID
         FROM
             CENTERS c
         WHERE
             c.COUNTRY = 'IT' )
 --AND pa.CLEARINGHOUSE = 803
 and acl.state = 4
 and pa.state = 4
