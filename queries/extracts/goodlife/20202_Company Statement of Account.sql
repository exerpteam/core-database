SELECT DISTINCT
    p.fullname AS "Company Name"
    ,p.center || 'p' || p.id AS "Company Person ID"
    ,prs.ref AS "Invoice Number"
    ,pr.req_date AS "Invoice Date"
    ,pr.due_date AS "Invoice Due Date"
    ,prs.total_invoice_amount AS "Invoice Amount"
    ,prs.open_amount AS "Unsettled Amount"
FROM
	payment_request_specifications prs
JOIN ar_trans at
	ON at.payreq_spec_center = prs.center
    AND at.payreq_spec_id = prs.id
    AND at.payreq_spec_subid = prs.subid
JOIN ACCOUNT_RECEIVABLES ar
	ON at.ID = ar.ID 
	AND at.CENTER = ar.CENTER
JOIN PERSONS p
    ON p.ID = ar.CUSTOMERID 
    AND p.CENTER = ar.CUSTOMERCENTER
JOIN payment_requests pr
    ON prs.center = pr.center
    AND prs.id = pr.id
    AND prs.subid = pr.subid
WHERE
	p.sex = 'C'
	AND pr.clearinghouse_id IN (2,401)
	AND prs.open_amount != 0
	AND (p.center,p.id) = :CompanyID


UNION ALL
SELECT
    a.companyname AS "Company Name"
    ,a.companypersonid AS "Company Person ID"
    ,a.invoicenumber AS "Invoice Number"
    ,a.invoicedate AS "Invoice Date"
    ,a.invoiceduedate AS "Invoice Due Date"
    ,a.totalamount AS "Invoice Amount"
    ,a.totalamount - b.settledamount AS "Unsettled Amount"

FROM
    (
        SELECT
            p.fullname AS "companyname",
            p.center || 'p' || p.id AS "companypersonid",
            'Payment' AS "invoicenumber",
            NULL AS "invoicedate",
            NULL AS "invoiceduedate",
            NULL AS invoicetotalamount,
            NULL AS credittotalamount,
            at.amount AS totalamount,
            at.center,
            at.id,
            at.subid
        FROM ar_trans at
        JOIN ACCOUNT_RECEIVABLES ar
            ON at.ID = ar.ID 
            AND at.CENTER = ar.CENTER
	    	AND ar.ar_type = 4
		    AND (        
                at.ref_type = 'ACCOUNT_TRANS' 
                OR at.collected = 2
            )
		JOIN payment_accounts pa
			ON pa.center = ar.center
			AND pa.id = ar.id
		JOIN payment_agreements pag
			ON pag.center = pa.active_agr_center
			AND pag.id = pa.active_agr_id
			AND pag.subid = pa.active_agr_subid
			AND payment_cycle_config_id = 601
        JOIN PERSONS p
            ON p.ID = ar.CUSTOMERID 
            AND p.CENTER = ar.CUSTOMERCENTER
		WHERE (p.center,p.id) = :CompanyID
		
    ) a
JOIN 
    (
        SELECT
            SUM(am.amount) as settledamount,
            at.center,
            at.id,
            at.subid
        FROM
            ar_trans at
        JOIN ACCOUNT_RECEIVABLES ar
            ON at.ID = ar.ID 
            AND at.CENTER = ar.CENTER
            AND (
                at.ref_type = 'ACCOUNT_TRANS' 
                OR at.collected = 2
            )
		JOIN payment_accounts pa
			ON pa.center = ar.center
			AND pa.id = ar.id
		JOIN payment_agreements pag
			ON pag.center = pa.active_agr_center
			AND pag.id = pa.active_agr_id
			AND pag.subid = pa.active_agr_subid
			AND payment_cycle_config_id = 601
        JOIN PERSONS p
            ON p.ID = ar.CUSTOMERID 
            AND p.CENTER = ar.CUSTOMERCENTER
        LEFT JOIN art_match am
            ON am.art_paying_center = at.center
            AND am.art_paying_id = at.id
            AND am.art_paying_subid = at.subid
        LEFT JOIN ar_trans at1
            ON am.art_paid_center = at1.center
            AND am.art_paid_id = at1.id
            AND am.art_paid_subid = at1.subid
		WHERE (p.center,p.id) = :CompanyID

        GROUP BY
            at.id,
            at.center,
            at.subid
) b
    ON a.center = b.center
    AND a.id = b.id
    AND a.subid = b.subid
WHERE
    a.totalamount - b.settledamount != 0
ORDER BY "Company Name"
