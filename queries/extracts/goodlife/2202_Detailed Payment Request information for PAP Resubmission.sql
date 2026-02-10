-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center as CENTER,
    p.id as ID,
    pr.center as PR_CENTER,
    pr.id as PR_ID,
    pr.subid as PR_SUBID,
    p.center || 'p' || p.id            AS "PERSONKEY" ,
    TO_CHAR(pr.REQ_AMOUNT, 'FM99999.90') as REQ_AMOUNT,
    TO_CHAR(pr.REQ_DATE, 'MM-DD-YYYY')    ORIG_PAYMENT_DATE ,
    TO_CHAR(CASE WHEN ci.RECEIVED_DATE is not null then ci.RECEIVED_DATE + 7 else pr.XFR_DATE end, 'MM-DD-YYYY') RESUB_DATE ,
    pr.REJECTED_REASON_CODE,
    coalesce(ivl.TOTAL_AMOUNT,0) as REJECTION_FEE,
    prs.open_amount,
    pea_resubdate.txtvalue,
    pr.*
FROM
    PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.center = prs.center
    AND ar.id = prs.id

JOIN
    PERSONS p
ON
    p.center = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID

JOIN
    goodlife.payment_requests pr
ON
    prs.center = pr.INV_COLL_CENTER
    AND prs.id = pr.INV_COLL_ID
    AND prs.subid = pr.INV_COLL_SUBID
    AND pr.REQUEST_TYPE = 1
    AND pr.STATE NOT IN (1,2,3,4,8,12)
    --AND pr.REQ_DELIVERY is not null
    AND pr.REJECTED_REASON_CODE in ('01','08')

JOIN payment_agreements pr_pag on pr_pag.center = pr.center and pr_pag.id = pr.id and pr_pag.subid = pr.agr_subid

LEFT JOIN
    CLEARING_IN ci
ON
    ci.ID = pr.XFR_DELIVERY


LEFT JOIN
    invoice_lines_mt ivl
ON
    ivl.CENTER = pr.REJECT_FEE_INVLINE_CENTER
    AND ivl.ID = pr.REJECT_FEE_INVLINE_ID
    AND ivl.SUBID = pr.REJECT_FEE_INVLINE_SUBID


-- join to the current agreement
LEFT JOIN payment_agreements cur_pag on pr_pag.current_center = cur_pag.center and pr_pag.current_id = cur_pag.id and pr_pag.current_subid = cur_pag.subid

LEFT JOIN payment_requests rep_req on rep_req.inv_coll_center = prs.center and rep_req.inv_coll_id = prs.id and rep_req.inv_coll_subid = prs.subid
and rep_req.request_type = 6 and rep_req.state not in (8)

LEFT JOIN
    PERSON_EXT_ATTRS pea_resubdate
ON
    pea_resubdate.PERSONCENTER = p.center
    AND pea_resubdate.PERSONID = p.id
    AND pea_resubdate.NAME = 'ResubmissionPaymentDate'

WHERE
    ((cur_pag.state is not null and cur_pag.state in (2,4)) or (cur_pag.state is null and pr_pag.state in (2,4))) AND ar.BALANCE < 0
    AND coalesce(ci.RECEIVED_DATE,pr.REQ_DATE) > (current_date - 35)
    AND coalesce(ci.RECEIVED_DATE,pr.REQ_DATE) < (current_date - 4)
    AND p.sex != 'C'
    -- exclude already represented requests
    AND rep_req.center is null
    AND prs.open_amount > 0
    
    AND pr.center in (:scope)