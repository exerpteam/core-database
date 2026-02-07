	
select 
	p.external_id,
	p.center||'p'||p.ID AS "Member id",
    p.FULLNAME AS "Full name",
    pag.Ref AS "Ref.",
    pag.STATE AS "Agreement_state",
	pr.STATE AS "Payment_req_Status",
	pr.req_date AS "Payment_req_date",
	pr.due_date AS "Due_Date",
	pr.req_amount AS "Req_Amount",
	pr.clearinghouse_id as "Clearing_ID",
	pr.creditor_id AS "Creditor_ID",
	prs.open_amount AS "Open_Amount",

	
	
	
	CASE p.status
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS PERSON_STATUS,
    CASE p.persontype
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        WHEN 9 THEN 'CHILD'
        WHEN 10 THEN 'EXTERNAL_STAFF'
        ELSE 'UNKNOWN'
    END AS PERSONTYPE
     
FROM persons p

LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.center = ar.center
    AND pac.ID = ar.ID

JOIN
    HP.AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.ID = ar.ID
JOIN
    PAYMENT_AGREEMENTS pag
ON
    pac.ACTIVE_AGR_CENTER = pag.CENTER
    AND pac.ACTIVE_AGR_ID = pag.ID
    AND pac.ACTIVE_AGR_SUBID = pag.SUBID

JOIN payment_request_specifications prs
ON
prs.CENTER = pac.ACTIVE_AGR_CENTER
AND prs.ID = pac.ACTIVE_AGR_ID

JOIN
     PAYMENT_REQUESTS pr
ON
    prs.CENTER = pr.INV_COLL_CENTER
    AND prs.ID = pr.INV_COLL_ID
    AND prs.SUBID = pr.INV_COLL_SUBID
        WHERE
			P.center IN (:center) 
    	AND P.STATUS IN (:PersonStatus)
		AND ar.CENTER = prs.CENTER
		AND ar.AR_TYPE = 4
        AND ar.ID = prs.ID
        AND pr.REQ_DATE >= (:PR_From)
		AND pr.REQ_DATE <= (:PR_To)
GROUP BY
    p.CENTER,
    p.ID,
pag.Ref,
pag.STATE,
pr.STATE,
pr.req_date,
pr.due_date,
pr.req_amount,
pr.clearinghouse_id,
pr.creditor_id,
prs.open_amount

	
    
    