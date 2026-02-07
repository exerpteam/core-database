Select
t1.bookdate as"date",
t1.product as "Product / Global account",
t1.GlobalAccountName as "Global Account Name",
t1.normal-t1.price as "Discount Amount",
t1.normal as "Line Item Gross",
t1.price as "Line Item Net",
Case
when t1.discountrate = 'NONE' and t1.price < t1.normal and (t1.normal != 0 or t1.price != 0)  
then 'Manual discount of '|| round(((t1.normal-t1.price)/t1.normal)*100,2) || '%'
else t1.discountrate END as "Discount rate",
t1.InvoiceNumber as "Invoice Number"


from
(
Select
longtodate(act.trans_time) as bookDate,
il.text as Product,
creditaccount.globalid as GlobalAccountName,
round((il.product_normal_price*0.86956521), 2 ) as normal,
il.net_amount as price,
il.center ||'inv'|| il.id as InvoiceNumber,
vatTran.AMOUNT,
100/((vattype.rate*100)+100) AS VATRATE,
il.product_normal_price*RATE,
round((il.product_normal_price*0.86956521), 2 ) as normalpriceexvat,
il.product_normal_price,
pp.price_modification_amount,
case
when pp.price_modification_name = 'OVERRIDE'
then 'Fixed price of ' || pp.price_modification_amount || ' SAR'
when pp.price_modification_name = 'PERCENTAGE_REBATE'
then 'Discount of '|| pp.price_modification_amount*100 || '%' 
else 'NONE' END as discountrate


from
invoice_lines_mt il

join
account_trans act
ON il.ACCOUNT_TRANS_CENTER = act.CENTER AND il.ACCOUNT_TRANS_ID = act.ID AND il.ACCOUNT_TRANS_SUBID = act.SUBID AND act.TRANS_TYPE=4

JOIN ACCOUNTS creditAccount
 ON creditAccount.CENTER = act.CREDIT_ACCOUNTCENTER AND creditAccount.ID = act.CREDIT_ACCOUNTID        
JOIN ACCOUNT_TRANS vatTran
                ON vatTran.MAIN_TRANSCENTER = act.CENTER AND vatTran.MAIN_TRANSID = act.ID AND vatTran.MAIN_TRANSSUBID = act.SUBID
JOIN VAT_TYPES vatType
                ON vatType.CENTER = vatTran.VAT_TYPE_CENTER AND vatType.ID = vatTran.VAT_TYPE_ID
left JOIN
   PRIVILEGE_USAGES pu
ON
    il.CENTER = pu.TARGET_CENTER
    AND il.ID = pu.TARGET_ID
    AND il.SUBID = pu.TARGET_SUBID
left join
product_privileges pp
on
pp.id = pu.privilege_id    
                
where
il.center in (:scope) 
and act.trans_time >= :fromdate
and act.trans_time <= :todate + (24*60*60*1000) ) t1 