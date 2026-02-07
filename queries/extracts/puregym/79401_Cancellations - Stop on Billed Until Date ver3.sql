 -- 2. Stop on BUD
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
     acl.LOG_DATE,
     CASE pag.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN
     'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN
     'Ended, creditor' WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN
     'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' END AS DDIState,
     acl.TEXT                                                                        AS ReasonCode
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
 JOIN
     (
         SELECT
             acl2.AGREEMENT_CENTER,
             acl2.AGREEMENT_id,
             acl2.AGREEMENT_SUBID,
             acl2.state,
             MAX(acl2.id) AS Id
         FROM
             AGREEMENT_CHANGE_LOG acl2
                         where (acl2.text is null or acl2.text not like 'Deduction day%')
         GROUP BY
             acl2.AGREEMENT_center,
             acl2.AGREEMENT_id,
             acl2.AGREEMENT_SUBID,
             acl2.state ) acl3
 ON
     acl3.AGREEMENT_center = pag.center
     AND acl3.AGREEMENT_id = pag.id
     AND acl3.AGREEMENT_subid = pag.subid
     AND acl3.state = pag.STATE
 LEFT JOIN
     AGREEMENT_CHANGE_LOG acl
 ON
     acl.ID = acl3.id
 LEFT JOIN
     PRODUCTS prod
 ON
     prod.CENTER = st.CENTER  AND  prod.ID = st.ID
 WHERE
     mac.CENTER IS NOT NULL
 and
         pag.STATE NOT IN (1,2,4,15)
     AND ((pag.state = 6 and acl.text is null) or acl.text IN ('Cancelled by payer',
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
     -- to review:
     --and acl.text not in ('Cancelled by payer', 'Instruction cancelled', 'Cancelled, Refer to
     -- payer', 'No account','No instruction','Payer deceased','Account closed')
     --stop on bud
     AND (
         ar.balance = 0)
     AND sub.BILLED_UNTIL_DATE IS NOT NULL
     AND (
         sub.END_DATE IS NULL
         OR sub.end_date > sub.BILLED_UNTIL_DATE)
     AND prod.GLOBALID not like ('BUDDY_SUBSCRIPTION%')
     AND p.PERSONTYPE != 2
     AND pag.center IN (:scope)
         --and pag.center not in (147, 141, 149, 123)