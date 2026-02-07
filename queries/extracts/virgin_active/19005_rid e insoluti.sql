 SELECT
     c.id club_id,
     c.NAME club_name,
     CASE pr.state WHEN 1 THEN  'New' WHEN 2 THEN  'Sent' WHEN 3 THEN  'Done' WHEN 4 THEN  'Done, manual' WHEN 5 THEN  'Rejected, clearinghouse' WHEN 6 THEN  'Rejected, bank' WHEN 7 THEN  'Rejected, debtor' WHEN 8 THEN  'Cancelled' WHEN 10 THEN  'Reversed, new' WHEN 11 THEN  'Reversed, sent' WHEN 12 THEN  'Failed, not creditor' WHEN 13 THEN  'Reversed, rejected' WHEN 14 THEN  'Reversed, confirmed' WHEN 17 THEN 'Revoked by debitor' WHEN 18 THEN 'Done partial' WHEN 19 THEN 'Fail unsupported' ELSE 'UNDEFINED' END AS request_state,
     CASE WHEN co.SENT_DATE IS NOT NULL THEN 1 ELSE 0 END in_file,
     pr.XFR_INFO rejection_code_info,
     SUM(pr.REQ_AMOUNT) TOTAL_REQUESTED_AMOUNT,
     COUNT(pr.CENTER) REQUESTS,
     co.TOTAL_AMOUNT amount_in_file,
     co.INVOICE_COUNT requests_in_file
 FROM
     PAYMENT_REQUESTS pr
 JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
 ON
     prs.CENTER = pr.INV_COLL_CENTER
     AND prs.ID = pr.INV_COLL_ID
     AND prs.SUBID = pr.INV_COLL_SUBID
 LEFT JOIN PAYMENT_REQUESTS pr2
 ON
     pr2.INV_COLL_CENTER = prs.CENTER
     AND pr2.INV_COLL_ID = prs.ID
     AND pr2.INV_COLL_SUBID = prs.SUBID
     AND pr2.REQUEST_TYPE != 6
 JOIN CENTERS c
 ON
     c.ID = pr.CENTER
 LEFT JOIN CLEARING_OUT co
 ON
     co.ID = pr.REQ_DELIVERY
 WHERE
     pr.STATE NOT IN (1)
         AND pr.CENTER in ($$Scope$$)
     AND pr.CREDITOR_ID = 'BACS IT'
     AND pr.REQ_DATE BETWEEN :reqDateFrom AND :reqDateTo + INTERVAL '1' DAY
 GROUP BY
     c.id ,
     c.NAME ,
     CASE pr.state WHEN 1 THEN  'New' WHEN 2 THEN  'Sent' WHEN 3 THEN  'Done' WHEN 4 THEN  'Done, manual' WHEN 5 THEN  'Rejected, clearinghouse' WHEN 6 THEN  'Rejected, bank' WHEN 7 THEN  'Rejected, debtor' WHEN 8 THEN  'Cancelled' WHEN 10 THEN  'Reversed, new' WHEN 11 THEN  'Reversed, sent' WHEN 12 THEN  'Failed, not creditor' WHEN 13 THEN  'Reversed, rejected' WHEN 14 THEN  'Reversed, confirmed' WHEN 17 THEN 'Revoked by debitor' WHEN 18 THEN 'Done partial' WHEN 19 THEN 'Fail unsupported' ELSE 'UNDEFINED' END,
     co.SENT_DATE ,
     pr.XFR_INFO,
     co.TOTAL_AMOUNT ,
     co.INVOICE_COUNT
 ORDER BY
     CASE WHEN co.SENT_DATE IS NOT NULL THEN 1 ELSE 0 END,
     SUM(pr.REQ_AMOUNT)
