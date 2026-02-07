Select
t3.memberid,
t3.text,
t3."amount without VAT" as "original amount without VAT",
t3."VAT amount" as "original VAT amount",
t3."Total Amount" as "original Total amount",
case when t3."Total Amount"= t3.unsettled_amount
then t3."VAT amount"
else t3."Unsettled VAT amount" end as "unsettled VAT amount" ,
case when t3."Total Amount"= t3.unsettled_amount
then t3."amount without VAT"
else t3.unsettled_amount-t3."Unsettled VAT amount" end as "unsettled amount without VAT",
t3.unsettled_amount as "total unsettled amount"
from
(
Select
t2.memberid,
t2.text,
t2."amount without VAT",
t2."VAT amount",
t2."Total Amount",
t2.unsettled_amount,
t2.unsettled_amount * (t2."vat rate"/(100+t2."vat rate")) as "Unsettled VAT amount",
t2."vat rate" 

From
(
Select
t1.memberid,
t1.text,
t1."amount without VAT",
t1."VAT amount",
t1."Total Amount",
t1.unsettled_amount,
t1."VAT amount"/t1."amount without VAT"*100 as "vat rate"



from
(
SELECT
 ar.customercenter ||'p'|| ar.customerid as memberid,
 case when il.text is not null
 then il.text
 when cnl.text is not null
 then cnl.text
 else art.text end as text ,
 case when il.net_amount is not null
 then il.net_amount 
 when cnl.net_amount is not null
 then cnl.net_amount*-1
 else null end as "amount without VAT",
 case when il.net_amount is not null
 then (il.total_amount-il.net_amount) 
 when cnl.net_amount is not null
 then (cnl.total_amount-cnl.net_amount)*-1
 else null end as "VAT amount",
 
 case 
 when il.total_amount is not null
 then il.total_amount
 when cnl.total_amount is not null
 then cnl.total_amount*-1
 else art.amount end as "Total Amount",
 art.unsettled_amount,
 
                   -- "vat on unsettled amount"
 art.ref_type
 
 FROM ar_trans art
 
 
 join  account_receivables ar
        on
        ar.center = art.center
        and
        ar.id = art.id 
        
LEFT JOIN INVOICES i
                ON i.CENTER = art.ref_center AND i.ID = art.ref_id and art.ref_type = 'INVOICE'
left join invoice_lines_mt il
        ON
            il.CENTER = i.center
        AND il.ID = i.id     
left join credit_notes cn
on cn.CENTER = art.ref_center AND cn.ID = art.ref_id and art.ref_type = 'CREDIT_NOTE'       

left join credit_note_lines_mt cnl
ON
            cn.CENTER = cnl.center
        AND cn.ID = cnl.id  


               

WHERE 
             
                -- ar.customercenter = 243 and ar.customerid = 192052  
               art.unsettled_amount != 0 and
                (ar.customercenter,ar.customerid) in (:memberids)
 )t1 )t2 )t3
 
             