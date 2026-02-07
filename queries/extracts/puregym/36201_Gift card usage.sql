 SELECT
     gc.CENTER || 'gc' || gc.ID "GIFT CARD ID" ,
     prod.NAME GIFTCARD_NAME ,
     gcu.ID "GIFT CARD USAGE SUB_ID" ,
     act.CENTER "TRANSACTION CENTER ID" ,
     c.SHORTNAME "TRANSACTION CENTER NAME" ,
     TO_CHAR(longToDateC(gcu.TIME,gc.CENTER),'HH24:MI') "TIME OF USE" ,
     TO_CHAR(longToDateC(gcu.TIME,gc.CENTER),'DD/MM/YYYY')"DATE OF USE" ,
     gcu.AMOUNT "AMOUNT USED" ,
     CASE WHEN cust.CENTER IS NOT NULL THEN cust.CENTER || 'p' || cust.ID ELSE 'ANONYMOUS OR UNKNOWN' END "USER ID" ,
     cust.FULLNAME "USER NAME" ,
     inv.PAYER_CENTER || 'p' || inv.PAYER_ID "OWNER ID" ,
     p.FULLNAME "OWNER NAME" ,
     gcu.TYPE "USAGE SOURCE" ,
     gcu.REF ,
     invS.CENTER || 'inv' || invS.id inv_id,
     sum(invl.TOTAL_AMOUNT) TOTAL_AMOUNT
 FROM
     GIFT_CARDS gc
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = gc.PRODUCT_CENTER
     AND prod.ID = gc.PRODUCT_ID
 JOIN
     INVOICELINES invl
 ON
     invl.CENTER = gc.INVOICELINE_CENTER
     AND invl.ID = gc.INVOICELINE_ID
     AND invl.SUBID = gc.INVOICELINE_SUBID
 JOIN
     INVOICES inv
 ON
     inv.CENTER = invl.CENTER
     AND inv.id = invl.ID
 JOIN
     PERSONS p
 ON
     p.CENTER = gc.PAYER_CENTER
     AND p.ID = gc.PAYER_ID
 JOIN
     GIFT_CARD_USAGES gcu
 ON
     gcu.GIFT_CARD_CENTER = gc.CENTER
     AND gcu.GIFT_CARD_ID = gc.ID
 LEFT JOIN
     AR_TRANS art
 ON
     art.TEXT = 'API Gift Voucher Redeemed - '||gcu.REF
     AND gcu.TYPE = 'Api'
     AND art.REF_TYPE = 'ACCOUNT_TRANS'
 LEFT JOIN
     AR_TRANS artSold
 ON
     artSold.CENTER = art.CENTER
     AND artSold.id = art.id
     AND artSold.SUBID > art.SUBID
     AND artSold.ENTRY_TIME < art.ENTRY_TIME +1000*5
     AND artSold.REF_TYPE = 'INVOICE'
 LEFT JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CENTER = art.CENTER
     AND ar.ID = art.ID
 LEFT JOIN
     ACCOUNT_TRANS act
 ON
     act.CENTER = COALESCE(gcu.TRANSACTION_CENTER,art.REF_CENTER)
     AND act.ID = COALESCE(gcu.TRANSACTION_ID,art.REF_ID)
     AND act.SUBID = COALESCE(gcu.TRANSACTION_SUBID,art.REF_SUBID)
 LEFT JOIN
     CASHREGISTERTRANSACTIONS crt
 ON
     crt.GLTRANSCENTER = act.CENTER
     AND crt.GLTRANSID = act.ID
     AND crt.GLTRANSSUBID = act.SUBID
     AND gcu.TYPE = 'CashRegister'
 LEFT JOIN
     INVOICES invS
 ON
     (
         invS.CENTER = artSold.REF_CENTER
         AND invS.ID = artSold.REF_ID
         AND artSold.REF_TYPE = 'INVOICE')
     OR (
         invS.CASHREGISTER_CENTER = crt.CENTER
         AND invS.CASHREGISTER_ID = crt.id
         AND invS.PAYSESSIONID = crt.PAYSESSIONID)
 LEFT JOIN
     PERSONS cust
 ON
     cust.CENTER = COALESCE(crt.CUSTOMERCENTER,ar.CUSTOMERCENTER)
     AND cust.ID = COALESCE(crt.CUSTOMERID,ar.CUSTOMERID)
 LEFT JOIN
     CENTERS c
 ON
     c.id = act.CENTER
 WHERE
     p.CENTER IN ($$scope$$)
     AND gcu.TIME BETWEEN $$from_date$$ AND $$to_date$$+1000*60*60*24 -1
 group by
     gc.CENTER || 'gc' || gc.ID ,
     prod.NAME  ,
     gcu.ID,
     act.CENTER ,
     c.SHORTNAME,
     TO_CHAR(longToDateC(gcu.TIME,gc.CENTER),'HH24:MI')  ,
     TO_CHAR(longToDateC(gcu.TIME,gc.CENTER),'DD/MM/YYYY'),
     gcu.AMOUNT  ,
     CASE WHEN cust.CENTER IS NOT NULL THEN cust.CENTER || 'p' || cust.ID ELSE 'ANONYMOUS OR UNKNOWN' END ,
     cust.FULLNAME  ,
     inv.PAYER_CENTER || 'p' || inv.PAYER_ID ,
     p.FULLNAME  ,
     gcu.TYPE,
     gcu.REF ,
     invS.CENTER || 'inv' || invS.id
