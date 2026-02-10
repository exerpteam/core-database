-- The extract is extracted from Exerp on 2026-02-08
--  
 select clo.id as "File id", to_char(clo.SENT_DATE, 'YYYY-MM-DD') as "Submit date", to_char(clo.REQUESTED_DATE, 'YYYY-MM-DD') as "Collection date"
 , clo.INVOICE_COUNT as "Count"
 , clo.TOTAL_AMOUNT "Total £"
 , sum(case pr.REQUEST_TYPE  when 1 then  1  else 0 end) as "Normal collections"
 , sum(case pr.REQUEST_TYPE  when 1 then  pr.REQ_AMOUNT  else 0 end) as "Normal collections total £"
 , sum(case pr.REQUEST_TYPE  when 6 then  1  else 0 end) as "Representations"
 , sum(case pr.REQUEST_TYPE  when 6 then  pr.REQ_AMOUNT  else 0 end) - sum(coalesce(il.TOTAL_AMOUNT, 0)) as "Representations total £"
 , sum(case when il.center is not null and il.TOTAL_AMOUNT > 0 then 1 else 0 end) as "Bounce fees"
 , sum(coalesce(il.TOTAL_AMOUNT, 0)) as "Bounce fees total £"
 , sum(case pr.REQUEST_TYPE  when 5 then  1  else 0 end) as "Refunds"
 , sum(case pr.REQUEST_TYPE  when 5 then  pr.REQ_AMOUNT  else 0 end) as "Refunds total £"
 , to_char(min(pr.DUE_DATE), 'YYYY-MM-DD') as "Earliest due date"
 , to_char(max(pr.DUE_DATE), 'YYYY-MM-DD') as "Latest due date"
 from CLEARING_OUT clo
 join PAYMENT_REQUESTS pr on pr.REQ_DELIVERY = clo.ID
 left join INVOICELINES il on il.center = pr.COLL_FEE_INVLINE_CENTER and il.id = pr.COLL_FEE_INVLINE_ID and il.subid = pr.COLL_FEE_INVLINE_SUBID
 where clo.SENT_DATE >= :fromDate and clo.SENT_DATE <= :toDate
 group by clo.id, clo.SENT_DATE, clo.REQUESTED_DATE, clo.TOTAL_AMOUNT, clo.INVOICE_COUNT
 order by 1
