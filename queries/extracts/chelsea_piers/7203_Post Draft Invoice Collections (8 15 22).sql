SELECT
        ch.name AS "Clearinghouse",
        prs.ref AS "Invoice ID",
        p.center || 'p' || p.id AS "Customer ID",
        p.fullname AS "Name",
        (CASE pr.state 
                WHEN 1 THEN 'PS_NEW' 
                WHEN 2 THEN 'PS_SENT' 
                WHEN 3 THEN 'PS_DONE' 
                WHEN 4 THEN 'PS_DONE_MANUAL' 
                WHEN 5 THEN 'PS_REJECTED_BY_CLEARINGHOUSE'
                WHEN 6 THEN 'PS_REJECTED_BY_BANK' 
                WHEN 7 THEN 'PS_REJECTED_BY_DEBITOR' 
                WHEN 8 THEN 'PS_CANCELLED' 
                WHEN 12 THEN 'PS_FAIL_NO_CREDITOR' 
                WHEN 17 THEN 'PS_FAIL_REJ_DEB_REVOKED' 
                WHEN 18 THEN 'PS_DONE_PARTIAL' 
                WHEN 19 THEN 'PS_FAIL_UNSUPPORTED' 
                WHEN 20 THEN 'PS_REQUIRE_APPROVAL' 
                WHEN 21 THEN 'PS_FAIL_DEBT_CASE_EXISTS' 
                WHEN 22 THEN 'PS_FAIL_TIMED_OUT' 
                ELSE 'UNDEFINED' 
        END) AS "State",        
        TO_CHAR(pr.req_date,'MM/DD/YYYY') AS "Deduction Day",
        TO_CHAR(pr.due_date,'MM/DD/YYYY') AS "Due Date",
        pr.rejected_reason_code AS "Rejected Reason Code",
        pr.xfr_info AS "Info",
        (CASE
               WHEN art.ref_type = 'INVOICE' THEN inv_person.firstname
               WHEN art.ref_type = 'CREDIT_NOTE' THEN cn_person.firstname
               ELSE '-'
        END) AS "First name",
        (CASE
               WHEN art.ref_type = 'INVOICE' THEN inv_person.lastname
               WHEN art.ref_type = 'CREDIT_NOTE' THEN cn_person.lastname
               ELSE '-'
        END) AS "Last name",
        (CASE
               WHEN art.ref_type = 'INVOICE' THEN inv_person.center || 'p' || inv_person.id
               WHEN art.ref_type = 'CREDIT_NOTE' THEN cn_person.center || 'p' || cn_person.id
               ELSE '-'
        END) AS "Member ID",
        (CASE
               WHEN art.ref_type = 'INVOICE' THEN inv_pg.name
               WHEN art.ref_type = 'CREDIT_NOTE' THEN cn_pg.name
               ELSE '-'
        END) AS "Product Group",
        (CASE
               WHEN art.ref_type = 'INVOICE' THEN inv_pr.name
               WHEN art.ref_type = 'CREDIT_NOTE' THEN cn_pr.name
               ELSE '-'
        END) AS "Product",
        (CASE
               WHEN art.ref_type = 'INVOICE' THEN il.net_amount
               WHEN art.ref_type = 'CREDIT_NOTE' THEN cnl.net_amount
               ELSE 0
        END) AS "Price excl. Tax",
        (CASE
               WHEN art.ref_type = 'INVOICE' THEN (il.total_amount-il.net_amount)
               WHEN art.ref_type = 'CREDIT_NOTE' THEN (cnl.total_amount-cnl.net_amount)
               ELSE 0
        END) AS "Tax",
        (CASE
               WHEN art.ref_type = 'INVOICE' THEN il.total_amount
               WHEN art.ref_type = 'CREDIT_NOTE' THEN cnl.total_amount
               ELSE 0
        END) AS "Total Price",
        art.unsettled_amount AS "Open Amount"
FROM chelseapiers.payment_requests pr
JOIN chelseapiers.payment_request_specifications prs 
        ON pr.inv_coll_center = prs.center 
        AND pr.inv_coll_id = prs.id 
        AND pr.inv_coll_subid = prs.subid
JOIN chelseapiers.clearinghouses ch 
        ON pr.clearinghouse_id = ch.id
JOIN chelseapiers.account_receivables ar
        ON pr.center = ar.center
        AND pr.id = ar.id
JOIN chelseapiers.persons p
        ON ar.customercenter = p.center
        AND ar.customerid = p.id
LEFT JOIN chelseapiers.ar_trans art
        ON art.payreq_spec_center = prs.center
        AND art.payreq_spec_id = prs.id
        AND art.payreq_spec_subid = prs.subid
        AND art.ref_type IN ('INVOICE','CREDIT_NOTE')
LEFT JOIN chelseapiers.invoices i
        ON i.center = art.ref_center 
        AND i.id = art.ref_id
        AND art.ref_type = 'INVOICE'
LEFT JOIN chelseapiers.invoice_lines_mt il
        ON il.center = i.center
        AND il.id = i.id
LEFT JOIN chelseapiers.persons inv_person
        ON inv_person.center = il.person_center
        AND inv_person.id = il.person_id
LEFT JOIN chelseapiers.products inv_pr
        ON inv_pr.center = il.productcenter
        AND inv_pr.id = il.productid
LEFT JOIN chelseapiers.product_group inv_pg
        ON inv_pg.id = inv_pr.primary_product_group_id
LEFT JOIN chelseapiers.credit_notes cn
        ON cn.center = art.ref_center 
        AND cn.id = art.ref_id
        AND art.ref_type = 'CREDIT_NOTE'
LEFT JOIN chelseapiers.credit_note_lines_mt cnl
        ON cnl.center = cn.center
        AND cnl.id = cn.id
LEFT JOIN chelseapiers.persons cn_person
        ON cn_person.center = cnl.person_center
        AND cn_person.id = cnl.person_id
LEFT JOIN chelseapiers.products cn_pr
        ON cn_pr.center = cnl.productcenter
        AND cn_pr.id = cnl.productid
LEFT JOIN chelseapiers.product_group cn_pg
        ON cn_pg.id = cn_pr.primary_product_group_id
WHERE
        pr.req_date between :FromDate AND :ToDate
		AND pr.center IN (:Scope)

