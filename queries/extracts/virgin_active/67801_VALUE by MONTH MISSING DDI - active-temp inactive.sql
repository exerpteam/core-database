SELECT
         t1.AccountBalance AS "Account Balance",
         s.BINDING_END_DATE AS "Binding Date",
         cs.NAME AS "Club",
         email.TXTVALUE AS "Email",
         t1.FullName AS "Full Name",
         t1.MemberStatus AS "Member status",
         t1.Gross AS "Gross DD Sent for the Period",
         pr.NAME AS "Membership Name",
         mobile.TXTVALUE AS "Mobile Phone",
         t1.CENTER || 'p' || t1.ID AS "Person ID",
         (CASE
                 WHEN (s.BINDING_END_DATE IS NOT NULL AND s.BINDING_END_DATE >= trunc(current_timestamp)) THEN
                         s.BINDING_PRICE
                 ELSE
                         s.SUBSCRIPTION_PRICE
         END) AS "Price",
         t1.SSN AS "SSN",
         s.START_DATE AS "Start Date",
         s.END_DATE AS "Stop Date",
         CASE  WHEN s.STATE IS NULL THEN  NULL  WHEN s.STATE = 2 THEN 'ACTIVE' WHEN s.STATE = 3 THEN 'ENDED' WHEN s.STATE = 4 THEN 'FROZEN' WHEN s.STATE = 7 THEN 'WINDOW' WHEN s.STATE = 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS "Subscription Status",
         CASE   WHEN s.SUB_STATE IS NULL THEN  NULL WHEN s.SUB_STATE = 1 THEN 'NONE'  WHEN s.SUB_STATE = 2 THEN 'AWAITING_ACTIVATION'  WHEN s.SUB_STATE = 3 THEN 'UPGRADED'  WHEN s.SUB_STATE = 4 THEN 'DOWNGRADED'
                          WHEN s.SUB_STATE = 5 THEN 'EXTENDED'  WHEN s.SUB_STATE = 6 THEN  'TRANSFERRED' WHEN s.SUB_STATE = 7 THEN 'REGRETTED' WHEN s.SUB_STATE = 8 THEN 'CANCELLED' WHEN s.SUB_STATE = 9 THEN 'BLOCKED' WHEN s.SUB_STATE = 10 THEN 'CHANGED' ELSE 'UNKNOWN' END AS "Subscription Sub-state",
         (CASE
                 WHEN s.CENTER IS NOT NULL THEN s.CENTER || 'ss' || s.ID
                 ELSE NULL
         END) AS "Subscription ID",
         (CASE
                 WHEN ch.CTYPE IS NULL THEN NULL
                 WHEN ch.CTYPE = 169 THEN 'CREDIT CARD'
                 WHEN ch.CTYPE = 166 THEN 'INVOICE'
                 WHEN ch.CTYPE = 167 THEN 'DIRECT DEBIT'
                 ELSE 'UNKNOWN'
         END) AS "Payment agreement type",
         CASE  WHEN pag.STATE IS NULL THEN  NULL WHEN pag.STATE = 1 THEN 'Created' WHEN pag.STATE = 2 THEN 'Sent' WHEN pag.STATE = 3 THEN 'Failed' WHEN pag.STATE = 4 THEN 'OK' WHEN pag.STATE = 5 THEN 'Ended, bank' WHEN pag.STATE = 6 THEN 'Ended, clearing house' WHEN pag.STATE = 7 THEN 'Ended, debtor' WHEN pag.STATE = 8 THEN 'Cancelled, not sent'
                       WHEN pag.STATE = 9 THEN 'Cancelled, sent' WHEN pag.STATE = 10 THEN 'Ended, creditor' WHEN pag.STATE = 11 THEN 'No agreement (deprecated)' WHEN pag.STATE = 12 THEN 'Cash payment (deprecated)' WHEN pag.STATE = 13 THEN 'Agreement not needed (invoice payment)'
                       WHEN pag.STATE = 14 THEN 'Agreement information incomplete' WHEN pag.STATE = 15 THEN 'Transfer' WHEN pag.STATE = 16 THEN 'Agreement Recreated' WHEN pag.STATE = 17 THEN  'Signature missing'  ELSE 'UNKNOWN' END AS "Payment agreement status",
         payer.FULLNAME AS "Payer full name",
         (CASE
                 WHEN payer.CENTER IS NOT NULL THEN payer.CENTER || 'p' || payer.ID
                 ELSE NULL
         END) AS "Payer ID",
         (CASE
                 WHEN r.CENTER IS NULL THEN 'NO'
                 ELSE 'YES'
         END) AS "Other Payer",
                 t1.collectionStartDate AS "MDDI start date",
         CASE t1.STATUS  WHEN 1 THEN 'ACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'   END AS "Person Status"
 FROM
 (
         SELECT
                 ar.BALANCE AS AccountBalance,
                 p.FULLNAME AS FullName,
                 CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'
                          WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'
                          WHEN 8 THEN 'GUEST'  WHEN 9 THEN  'CHILD'  WHEN 10 THEN  'EXTERNAL_STAFF' ELSE 'UNKNOWN' END AS MemberStatus,
                 p.CENTER,
                 p.ID,
                 p.SSN,
                 ar.CENTER AS arCenter,
                 ar.ID AS arID,
                 inv.PAYER_CENTER,
                 inv.PAYER_ID,
                                 ccc.STARTDATE as collectionStartDate,
                 p.STATUS,
                 SUM(art.AMOUNT) AS Gross
         FROM
                 PERSONS p
         JOIN
                 CENTERS c ON p.CENTER = c.ID
         JOIN
                 CASHCOLLECTIONCASES ccc ON ccc.PERSONCENTER = p.CENTER AND ccc.PERSONID = p.ID
         JOIN
                 ACCOUNT_RECEIVABLES ar ON ar.CUSTOMERCENTER = p.CENTER AND ar.CUSTOMERID = p.ID AND ar.AR_TYPE = 4
         LEFT JOIN
                 AR_TRANS art ON ar.CENTER = art.CENTER AND ar.ID = art.ID AND art.TEXT LIKE '%Auto Renewal%'
                                         AND art.DUE_DATE >= :FromDate
                                         AND art.DUE_DATE <= :ToDate
         LEFT JOIN
                 INVOICES inv ON inv.CENTER = art.REF_CENTER AND inv.ID = art.REF_ID AND art.REF_TYPE = 'INVOICE'
         WHERE
                 c.COUNTRY = 'IT'
                 AND ccc.MISSINGPAYMENT = 0
                 AND ccc.CLOSED = 0
                 AND p.CENTER IN (:Scope)
                 AND p.STATUS IN (1,3)
				 
         GROUP BY
                 ar.BALANCE,
                 p.FULLNAME,
                 p.PERSONTYPE,
                 p.CENTER,
                 p.ID,
                 p.SSN,
                 ar.CENTER,
                 ar.ID,
                 inv.PAYER_CENTER,
                 inv.PAYER_ID,
                                 ccc.STARTDATE,
                 p.STATUS
 ) t1
 LEFT JOIN
         PAYMENT_ACCOUNTS pac ON pac.CENTER = t1.arCenter AND pac.ID = t1.arID
 LEFT JOIN
         PAYMENT_AGREEMENTS pag ON pag.CENTER = pac.ACTIVE_AGR_CENTER AND pag.ID = pac.ACTIVE_AGR_ID AND pag.SUBID = pac.ACTIVE_AGR_SUBID
 LEFT JOIN
         CLEARINGHOUSES ch ON pag.CLEARINGHOUSE = ch.ID
 LEFT JOIN
         SUBSCRIPTIONS s ON t1.CENTER = s.OWNER_CENTER AND t1.ID = s.OWNER_ID AND s.STATE IN (2,3,4,7,8)
 LEFT JOIN
         PRODUCTS pr ON s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER AND s.SUBSCRIPTIONTYPE_ID = pr.ID
 LEFT JOIN
         CENTERS cs ON s.CENTER = cs.ID
 LEFT JOIN
         PERSON_EXT_ATTRS email ON email.PERSONCENTER = t1.CENTER AND email.PERSONID = t1.ID AND email.NAME = '_eClub_Email'
 LEFT JOIN
         PERSON_EXT_ATTRS mobile ON mobile.PERSONCENTER = t1.CENTER AND mobile.PERSONID = t1.ID AND mobile.NAME = '_eClub_PhoneSMS'
 LEFT JOIN
         PERSONS payer ON payer.CENTER = t1.PAYER_CENTER AND payer.ID = t1.PAYER_ID
 LEFT JOIN
         RELATIVES r ON t1.CENTER = r.RELATIVECENTER AND t1.ID = r.RELATIVEID AND r.RTYPE = 12 AND r.STATUS = 1
