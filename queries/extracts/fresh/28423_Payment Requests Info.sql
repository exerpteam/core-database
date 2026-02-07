select
    to_char(current_date,'dd-mon-yyyy') as extractdate,
    case
        when art.REF_TYPE = 'INVOICE' 
        then spp.FROM_DATE
        when art.REF_TYPE = 'CREDIT_NOTE' 
        then sppcn.FROM_DATE
        else null
    end as "Invoiced Period From date",
    case
        when art.REF_TYPE = 'INVOICE' 
        then spp.TO_DATE
        when art.REF_TYPE = 'CREDIT_NOTE' 
        then sppcn.TO_DATE
        else null
    end as "invoiced Period to date",
    case
        when art.REF_TYPE = 'INVOICE' 
        then il.PERSON_CENTER ||'p'|| il.PERSON_ID
        when art.REF_TYPE = 'CREDIT_NOTE' 
        then cl.PERSON_CENTER ||'p'|| cl.PERSON_ID
        else ''
    end as "ID on person invoiced for",
    case
        when prel.CENTER is not null 
        then prel.fullname
        when prel2.CENTER is not null 
        then prel2.fullname
        else ''
    end as "name on person invoiced for",
    case
        when prel.CENTER is not null 
        then prel.ssn
        when prel2.CENTER is not null 
        then prel2.ssn
        else ''
    end                                     as "SSN on person invoiced for" ,
    ar.CUSTOMERCENTER ||'p'|| ar.CUSTOMERID as payer_id,
    p.fullname                              as payer_name,
    p.ssn,
    center.ORG_CODE,
    center.name,
    center.address1,
    center.zipcode ||' '|| center.city as city,
    prs.ref                            as invoiceid,
    case pr.state 
        when 1 
        then 'New' 
        when 2 
        then 'Sent' 
        when 3 
        then 'Done' 
        when 4 
        then 'Done, manual' 
        when 5 
        then 'Rejected, clearinghouse' 
        when 6 
        then 'Rejected, bank' 
        when 7 
        then 'Rejected, debtor' 
        when 8 
        then 'Cancelled' 
        when 10 
        then 'Reversed, new' 
        when 11 
        then 'Reversed, sent'
        when 12 
        then 'Failed, not creditor' 
        when 13 
        then 'Reversed, rejected' 
        when 14 
        then 'Reversed, confirmed' 
        when 17 
        then 'Failed, payment revoked' 
        when 18 
        then 'Done Partial' 
        when 19 
        then 'Failed, Unsupported' 
        when 20 
        then 'Require approval' 
        when 21 
        then 'Fail, debt case exists' 
        when 22 
        then ' Failed, timed out' 
        else 'UNDEFINED' 
    end as state,
    pr.REQ_AMOUNT,
    (TOTAL_INVOICE_AMOUNT-REQUESTED_AMOUNT) as "from previous invoices",
    pr.REQ_DATE,
    pr.DUE_DATE,
    case
        when art.REF_TYPE = 'INVOICE' 
        then il.TEXT
        when art.REF_TYPE = 'CREDIT_NOTE' 
        then cl.TEXT
        else art.text
    end as "TEXT",
    case
        when art.REF_TYPE = 'INVOICE' 
        then il.TOTAL_AMOUNT
        when art.REF_TYPE = 'CREDIT_NOTE' 
        then -(cl.TOTAL_AMOUNT)
        when art.REF_TYPE = 'ACCOUNT_TRANS' 
        then art.AMOUNT
        else 0
    end as "TOTAL_AMOUNT",
    case
        when art.REF_TYPE = 'INVOICE' 
        then il.NET_AMOUNT
        when art.REF_TYPE = 'CREDIT_NOTE' 
        then -(cl.NET_AMOUNT)
        else 0::int
    end as "NET_AMOUNT",
    case
        when art.REF_TYPE = 'INVOICE' 
        then (il.TOTAL_AMOUNT-il.NET_AMOUNT)
        when art.REF_TYPE = 'CREDIT_NOTE' 
        then -(cl.TOTAL_AMOUNT-cl.NET_AMOUNT)
        else 0::int
    end as "VAT amount",
    case
        when art.REF_TYPE = 'INVOICE' 
        then (ilv.rate*100)
        when art.REF_TYPE = 'CREDIT_NOTE' 
        then (clv.rate*100)
        else null
    end as "VAT Rate",
    art.ref_type,
    art.text as "TEXT consolidated"
