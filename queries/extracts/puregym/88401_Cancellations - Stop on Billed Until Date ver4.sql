 WITH sublist1 AS (
 SELECT
     p.center||'p'||p.id as member_key,
     p.FULLNAME,
     pag.ref,
     pag.BANK_ACCOUNT_HOLDER,
     CASE sub.STATE  WHEN 2 THEN  'ACTIVE'  WHEN 4 THEN  'FROZEN'  WHEN 8 THEN  'CREATED' END AS SubscriptionState,
     sub.start_date,
     sub.BILLED_UNTIL_DATE,
     sub.end_date,
     longtodate(pag.CREATION_TIME) AS DDI_CREATED,
     ar.balance,
     ccc.STARTDATE AS DEBT_START,
     ccc.AMOUNT,
     CASE pag.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN
     'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN
     'Ended, creditor' WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN
     'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' END AS DDIState
     ,pag.center as center,
     pag.id as id,
     pag.subid as subid,
     pag.state as state
 FROM
     persons p
 JOIN
     SUBSCRIPTIONS sub
 ON
     sub.OWNER_CENTER = p.center
     AND sub.OWNER_ID = p.id
     AND sub.state IN (2,4,8)
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     st.center = sub.SUBSCRIPTIONTYPE_CENTER
     AND st.id = sub.SUBSCRIPTIONTYPE_ID
     AND st.ST_TYPE = 1
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = st.CENTER  
     AND prod.ID = st.ID
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = p.center
     AND ar.CUSTOMERID = p.id
 JOIN
     PAYMENT_ACCOUNTS pa
 ON
     pa.CENTER = ar.CENTER
     AND pa.id = ar.id
 JOIN
     PAYMENT_AGREEMENTS pag
 ON
     pag.center = pa.ACTIVE_AGR_CENTER
     AND pag.id = pa.ACTIVE_AGR_ID
     AND pag.subid = pa.ACTIVE_AGR_SUBID
 LEFT JOIN
     CASHCOLLECTIONCASES mac
 ON
     mac.PERSONCENTER = p.center
     AND mac.PERSONID = p.id
     AND mac.CLOSED = 0
     AND mac.MISSINGPAYMENT = 0
 LEFT JOIN
     CASHCOLLECTIONCASES ccc
 ON
     ccc.PERSONCENTER = p.center
     AND ccc.PERSONID = p.id
     AND ccc.CLOSED = 0
     AND ccc.MISSINGPAYMENT = 1
  WHERE
     pag.center IN (:scope)
     AND mac.CENTER IS NOT NULL
     AND pag.STATE NOT IN (1,2,4,15)
     AND ar.balance = 0
     AND sub.BILLED_UNTIL_DATE IS NOT NULL
     AND (
         sub.END_DATE IS NULL
         OR sub.end_date > sub.BILLED_UNTIL_DATE)
     AND prod.GLOBALID not like ('BUDDY_SUBSCRIPTION%')
     AND p.PERSONTYPE != 2
 ), sublist2 AS
 (
 SELECT
     sl.*, acl.text, acl.log_date,
     RANK() OVER (PARTITION BY acl.AGREEMENT_CENTER, acl.AGREEMENT_ID, acl.AGREEMENT_SUBID, acl.STATE ORDER BY acl.id DESC) AS acl_rank
 FROM
     sublist1 sl
 JOIN 
     agreement_change_log acl
 ON     
     acl.AGREEMENT_center = sl.center
     AND acl.AGREEMENT_id = sl.id
     AND acl.AGREEMENT_subid = sl.subid
     AND acl.state = sl.STATE
WHERE
   (acl.text is null or acl.text not like 'Deduction day%')
AND ((sl.state = 6 and acl.text is null) or acl.text IN ('Cancelled by payer',
                      'Instruction cancelled',
                      'Cancelled, Refer to payer',
                      'No account',
                      'No instruction',
                      'Payer deceased',
                      'Account closed',
                      'Instruction cancelled by payer',
                         'Invalid account type',
                          'Bank will not accept DDI on ac',
                          'Payer reference not unique'))

)
select * from sublist2      
where acl_rank = 1