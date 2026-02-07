 select
         to_char(longToDateC(i.ENTRY_TIME,i.payer_center),'YYYY-MM-dd') Invoice_Date_Time,
         i.payer_center || 'p' || i.Payer_id "Payer_ID",
         case
                 when p1.STATUS = 1 then 'Active'
                 when p1.STATUS = 2 then 'Inactive'
                 when p1.STATUS = 3 then 'Temporary Inactive'
                 when p1.STATUS = 9 then 'Contact'
         end "Payer_Status",
         p1.FULLNAME "Payer_Fullname",
         p1.EXTERNAL_ID "Payer_External_ID",
         invl.person_center || 'p' || invl.person_id "Person_being_paid_for_ID",
         case
                 when p2.STATUS = 1 then 'Active'
                 when p2.STATUS = 2 then 'Inactive'
                 when p2.STATUS = 3 then 'Temporary Inactive'
                 when p2.STATUS = 9 then 'Contact'
         end "Person_being_paid_for_Status",
         p2.FULLNAME "Person_being_paid_for_Fullname",
         p2.EXTERNAL_ID "Person_being_paid_for_ID",
         i.text,
         invl.text,
         invl.Product_Normal_Price,
         prod.Price "Standard_Price",
         pa.State,
         pa.Ref,
         pa.ClearingHouse "Clearing_House_Exerp_ID",
         pa.Creditor_ID,
         pa.Bank_RegNo,
         pa.Bank_Branch_No,
         pa.Bank_Name,
         pa.Bank_AccNo,
         pa.Requests_sent,
         pa.ClearingHouse_Ref,
         pr.REF,
         pr.REQ_AMOUNT,
         pr.REQ_DATE,
         pr.REQ_DELIVERY,
         pr.XFR_AMOUNT,
         pr.XFR_DATE
 FROM
         INVOICES i
 JOIN
         INVOICELINES invl
 ON
     invl.CENTER = i.CENTER
     AND invl.ID = i.ID
 JOIN
         PRODUCTS prod
 ON
     prod.CENTER = invl.PRODUCTCENTER
     AND prod.ID = invl.PRODUCTID
 JOIN
         PERSONS p1
 ON
     p1.CENTER = i.payer_center
     AND p1.ID =  i.Payer_id
 JOIN
         PERSONS p2
 ON
     p2.CENTER = invl.person_center
     AND p2.ID = invl.person_id
 LEFT JOIN
         ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = p1.CENTER
     AND ar.CUSTOMERID = p1.ID
     AND ar.AR_TYPE = 4
 LEFT
         JOIN PAYMENT_ACCOUNTS pac
 ON
     pac.CENTER = ar.CENTER
     AND pac.ID = ar.ID
 LEFT JOIN
         PAYMENT_AGREEMENTS PA
 ON
     pa.CENTER = pac.ACTIVE_AGR_CENTER
     AND pa.ID = pac.ACTIVE_AGR_ID
     AND pa.SUBID = pac.ACTIVE_AGR_SUBID
 LEFT JOIN
     PAYMENT_REQUEST_SPECIFICATIONS prs
 ON
     prs.CENTER = pa.CENTER
     AND prs.ID = pa.id
     AND prs.SUBID = pa.SUBID
 LEFT JOIN
     PAYMENT_REQUESTS pr
 ON
     pr.INV_COLL_CENTER = prs.CENTER
     AND pr.INV_COLL_ID = prs.ID
     AND pr.INV_COLL_SUBID = prs.SUBID
 WHERE
         i.text LIKE '%01/03/2016 - 31/03/2016 (Auto Renewal)%'
 AND
         to_char(longToDateC(i.ENTRY_TIME,i.payer_center),'MM') = '03'
 AND
         to_char(longToDateC(i.ENTRY_TIME,i.payer_center),'dd') <> '01'
 AND
         to_char(longToDateC(i.ENTRY_TIME,i.payer_center),'YYYY') = '2016'
 AND
         p2.COUNTRY = 'IT'
 AND
         invl.Total_Amount <> 0
