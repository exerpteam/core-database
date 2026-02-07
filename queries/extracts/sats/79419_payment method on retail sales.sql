 select
 t1.center,
 t1.name,
 CASE t1.paymenttype WHEN 1 THEN 'CASH' WHEN 2 THEN 'CHANGE' WHEN 3 THEN 'RETURN ON CREDIT' WHEN 4 THEN 'PAYOUT CASH' WHEN 5 THEN 'PAID BY CASH AR ACCOUNT' WHEN 6 THEN 'DEBIT CARD' WHEN 7 THEN 'CREDIT CARD' WHEN 8 THEN 'DEBIT OR CREDIT CARD' WHEN 9 THEN 'GIFT CARD' WHEN 10 THEN 'CASH ADJUSTMENT' WHEN 11 THEN 'CASH TRANSFER' WHEN 12 THEN 'PAYMENT AR' WHEN 13 THEN 'CONFIG PAYMENT METHOD' WHEN 14 THEN 'CASH REGISTER PAYOUT' WHEN 15 THEN 'CREDIT CARD ADJUSTMENT' WHEN 16 THEN 'CLOSING CASH ADJUST' WHEN 17 THEN 'VOUCHER' WHEN 18 THEN 'PAYOUT CREDIT CARD' WHEN 19 THEN 'TRANSFER BETWEEN REGISTERS' WHEN 20 THEN 'CLOSING CREDIT CARD ADJ' WHEN 21 THEN 'TRANSFER BACK CASH COINS' WHEN 22 THEN 'INSTALLMENT PLAN' WHEN 100 THEN 'INITIAL CASH' WHEN 101 THEN 'MANUAL' ELSE 'Undefined' END CRTTYPE,
 sum(t1.amount) as "total amount",
 t1.country
 from
 (select
 crt.CRTTYPE as paymenttype,
 sum(crt.amount) as amount,
 crt.center,
 pg.id,
 c.name,
 c.country
 from CASHREGISTERTRANSACTIONS crt
 join invoices i
 on
 crt.PAYSESSIONID = i.PAYSESSIONID
 join INVOICE_LINES_MT invl
 on
 i.center = invl.center
 and
 i.id = invl.id
 join PRODUCTS prod
 ON
     prod.ID = invl.PRODUCTID
     AND prod.CENTER = invl.PRODUCTCENTER
 join PRODUCT_AND_PRODUCT_GROUP_LINK ppg
 on
 prod.center = ppg.PRODUCT_CENTER
 and
 prod.id = ppg.PRODUCT_ID
 join PRODUCT_GROUP pg
 on
 ppg.PRODUCT_GROUP_ID = pg.id
 join centers c
 on
 c.id = crt.center
 where
 longtodate(crt.TRANSTIME) between cast(:fromdate as date) and cast(:todate as date)+1 
 and crt.CENTER in (:scope)
 and pg.name in (:productgroupname)
 group by
 c.name,
 c.country,
 crt.crttype,
 crt.center,
 pg.id)t1
 group by
 t1.name,
 t1.country,
 t1.paymenttype,
 t1.center
