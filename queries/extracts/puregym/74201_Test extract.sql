 SELECT
 longtodate(art.entry_time) Invoice_Date,
  coalesce (cl.person_center, il.person_center) ||'p'||  coalesce (cl.person_id, il.person_id) Member_key,
     pr2.center AS center,
     pr2.id     AS id,
     pr2.subid  AS subid ,
     pr2.REQ_AMOUNT,
     pr2.DUE_DATE,
     COALESCE(i.TEXT,cn.TEXT)                    AS TEXT,
     COALESCE(il.NET_AMOUNT, -cl.NET_AMOUNT)     AS NET_AMOUNT,
     COALESCE(il.TOTAL_AMOUNT, -cl.TOTAL_AMOUNT) AS TOTAL_AMOUNT,
     COALESCE(il.TOTAL_AMOUNT-il.NET_AMOUNT,-( cl.TOTAL_AMOUNT-cl.NET_AMOUNT))     AS VAT,
     coalesce (cl.person_center, il.person_center) as Customer_Center,
        coalesce (cl.person_id, il.person_id) as Customer_ID,
             art.REF_TYPE
 FROM
     PAYMENT_REQUESTS pr2
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.center = pr2.center
 AND ar.id = pr2.id
 AND ar.AR_TYPE = 4
 JOIN
     PAYMENT_REQUEST_SPECIFICATIONS prs
 ON
     pr2.INV_COLL_CENTER = prs.CENTER
 AND pr2.INV_COLL_ID = prs.ID
 AND pr2.INV_COLL_SUBID = prs.subid
 JOIN
     AR_TRANS art
 ON
     art.PAYREQ_SPEC_CENTER = prs.CENTER
 AND art.PAYREQ_SPEC_ID = prs.ID
 AND art.PAYREQ_SPEC_SUBID = prs.SUBID
 LEFT JOIN
     INVOICES i
 ON
     art.REF_CENTER = i.CENTER
 AND art.REF_ID = i.ID
 AND art.REF_TYPE IN('INVOICE')
 LEFT JOIN
     CREDIT_NOTES cn
 ON
     art.REF_CENTER = cn.CENTER
 AND art.REF_ID = cn.ID
 AND art.REF_TYPE IN('CREDIT_NOTE')
 LEFT JOIN
     INVOICE_LINES_MT il
 ON
     art.REF_CENTER = il.CENTER
 AND art.REF_ID = il.ID
 AND art.REF_TYPE IN('INVOICE')
 LEFT JOIN
     credit_note_lines_mt cl
 ON
     art.REF_CENTER = cl.CENTER
 AND art.REF_ID = cl.ID
 AND art.REF_TYPE IN ('CREDIT_NOTE')
 WHERE
     art.REF_TYPE IN ('INVOICE',
                      'CREDIT_NOTE')
 AND pr2.center= 100
 AND pr2.id = 22612
 AND pr2.subid=73
