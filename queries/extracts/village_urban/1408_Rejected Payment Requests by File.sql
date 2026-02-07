 SELECT
     p.CENTER||'p'||p.id AS memberid,
     p.FULLNAME,
     prs.ref,
     
     CASE 
        WHEN pr.STATE = 1 THEN 'New' 
        WHEN pr.STATE = 2 THEN 'Sent'
        WHEN pr.STATE = 3 THEN 'Done' 
        WHEN pr.STATE = 4 THEN 'Done, manual' 
        WHEN pr.STATE = 5 THEN 'Rejected, clearinghouse' 
        WHEN pr.STATE = 6 THEN 'Rejected, bank' 
        WHEN pr.STATE = 7 THEN 'Rejected, debtor' 
        WHEN pr.STATE = 8 THEN 'Cancelled' 
        WHEN pr.STATE = 10 THEN 'Reversed, new' 
        WHEN pr.STATE = 11 THEN 'Reversed , sent' 
        WHEN pr.STATE = 12 THEN 'Failed, not creditor' 
        WHEN pr.STATE = 13 THEN 'Reversed, rejected' 
        WHEN pr.STATE = 14 THEN 'Reversed, confirmed' 
        WHEN pr.STATE = 17 THEN 'Failed, payment revoked' 
        ELSE 'UNDEFINED'
     END AS STATE,
     REQ_AMOUNT,
     prs.OPEN_AMOUNT Open_amount_still_unpaid,
     REQ_DATE,
     DUE_DATE,
     XFR_AMOUNT AS import_file_amount,
     XFR_DATE   AS import_file_date,
     XFR_INFO   AS rejection_info,
     REJECTED_REASON_CODE,
     FULL_REFERENCE,
     REQ_DELIVERY AS payment_export_file
 FROM
     PAYMENT_REQUESTS pr
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     pr.CENTER = ar.CENTER
 AND pr.ID = ar.ID
 JOIN
     PERSONS p
 ON
     ar.CUSTOMERCENTER = p.center
 AND ar.CUSTOMERID = p.id
 JOIN
     PAYMENT_REQUEST_SPECIFICATIONS prs
 ON
     pr.INV_COLL_CENTER = prs.CENTER
 AND pr.INV_COLL_ID = prs.ID
 AND pr.INV_COLL_SUBID = prs.SUBID
 WHERE
     pr.XFR_DELIVERY = $$clearing_in$$
