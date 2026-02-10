-- The extract is extracted from Exerp on 2026-02-08
--  
select 
    comp.CENTER||'p'||comp.ID as customerId,
	comp.LASTNAME as Company_name,
    pr.REQ_AMOUNT as requestedAmount,
    prs.TOTAL_INVOICE_AMOUNT as totalInvoiceAmount,
    nvl(sum(sp_il.TOTAL_AMOUNT), 0) - nvl(sum(sp_cnl.total_amount), 0) as fully_sponsored_inv_amount,
--    nvl(sum(sp_il.TOTAL_AMOUNT), 0) as fully_sponsored_inv_amount,
--    nvl(sum(sp_cnl.total_amount), 0) as fully_sponsored_cr_am,
    pr.REQ_AMOUNT - (nvl(sum(sp_il.TOTAL_AMOUNT), 0) - nvl(sum(sp_cnl.total_amount), 0)) as non_sponsored_amount,
    TO_CHAR(pr.REQ_DATE, 'yyyy-MM-dd') as requestDate,
	trunc(longtodate(ar.entry_time)) as entry_time
from 
        fw.PAYMENT_REQUESTS pr
join fw.PAYMENT_REQUEST_SPECIFICATIONS prs 
    on 
        pr.INV_COLL_CENTER = prs.center 
        and pr.INV_COLL_ID = prs.id 
        and pr.INV_COLL_SUBID = prs.subid
join fw.ar_trans ar
    on
        prs.center = ar.payreq_spec_center 
        and prs.id = ar.payreq_spec_id
        and prs.subid = ar.payreq_spec_subid
        and ar.COLLECTED = 1
        and ar.REF_TYPE in ('INVOICE', 'CREDIT_NOTE')
join fw.ACCOUNT_RECEIVABLES arc 
    on 
        pr.center = arc.center 
        and pr.id = arc.id
join fw.persons comp
    on
       arc.CUSTOMERCENTER = comp.center
       and arc.CUSTOMERID = comp.id
       and comp.sex = 'C'
left join fw.invoices sp_i
    on
       ar.ref_center    = sp_i.center
       and ar.ref_id    = sp_i.id
       and ar.REF_TYPE = 'INVOICE'
left join fw.invoicelines sp_il
    on
        sp_i.center = sp_il.center
       and sp_i.id = sp_il.id
left join FW.INVOICES i 
    on 
        i.SPONSOR_INVOICE_CENTER = sp_i.CENTER 
    and i.SPONSOR_INVOICE_ID = sp_i.ID
left join FW.CREDIT_NOTES sp_cn
    on
       ar.ref_center    = sp_cn.center
       and ar.ref_id    = sp_cn.id
       and ar.REF_TYPE = 'CREDIT_NOTE'
left join FW.CREDIT_NOTE_LINES sp_cnl 
    on
        sp_cn.center = sp_cnl.center
       and sp_cn.id = sp_cnl.id

left join FW.INVOICELINES sp_cn_sp_il 
    on 
        sp_cnl.INVOICELINE_CENTER = sp_cn_sp_il.CENTER 
       and sp_cnl.INVOICELINE_ID = sp_cn_sp_il.ID 
       and sp_cnl.INVOICELINE_SUBID = sp_cn_sp_il.SUBID
left join FW.INVOICES sp_cn_sp_i 
    on 
        sp_cn_sp_i.center = sp_cn_sp_il.CENTER 
       and sp_cn_sp_i.id = sp_cn_sp_il.ID
left join FW.INVOICES sp_cn_i 
    on 
        sp_cn_i.SPONSOR_INVOICE_CENTER = sp_cn_sp_i.CENTER 
      and sp_cn_i.SPONSOR_INVOICE_ID = sp_cn_sp_i.ID
where
    arc.CUSTOMERCENTER in (:scope)
--    and arc.CUSTOMERid = 10162  -- 16122
    and pr.req_date >= :request_from 
    and pr.req_date <= :request_to
--    and (ar.REF_TYPE = 'INVOICE' and i.center is not null)
    and ((ar.REF_TYPE = 'INVOICE' and i.center is not null) or (ar.REF_TYPE = 'CREDIT_NOTE' and sp_cn_i.center is not null))
group by
    comp.CENTER,
    comp.ID,
    pr.REQ_AMOUNT,
    pr.REQ_DATE,
    prs.TOTAL_INVOICE_AMOUNT,
	trunc(longtodate(ar.entry_time))
order by
    comp.CENTER,
    comp.ID