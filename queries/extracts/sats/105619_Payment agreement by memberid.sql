SELECT distinct
 ch.NAME                        AS "Clearinghouse",
 pcc.NAME                       AS "Payment cycle",
 p.external_id                  AS "External ID",
 p.CENTER || 'p' || p.ID        AS "Member ID",
 p.fullname                     AS "Name",
 case when p.sex = 'C'
      then 'company'
      else 'private member' END as "type",      
pr.name                         as "subscriptionname",
 s.subscription_price,
 CASE pag.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' ELSE 'UNDEFINED' END 
                                AS "Status",
 pag.EXAMPLE_REFERENCE          AS "KID",
 CASE pcc.RENEWAL_POLICY WHEN 5 THEN 'prepaid' WHEN 9 THEN 'postpaid' ELSE 'Undefined' END 
                                AS "Agreement policy",
 a.name                         AS "Scope",
  pag.ref                        AS "Exerp reference",
  pag.state,
 mem.center||'p'||mem.id        AS "Paying for",
 --s.center||'ss'||s.id           AS "Subscription ID", 
 pr.name                        AS "Membership",
 CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END 
                                AS "Person Type",
 rp.center||'p'||rp.id          AS "Payer",
 comp.fullname,
 pg.sponsorship_name
 

 FROM PAYMENT_AGREEMENTS pag
 JOIN CLEARINGHOUSES ch ON ch.ID = pag.CLEARINGHOUSE
 JOIN PAYMENT_ACCOUNTS pac ON pac.ACTIVE_AGR_CENTER = pag.CENTER AND pac.ACTIVE_AGR_ID = pag.ID AND pac.ACTIVE_AGR_SUBID = pag.SUBID
 JOIN ACCOUNT_RECEIVABLES ar ON pac.CENTER = ar.CENTER AND pac.ID = ar.ID AND ar.AR_TYPE = 4 ---4 Payment account
 JOIN PERSONS p ON p.CENTER = ar.CUSTOMERCENTER AND p.ID = ar.CUSTOMERID
 JOIN SUBSCRIPTIONS S on s.owner_center = p.center and s.owner_id = p.id
 
 JOIN CH_AND_PCC_LINK ch_pcc ON ch_pcc.CLEARING_HOUSE_ID = pag.CLEARINGHOUSE
 JOIN PAYMENT_CYCLE_CONFIG pcc ON ch_pcc.PAYMENT_CYCLE_ID = pcc.ID and pcc.id = pag.PAYMENT_CYCLE_CONFIG_ID
 JOIN AREAS a ON ch.SCOPE_ID = a.ID
 JOIN subscriptiontypes st ON st.center = s.subscriptiontype_center AND st.id = s.subscriptiontype_id 
 JOIN products pr ON pr.center = st.center AND pr.id = st.id
 
 ---finding active other payer for not active persons
 LEFT JOIN RELATIVES rp ON rp.RELATIVECENTER = p.CENTER AND rp.RELATIVEID = p.ID 
 AND rp.RTYPE = 12 ---12 Other payer
 AND rp.STATUS = 1 ---1 active 
 AND p.status != 1 ---1 active
 LEFT JOIN RELATIVES r ON r.CENTER = p.CENTER AND r.ID = p.ID AND r.RTYPE = 12 ---12 Other payer
 AND r.STATUS < 2 ---0 lead. 1 active 
 LEFT JOIN PERSONS mem ON mem.CENTER = r.RELATIVECENTER AND mem.ID = r.RELATIVEID
 LEFT JOIN RELATIVES r2 ON r2.RELATIVECENTER = p.CENTER AND r2.RELATIVEID = p.ID AND r2.RTYPE = 12 AND r2.STATUS < 2
 
 left JOIN
             RELATIVES r3
         ON
             p.CENTER = r3.CENTER
             AND p.ID = r3.ID
            AND r3.RTYPE = 3
             AND r3.STATUS < 3
     left JOIN
             COMPANYAGREEMENTS cag
         ON
             cag.CENTER = r3.RELATIVECENTER
             AND cag.ID = r3.RELATIVEID
             AND cag.SUBID = r3.RELATIVESUBID
         left JOIN
             PERSONS comp
         ON
             comp.CENTER = cag.CENTER
             AND comp.ID = cag.ID
left JOIN privilege_grants pg ON  pg.GRANTER_CENTER = cag.CENTER AND pg.GRANTER_ID = cag.ID AND pg.GRANTER_SUBID = cag.SUBID  AND pg.GRANTER_SERVICE = 'CompanyAgreement'             
 
left JOIN  PRIVILEGE_SETS ps ON   PG.PRIVILEGE_SET = ps.ID 
 
 WHERE 
 
 (pg.valid_to is null or pg.valid_to > datetolong('2024-09-24'))
 and (p.center,p.id) in (:memberid)
--and  s.state IN (2,4)