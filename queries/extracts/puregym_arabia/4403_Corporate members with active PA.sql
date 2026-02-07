 select
 P.CENTER||'p'||P.ID AS MEMBER_ID,
 CASE pag.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN  'Transfer' WHEN 17 THEN 'Agreement signature missing' END as AGREEMENT_STATE,
 PAG.ENDED_REASON_TEXT,
 CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARY INACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS PERSON_STATUS
 from persons p
 join ACCOUNT_RECEIVABLES ar on p.center = ar.CUSTOMERCENTER and p.id = ar.CUSTOMERID
 join PAYMENT_ACCOUNTS pa on ar.CENTER = pa.CENTER and ar.ID = pa.ID
 join PAYMENT_AGREEMENTS pag on pa.ACTIVE_AGR_CENTER = pag.CENTER and pa.ACTIVE_AGR_ID = pag.ID and pa.ACTIVE_AGR_SUBID = pag.SUBID
 where pag.STATE in (1,2,4) and p.PERSONTYPE = 4 and p.STATUS in (1,3)