 SELECT DISTINCT
     p.center || 'p' || p.id pid,
     CASE pag.STATE WHEN 1 THEN 'Created' WHEN 2 THEN 'Sent' WHEN 3 THEN 'Failed' WHEN 4 THEN 'OK' WHEN 5 THEN 'Ended, bank' WHEN 6 THEN 
     'Ended, clearing house' WHEN 7 THEN 'Ended, debtor' WHEN 8 THEN 'Cancelled, not sent' WHEN 9 THEN 'Cancelled, sent' WHEN 10 THEN 
     'Ended, creditor' WHEN 11 THEN 'No agreement (deprecated)' WHEN 12 THEN 'Cash payment (deprecated)' WHEN 13 THEN 
     'Agreement not needed (invoice payment)' WHEN 14 THEN 'Agreement information incomplete' END agreement_state
     ,
     pcc2.NAME AS "Agreement Cycle",
     CASE pcc2.RENEWAL_POLICY WHEN 4 THEN 'Postpaid' WHEN 5 THEN 'Prepaid' ELSE 'else' END "Agreement Policy",
     ch.id    AS "Clearing House ID",
     ch.NAME  AS "Clearing House Name",
     a.NAME   AS "Scope",
     pcc.NAME AS "Clearing House Cycle",
     CASE pcc.RENEWAL_POLICY WHEN 4 THEN 'Postpaid' WHEN 5 THEN 'Prepaid' ELSE 'else' END "Clearing House Policy",
     SUM(
         CASE
             WHEN pcc.COMPANY = 1
             AND p.SEX ='C'
             AND p.STATUS IN (0,1,3,8)
             THEN 1
             WHEN pcc.COMPANY = 0
             AND p.SEX IN('M',
                          'F')
             AND p.status IN (1,3)
             THEN 1
             ELSE 0
         END) AS "Members Count",
     CASE
         WHEN pcc2.id !=pcc.id
         THEN 'Yes'
         ELSE 'No'
     END AS Different_Cycles,
 p.state,
  case p.status when 1 then 'Active' when 3 then 'TemporaryInactive' else 'Undefined' end AS PersonStatus
 FROM
     PERSONS p
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     p.CENTER = ar.CUSTOMERCENTER
 AND p.id = ar.CUSTOMERID
 AND ar.AR_TYPE = 4
 JOIN
     PAYMENT_ACCOUNTS pac
 ON
     pac.CENTER = ar.CENTER
 AND pac.ID = ar.ID
 JOIN
     PAYMENT_AGREEMENTS pag
 ON
     pac.ACTIVE_AGR_CENTER = pag.CENTER
 AND pac.ACTIVE_AGR_ID = pag.ID
 AND pac.ACTIVE_AGR_SUBID = pag.SUBID
 JOIN
     PAYMENT_CYCLE_CONFIG pcc2
 ON
     pag.PAYMENT_CYCLE_CONFIG_ID = pcc2.id
 JOIN
     CLEARINGHOUSES ch
 ON
     ch.ID = pag.CLEARINGHOUSE
 JOIN
     CH_AND_PCC_LINK ch_pcc
 ON
     ch_pcc.CLEARING_HOUSE_ID = pag.CLEARINGHOUSE
 JOIN
     PAYMENT_CYCLE_CONFIG pcc
 ON
     ch_pcc.PAYMENT_CYCLE_ID = pcc.ID
 JOIN
     AREAS a
 ON
     ch.SCOPE_ID = a.ID
 WHERE
     p.center IN ($$scope$$)
     AND p.status IN ('1','3') --active, inactive
 GROUP BY
     p.center,
     p.id,
     pcc2.NAME,
     CASE pcc2.RENEWAL_POLICY WHEN 4 THEN 'Postpaid' WHEN 5 THEN 'Prepaid' ELSE 'else' END,
     ch.id,
     ch.NAME,
     a.NAME,
     pcc.NAME,
     pag.STATE,
     pcc.RENEWAL_POLICY,
     pcc2.id,
     pcc.id,
     p.state
