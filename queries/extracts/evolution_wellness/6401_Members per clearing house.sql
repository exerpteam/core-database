-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
 ch.NAME                        AS "Clearinghouse",
 pcc.NAME                       AS "Payment cycle",
 p.external_id                  AS "External Id",
 p.CENTER || 'p' || p.ID        AS "MEMBER ID",
 p.fullname                     AS Name,
 CASE pag.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 'Ended, creditor' WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' WHEN 15 THEN 'Transfer' WHEN 16 THEN 'Agreement Recreated' WHEN 17 THEN 'Signature missing' ELSE 'UNDEFINED' END                                
                                AS "Status",
 pag.EXAMPLE_REFERENCE          AS KID,
 CASE pcc.RENEWAL_POLICY WHEN 5 THEN 'prepaid' WHEN 9 THEN 'postpaid' ELSE 'Undefined' END      
                                AS "Agreement policy",
 a.name                         AS scope,
 pag.ref                        AS "Exerp reference", 
 rp.center||'p'||rp.id          AS "Payer"

 FROM PAYMENT_AGREEMENTS pag
 JOIN CLEARINGHOUSES ch ON ch.ID = pag.CLEARINGHOUSE
 JOIN PAYMENT_ACCOUNTS pac ON pac.ACTIVE_AGR_CENTER = pag.CENTER AND pac.ACTIVE_AGR_ID = pag.ID AND pac.ACTIVE_AGR_SUBID = pag.SUBID
 JOIN ACCOUNT_RECEIVABLES ar ON pac.CENTER = ar.CENTER AND pac.ID = ar.ID AND ar.AR_TYPE = 4
 JOIN PERSONS p ON p.CENTER = ar.CUSTOMERCENTER AND p.ID = ar.CUSTOMERID
 LEFT JOIN RELATIVES r ON r.CENTER = p.CENTER AND r.ID = p.ID AND r.RTYPE = 12 AND r.STATUS < 2
 LEFT JOIN PERSONS mem ON mem.CENTER = r.RELATIVECENTER AND mem.ID = r.RELATIVEID
 LEFT JOIN RELATIVES r2 ON r2.RELATIVECENTER = p.CENTER AND r2.RELATIVEID = p.ID AND r2.RTYPE = 12 AND r2.STATUS < 2
 JOIN CH_AND_PCC_LINK ch_pcc ON ch_pcc.CLEARING_HOUSE_ID = pag.CLEARINGHOUSE
 JOIN PAYMENT_CYCLE_CONFIG pcc ON ch_pcc.PAYMENT_CYCLE_ID = pcc.ID and pcc.id = pag.PAYMENT_CYCLE_CONFIG_ID
 JOIN AREAS a ON ch.SCOPE_ID = a.ID
 
  ---finding active other payer for not active persons
 LEFT JOIN RELATIVES rp ON rp.RELATIVECENTER = p.CENTER AND rp.RELATIVEID = p.ID 
 AND rp.RTYPE = 12 ---12 Other payer
 AND rp.STATUS = 1 ---1 active 
 AND p.status != 1 ---1 active

 WHERE ( 
 ( r.CENTER IS NULL AND p.STATUS IN (1, 3) ) ---1 active. 3 temp inactive
 OR ( 
 r.CENTER IS NOT NULL AND mem.STATUS IN (1, 3) )  
 OR ( 
 p.sex IN ('C') )
 )
 AND p.CENTER IN (:Scope)
 AND pag.CLEARINGHOUSE IN (:Clearinghouse)