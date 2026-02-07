SELECT

a.EntryDate AS "Entry Date",
a.BookDate AS "Book Date",
a.MemberName AS "Member Name",
a.MemberPersonID AS "Member Person ID",
a.CompanyName AS "Company Name",
a.CompanyPersonId AS "Company Person Id",
a.InvoiceNumber AS "Invoice Number",
a.InvoiceDate AS "Invoice Date",
a.InvoiceDueDate AS "Invoice Due Date",
a.Province AS "Province",
SUM(a.PreTaxAmount) AS "Pre Tax Amount",
SUM(a.TaxAmount) AS "Tax Amount",
SUM(a.TotalAmount) AS "Total Amount",
a.Type AS "Type",
a.Info AS "Info",
a.Text AS "Text",
a.FamilyofEmployee AS "Family of Employee",
a.MemberExternalId AS "Member External ID"


FROM

(

SELECT

    TO_CHAR(LONGTODATEC(at.entry_time, 100),'YYYY-MM-DD') AS "entrydate",
	TO_CHAR(LONGTODATEC(at.trans_time, 100),'YYYY-MM-DD') AS "bookdate",
    (CASE
        WHEN per.fullname IS NOT NULL
        THEN perx.fullname
        WHEN pers.fullname IS NOT NULL
        THEN persx.fullname
        ELSE ''
        END) AS "membername",
    (CASE
        WHEN per.center IS NOT NULL
        THEN per.center||'p'||per.id
        WHEN pers.center IS NOT NULL
        THEN pers.center||'p'||pers.id
		
        ELSE ''
        END) AS "memberpersonid",
    p.fullname AS "companyname",
    p.center || 'p' || p.id AS "companypersonid",
	    prs.ref AS "invoicenumber",
    pr.req_date AS "invoicedate",
    pr.due_date AS "invoiceduedate",
    (CASE
        WHEN z.province IS NOT NULL
        THEN z.province
        ELSE z2.province
        END) AS "province",
    (CASE
        WHEN credmt.net_amount IS NOT NULL
        THEN credmt.net_amount
        WHEN inv1.net_amount IS NOT NULL
        THEN inv1.net_amount * -1
        ELSE NULL
        END) AS "pretaxamount",
    (CASE
        WHEN credmt.net_amount IS NOT NULL AND credmt.net_amount != 0
        THEN credmt.total_amount - credmt.net_amount
        WHEN inv1.net_amount IS NOT NULL AND inv1.net_amount != 0
        THEN (inv1.total_amount - inv1.net_amount) * -1
        WHEN credmt.net_amount = 0
        THEN 0
        WHEN inv1.net_amount = 0
        THEN 0
        ELSE NULL
        END) AS "taxamount",
      (CASE
        WHEN credmt.total_amount IS NOT NULL
        THEN credmt.total_amount
        WHEN inv1.total_amount IS NOT NULL
        THEN inv1.total_amount * -1
		ELSE at.amount
		END) AS "totalamount",
	(CASE
	WHEN at.ref_type = 'CREDIT_NOTE' OR at.ref_type = 'INVOICE'
	THEN 'INVOICE/CREDIT'
	WHEN ((at.ref_type = 'ACCOUNT_TRANS' AND at.text = 'Payment into account')
	OR at.collected = 2)
	THEN 'PAYMENT'
	WHEN at.ref_type = 'ACCOUNT_TRANS' AND at.text != 'Payment into account'
	THEN 'FINANCIAL TRANSACTION'
	ELSE NULL
	END) AS "type",
 
	(CASE
	WHEN at.ref_type = 'CREDIT_NOTE'
	THEN at.ref_center||'cred'||at.ref_id
	WHEN at.ref_type = 'INVOICE'
	THEN at.ref_center||'inv'||at.ref_id
	WHEN ((at.ref_type = 'ACCOUNT_TRANS' AND at.text = 'Payment into account')
	OR at.collected = 2)
	THEN at.info
	WHEN at.ref_type = 'ACCOUNT_TRANS' AND at.text != 'Payment into account'
	THEN 'FINANCIAL TRANSACTION'
	ELSE NULL
	END) AS "info",
(CASE
	WHEN cr.text IS NOT NULL AND cr.text != 'Subscription changed'
	THEN cr.text
	WHEN i3.text IS NOT NULL AND i3.text != 'Subscription changed'
	THEN i3.text	
	WHEN at.text IS NOT NULL AND at.ref_type = 'CREDIT_NOTE' AND credmt.text IS NULL
	THEN at.text

	WHEN credmt.text IS NOT NULL 
		AND credmt.text != 'All Club Access Paid in Full with Towels (KAP): Subscription changed'
		AND credmt.text != 'All Club Access Monthly (KAFP): Subscription changed'
		
	THEN credmt.text
	WHEN inv1.text IS NOT NULL
	THEN inv1.text
	
	WHEN at.text IS NOT NULL
	THEN at.text
	ELSE NULL
	END) AS "text",
    (CASE
        WHEN per2.fullname IS NOT NULL
        THEN per2.fullname
        ELSE pers2.fullname
        END) AS "familyofemployee",
	
	(CASE
        WHEN per.center IS NOT NULL
        THEN perx.external_id
        WHEN pers.center IS NOT NULL
	THEN persx.external_id
	ELSE ''
        END) AS "memberexternalid"
 
FROM
 
ar_trans at
 
LEFT JOIN payment_request_specifications prs
    ON at.payreq_spec_center = prs.center
    AND at.payreq_spec_id = prs.id
    AND at.payreq_spec_subid = prs.subid

JOIN ACCOUNT_RECEIVABLES ar
   ON at.ID = ar.ID 
   AND at.CENTER = ar.CENTER
 
JOIN PERSONS p
    ON p.ID = ar.CUSTOMERID 
    AND p.CENTER = ar.CUSTOMERCENTER

LEFT JOIN employees e
	ON at.employeecenter = e.center
	AND at.employeeid = e.id

LEFT JOIN persons px
	ON px.center = e.personcenter
	AND px.id = e.personid

LEFT JOIN invoice_lines_mt inv1
    ON at.ref_center = inv1.center
    AND at.ref_id = inv1.id
    AND at.ref_type ='INVOICE'


LEFT JOIN invoices i3
	ON inv1.center = i3.center
	AND inv1.id = i3.id
	
LEFT JOIN credit_note_lines_mt credmt
    ON at.ref_center = credmt.center
    AND at.ref_id = credmt.id
    AND at.ref_type ='CREDIT_NOTE'


LEFT JOIN credit_notes cr
	ON credmt.center = cr.center
	AND credmt.id = cr.id
 
LEFT JOIN payment_requests pr
    ON prs.center = pr.inv_coll_center
    AND prs.id = pr.inv_coll_id
    AND prs.subid = pr.inv_coll_subid
 
LEFT JOIN invoices i
    ON at.ref_center = i.sponsor_invoice_center
    AND at.ref_id = i.sponsor_invoice_id
    AND at.ref_type ='INVOICE'
 
LEFT JOIN persons per
    ON i.payer_center = per.center
    AND i.payer_id = per.id

LEFT JOIN persons perx
 	ON per.current_person_center = perx.center
	AND per.current_person_id = perx.id
 
LEFT JOIN relatives r
    ON perx.center = r.center
    AND perx.id = r.id
    AND r.rtype = 16
	AND r.status = 1
 
LEFT JOIN persons per2
    ON r.relativecenter = per2.center
    AND r.relativeid = per2.id
 
LEFT JOIN centers c
    ON per.center = c.id
 
LEFT JOIN zipcodes z
    ON c.zipcode = z.zipcode
 
LEFT JOIN invoices i2
    ON cr.invoice_center = i2.sponsor_invoice_center
    AND cr.invoice_id = i2.sponsor_invoice_id
 
LEFT JOIN persons pers
    ON i2.payer_center = pers.center
    AND i2.payer_id = pers.id

LEFT JOIN persons persx
 	ON pers.current_person_center = persx.center
	AND pers.current_person_id = persx.id

LEFT JOIN relatives r2
    ON persx.center = r2.center
    AND persx.id = r2.id
    AND r2.rtype = 16
	AND r.status = 1
 
LEFT JOIN persons pers2
    ON r2.relativecenter = pers2.center
    AND r2.relativeid = pers2.id
 
LEFT JOIN centers c2
    ON pers.center = c2.id
 
LEFT JOIN zipcodes z2
    ON c2.zipcode = z2.zipcode
 
WHERE
 
('All' = :reference OR prs.ref = :reference)
    AND (p.center,p.id) = (:CompanyID)
    AND (CASE
			WHEN 2 IN (:Collected) AND 0 NOT IN (:Collected) AND 1 NOT IN (:Collected)
			THEN ((at.ref_type = 'ACCOUNT_TRANS' AND at.text = 'Payment into account') OR at.collected = 2)
			ELSE at.collected IN (:Collected)
		END)	
	--Remove Migration transaction lines
	AND NOT (at.collected = 1 AND prs.ref IS NULL)
) a

GROUP BY
a.EntryDate,
a.BookDate,
a.MemberName,
a.MemberPersonID,
a.MemberExternalID,
a.CompanyName,
a.CompanyPersonId,
a.InvoiceNumber,
a.InvoiceDate,
a.InvoiceDueDate,
a.Province,
a.Type,
a.Info,
a.Text,
a.FamilyofEmployee