from
    PERSONS p
    join
        PERSONS ap on p.CENTER = ap.TRANSFERS_CURRENT_PRS_CENTER and p.ID = 
            ap.TRANSFERS_CURRENT_PRS_ID
    join
        ACCOUNT_RECEIVABLES ar on ar.CUSTOMERCENTER = ap.CENTER and ar.CUSTOMERID = ap.ID
    join
        PAYMENT_REQUEST_SPECIFICATIONS prs on prs.CENTER = ar.CENTER and prs.ID = ar.ID
    join
        PAYMENT_REQUESTS pr on pr.INV_COLL_CENTER = prs.CENTER and pr.INV_COLL_ID = prs.ID and 
            pr.INV_COLL_SUBID = prs.SUBID
    join
        AR_TRANS art on prs.CENTER = art.PAYREQ_SPEC_CENTER and prs.ID = art.PAYREQ_SPEC_ID and 
            prs.SUBID = art.PAYREQ_SPEC_SUBID
    join
        CENTERS center on ap.CENTER = center.ID
    -- INVOICE
    left join
        INVOICES i on i.CENTER = art.REF_CENTER and i.ID = art.REF_ID and art.REF_TYPE = 'INVOICE'
    left join
        INVOICE_LINES_MT il on i.CENTER = il.CENTER and i.ID = il.ID
    left join
        INVOICELINES_VAT_AT_LINK ilv on il.CENTER = ilv.invoiceline_CENTER and il.id = 
            ilv.invoiceline_id and il.subid = ilv.invoiceline_subid
    left join
        spp_invoicelines_link sppinvlnk on sppinvlnk.invoiceline_center = il.center and 
            sppinvlnk.invoiceline_id = il.id and sppinvlnk.invoiceline_subid = il.subid
    left join
        subscriptionperiodparts spp on spp.center = sppinvlnk.period_center and spp.id = 
            sppinvlnk.period_id and spp.subid = sppinvlnk.period_subid
    left join
        persons prel on il.PERSON_CENTER = prel.CENTER and il.PERSON_id = prel.ID
    -- CREDIT NOTES
    left join
        CREDIT_NOTES cn on cn.CENTER = art.REF_CENTER and cn.ID = art.REF_ID and art.REF_TYPE = 
            'CREDIT_NOTE'
    left join ( 
            select
                center,
                id,
                subid,
                invoiceline_center,
                invoiceline_id,
                invoiceline_subid,
                productcenter,
                productid,
                account_trans_center,
                account_trans_id,
                account_trans_subid,
                quantity,
                text,
                credit_type,
                canceltype,
                total_amount,
                product_cost,
                reason,
                person_center,
                person_id,
                rebooking_acc_trans_center,
                rebooking_acc_trans_id,
                rebooking_acc_trans_subid,
                rebooking_to_center,
                installment_plan_id,
                sales_commission,
                sales_units,
                period_commission,
                net_amount, (
                    select
                        l.account_trans_center
                    from
                        credit_note_line_vat_at_link l
                    where
                        l.credit_note_line_center = line.center
                        and l.credit_note_line_id = line.id
                        and l.credit_note_line_subid = line.subid)
                as vat_acc_trans_center, (
                    select
                        l.account_trans_subid
                    from
                        credit_note_line_vat_at_link l
                    where
                        l.credit_note_line_center = line.center
                        and l.credit_note_line_id = line.id
                        and l.credit_note_line_subid = line.subid)
                as vat_acc_trans_subid, (
                    select
                        l.account_trans_id
                    from
                        credit_note_line_vat_at_link l
                    where
                        l.credit_note_line_center = line.center
                        and l.credit_note_line_id = line.id
                        and l.credit_note_line_subid = line.subid)
                as vat_acc_trans_id, (
                    select
                        l.rate
                    from
                        credit_note_line_vat_at_link l
                    where
                        l.credit_note_line_center = line.center
                        and l.credit_note_line_id = line.id
                        and l.credit_note_line_subid = line.subid)
                as rate, (
                    select
                        l.orig_rate
                    from
                        credit_note_line_vat_at_link l
                    where
                        l.credit_note_line_center = line.center
                        and l.credit_note_line_id = line.id
                        and l.credit_note_line_subid = line.subid)
                as orig_rate
            from
                credit_note_lines_mt line ) cl on cn.CENTER = cl.CENTER and cn.ID = cl.ID
    left join
        CREDIT_NOTE_LINE_VAT_AT_LINK clv on cl.CENTER = clv.CREDIT_NOTE_LINE_CENTER and cl.id = 
            clv.CREDIT_NOTE_LINE_ID and cl.subid = clv.CREDIT_NOTE_LINE_SUBID
    left join
        spp_invoicelines_link sppcnlnk on sppcnlnk.invoiceline_center = cl.center and 
            sppcnlnk.invoiceline_id = cl.id and sppcnlnk.invoiceline_subid = cl.subid
    left join
        subscriptionperiodparts sppcn on sppcn.center = sppcnlnk.period_center and sppcn.id = 
            sppcnlnk.period_id and sppcn.subid = sppcnlnk.period_subid
    left join
        Persons prel2 on cl.PERSON_CENTER = prel2.CENTER and cl.PERSON_ID = prel2.ID
where
    p.external_id in (:externalid)
    and pr.REQ_DATE between :from_date and :to_date
    and art.COLLECTED in (1,4,5)
    and pr.state in (3,4,18)
    and art.text != 'API Sale Transaction'