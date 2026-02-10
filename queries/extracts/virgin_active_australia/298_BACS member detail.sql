-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     t1."original_due_date" ,
     t1."Payer club" ,
     t1."Payer ID" ,
     t1."Company" ,
     t1."Payer status" ,
     t1."Payer BACS reference" ,
     t1."Payer SUN" ,
     t1."BACS trans ref" ,
     t1."Invoice due date" ,
     t1."Main presentation amount" ,
     t1."Failure amount" ,
     t1."Representation amount" ,
     t1."Representation failure amount" ,
     t1."Total amount collected " ,
     t1."Request spec open amount" ,
     t1."CTA amount" ,
     t1."Total membership dues" ,
     t1."Vantage dues" ,
     t1."Reason for not presenting" ,
     t1."request_state" ,
     t1."requested_amount" ,
     SUM(art.AMOUNT) "Payer balance"
 FROM
     (
         SELECT
             p.CENTER AS center,
             p.id as id,
             prs."original_due_date" ,
             c.SHORTNAME "Payer club" ,
             p.center || 'p' || p.id "Payer ID" ,
             CASE p.SEX WHEN 'C' THEN 'Yes' ELSE 'No' END "Company" ,
             CASE  p.STATUS  WHEN 0 THEN 'Lead'  WHEN 1 THEN 'Active'  WHEN 2 THEN 'Inactive'  WHEN 3 THEN 'Temporary Inactive'  WHEN 4 THEN 'Transfered'  WHEN 5 THEN 'Duplicate'  WHEN 6 THEN 'Prospect'  WHEN 7 THEN 'Deleted' WHEN 8 THEN  'Anonymized'  WHEN 9 THEN  'Contact'  ELSE 'Unknown' END "Payer status" ,
             pa.REF "Payer BACS reference" ,
             chc.FIELD_6 "Payer SUN" ,
             prs.REF "BACS trans ref" ,
             prs.ORIGINAL_DUE_DATE "Invoice due date" ,
             CASE
                 WHEN pr1.REQ_DELIVERY IS NOT NULL
                 THEN pr1.REQ_AMOUNT * -1
                 ELSE 0
             END "Main presentation amount" ,
             pr1.REQ_AMOUNT - pr1.XFR_AMOUNT "Failure amount" ,
             pr2.REQ_AMOUNT * -1 "Representation amount" ,
             pr2.REQ_AMOUNT - pr2.XFR_AMOUNT "Representation failure amount" ,
             COALESCE(pr1.XFR_AMOUNT,0) + COALESCE(pr2.XFR_AMOUNT,0) "Total amount collected " ,
             prs.open_amount "Request spec open amount" ,
             SUM(
                 CASE
                     WHEN art.TEXT = 'Transfer to payment account for payment request'
                     THEN art.AMOUNT * -1
                     ELSE 0
                 END) "CTA amount" ,
             SUM(
                 CASE
                     WHEN invp.CENTER IS NOT NULL
                     THEN invl.TOTAL_AMOUNT
                     WHEN cnlp.CENTER IS NOT NULL
                     THEN 0 -- -1*cnl.TOTAL_AMOUNT
                     ELSE 0
                 END) "Total membership dues" ,
             NULL "Vantage dues" ,
             NULL "Reason for not presenting" ,
             CASE pr1.STATE WHEN 1 THEN  'New' WHEN 2 THEN  'Sent' WHEN 3 THEN  'Done' WHEN 4 THEN  'Done, manual' WHEN 5 THEN  'Rejected, clearinghouse' WHEN 6 THEN  'Rejected, bank' WHEN 7 THEN  'Rejected, debtor' WHEN 8 THEN  'Cancelled' WHEN 10 THEN  'Reversed, new' WHEN 11 THEN  'Reversed, sent' WHEN 12 THEN  'Failed, not creditor' WHEN 13 THEN  'Reversed, rejected' WHEN 14 THEN  'Reversed, confirmed'  WHEN 17 THEN  'Failed, payment revoked'  WHEN 18 THEN  'Done Partial'  WHEN 19 THEN  'Failed, Unsupported'  WHEN 20 THEN  'Require approval'  WHEN 21 THEN 'Fail, debt case exists'  WHEN 22 THEN ' Failed, timed out' ELSE 'UNDEFINED' END AS request_state,
             pr2.REQ_AMOUNT AS     requested_amount                                                                                                                                                                                                       
         FROM
             PAYMENT_REQUEST_SPECIFICATIONS prs
         JOIN
             AR_TRANS art
         ON
             art.PAYREQ_SPEC_CENTER = prs.CENTER
             AND art.PAYREQ_SPEC_ID = prs.ID
             AND art.PAYREQ_SPEC_SUBID = prs.SUBID
         JOIN
             ACCOUNT_RECEIVABLES ar
         ON
             ar.CENTER = art.CENTER
             AND ar.ID = art.ID
             AND ar.AR_TYPE = 4
         LEFT JOIN
             INVOICE_LINES_MT invl
         ON
             invl.CENTER = art.REF_CENTER
             AND invl.id = art.REF_ID
             --     and invl.SUBID = art.REF_SUBID
             AND art.REF_TYPE = 'INVOICE'
             /* only subscription related */
         LEFT JOIN
             PRODUCTS invp
         ON
             invp.CENTER = invl.PRODUCTCENTER
             AND invp.ID = invl.PRODUCTID
             AND invp.PTYPE IN (5,10,12,6,7,13) -- jf, sub,prorata, trans, freeze, addon
         LEFT JOIN
             CREDIT_NOTE_LINES_MT cnl
         ON
             cnl.CENTER = art.REF_CENTER
             AND cnl.id = art.REF_ID
             AND art.REF_TYPE = 'CREDIT_NOTE'
             /* only subscription related */
         LEFT JOIN
             PRODUCTS cnlp
         ON
             cnlp.CENTER = cnl.PRODUCTCENTER
             AND cnlp.ID = cnl.PRODUCTID
             AND cnlp.PTYPE IN (5,10,12,6,7,13)
         JOIN
             ACCOUNT_RECEIVABLES ar2
         ON
             ar2.CENTER = prs.CENTER
             AND ar2.ID = prs.ID
         JOIN
             PERSONS po
         ON
             po.CENTER = ar.CUSTOMERCENTER
             AND po.id = ar.CUSTOMERID
         JOIN
             PERSONS p
         ON
             p.CENTER = po.CURRENT_PERSON_CENTER
             AND p.id = po.CURRENT_PERSON_ID
         JOIN
             CENTERS c
         ON
             c.id = p.CENTER
         JOIN
             PAYMENT_REQUESTS pr1
         ON
             pr1.INV_COLL_CENTER = prs.CENTER
             AND pr1.INV_COLL_ID = prs.ID
             AND pr1.INV_COLL_SUBID = prs.SUBID
             AND pr1.REQUEST_TYPE = 1
            -- AND pr1.STATE NOT IN (4,8)
         LEFT JOIN
             PAYMENT_AGREEMENTS pa
         ON
             pa.CENTER = prs.CENTER
             AND pa.ID = prs.ID
             AND pa.SUBID = pr1.AGR_SUBID
         LEFT JOIN
             CLEARINGHOUSE_CREDITORS chc
         ON
             chc.CLEARINGHOUSE = pa.CLEARINGHOUSE
             AND chc.CREDITOR_ID = pa.CREDITOR_ID
         LEFT JOIN
             PAYMENT_REQUESTS pr2
         ON
             pr2.INV_COLL_CENTER = prs.CENTER
             AND pr2.INV_COLL_ID = prs.ID
             AND pr2.INV_COLL_SUBID = prs.SUBID
             AND pr2.REQUEST_TYPE = 6
         WHERE
             ar.CENTER IN ($$scope$$)
             /*((
             ar.CUSTOMERCENTER =76
             AND ar.CUSTOMERID = 1677 )
             OR (
             ar.CUSTOMERCENTER = 955
             AND ar.CUSTOMERID = 5226))*/
             AND prs.ORIGINAL_DUE_DATE = $$due_date$$
         GROUP BY
             p.CENTER ,
             COALESCE(pr1.XFR_AMOUNT,0) + COALESCE(pr2.XFR_AMOUNT,0) ,
             p.id ,
             prs.ORIGINAL_DUE_DATE ,
             c.SHORTNAME ,
             prs.open_amount ,
             p.center || 'p' || p.id ,
             pr1.REQ_DELIVERY ,
             CASE p.SEX WHEN 'C' THEN 'Yes' ELSE 'No' END ,
             CASE  p.STATUS  WHEN 0 THEN 'Lead'  WHEN 1 THEN 'Active'  WHEN 2 THEN 'Inactive'  WHEN 3 THEN 'Temporary Inactive'  WHEN 4 THEN 'Transfered'  WHEN 5 THEN 'Duplicate'  WHEN 6 THEN 'Prospect'  WHEN 7 THEN 'Deleted' WHEN 8 THEN  'Anonymized'  WHEN 9 THEN  'Contact'  ELSE 'Unknown' END ,
             pa.REF ,
             chc.FIELD_6 ,
             prs.REF ,
             prs.ORIGINAL_DUE_DATE ,
             pr1.REQ_AMOUNT ,
             pr1.REQ_AMOUNT - pr1.XFR_AMOUNT ,
             pr2.REQ_AMOUNT ,
             pr2.REQ_AMOUNT - pr2.XFR_AMOUNT ,
             prs.REQUESTED_AMOUNT - prs.OPEN_AMOUNT ,
             CASE pr1.STATE WHEN 1 THEN  'New' WHEN 2 THEN  'Sent' WHEN 3 THEN  'Done' WHEN 4 THEN  'Done, manual' WHEN 5 THEN  'Rejected, clearinghouse' WHEN 6 THEN  'Rejected, bank' WHEN 7 THEN  'Rejected, debtor' WHEN 8 THEN  'Cancelled' WHEN 10 THEN  'Reversed, new' WHEN 11 THEN  'Reversed, sent' WHEN 12 THEN  'Failed, not creditor' WHEN 13 THEN  'Reversed, rejected' WHEN 14 THEN  'Reversed, confirmed'  WHEN 17 THEN  'Failed, payment revoked'  WHEN 18 THEN  'Done Partial'  WHEN 19 THEN  'Failed, Unsupported'  WHEN 20 THEN  'Require approval'  WHEN 21 THEN 'Fail, debt case exists'  WHEN 22 THEN ' Failed, timed out' ELSE 'UNDEFINED' END ,
             pr2.REQ_AMOUNT ) t1
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER =t1.center
     AND ar.CUSTOMERID = t1.id
     AND ar.AR_TYPE = 4
 JOIN
     AR_TRANS art
 ON
     art.CENTER = ar.center
     AND art.ID = ar.id
     AND art.TRANS_TIME < (dateToLongC(TO_CHAR(t1.ORIGINAL_DUE_DATE,'YYYYMMdd HH24:MI'),t1.center) + (1000 * 60 * 60 * 24 * $$rejections_delay$$))
 GROUP BY
     t1."center" ,
     t1."id" ,
     t1."original_due_date" ,
     t1."Payer club" ,
     t1."Payer ID" ,
     t1."Company" ,
     t1."Payer status" ,
     t1."Payer BACS reference" ,
     t1."Payer SUN" ,
     t1."BACS trans ref" ,
     t1."Invoice due date" ,
     t1."Main presentation amount" ,
     t1."Failure amount" ,
     t1."Representation amount" ,
     t1."Representation failure amount" ,
     t1."Total amount collected " ,
     t1."CTA amount" ,
     t1."Total membership dues" ,
     t1."Request spec open amount" ,
     t1."Vantage dues" ,
     t1."Reason for not presenting" ,
     t1."request_state" ,
     t1."requested_amount"
