-- People that represent the first part of a relation
SELECT *
FROM
(SELECT		COALESCE(p.external_id, cp.external_id) AS "ExternalId",
			COALESCE(rperson.external_id, rcp.external_id) AS "RelativeExternalId",
			1 as "PaidByMe",
			'Paid for by me' AS "RelationTypeName",
			rel.status AS "RelationStatus",
			(CASE
				WHEN rel.status = 0
				THEN 'Lead'
				WHEN rel.status = 1
				THEN 'Active'
				WHEN rel.status = 2
				THEN 'Inactive'
				WHEN rel.status = 3
				THEN 'Blocked'
			END) AS "RelationStatusName",
			TO_CHAR(longtodatec(scl.book_start_time, p.center),'YYYY-MM-DD HH24:MI') AS "RelationFromDate",
			TO_CHAR(longtodatec(scl.book_end_time, p.center),'YYYY-MM-DD HH24:MI') AS "RelationToDate",
			rel.expiredate AS "RelationExpiryDate" 
FROM	    persons p
			JOIN persons cp ON 
				cp.center = p.transfers_current_prs_center AND 
				cp.id = p.transfers_current_prs_id AND
				cp.external_id=:PersonExternalId
			JOIN relatives rel ON
				rel.center = p.center
				AND rel.id = p.id
				AND rel.rtype = 12
			LEFT JOIN state_change_log scl ON
				scl.center = rel.center
				AND scl.id = rel.id
				AND scl.subid = rel.subid
				AND scl.entry_type = 4
				AND scl.stateid = 1
			JOIN persons rperson ON
				rperson.center = rel.relativecenter
				AND rperson.id = rel.relativeid
			JOIN persons rcp ON 
				rcp.center = rperson.transfers_current_prs_center AND 
				rcp.id = rperson.transfers_current_prs_id

UNION

-- People that represent the second part of a relation
SELECT		COALESCE(p.external_id, cp.external_id) AS "ExternalId",
			COALESCE(rperson.external_id, rcp.external_id) AS "RelativeExternalId",
			0 as "PaidByMe",
			'My payer' AS "RelationTypeName",
			rel.status AS "RelationStatus",
			(CASE
					WHEN rel.status = 0
					THEN 'Lead'
					WHEN rel.status = 1
					THEN 'Active'
					WHEN rel.status = 2
					THEN 'Inactive'
					WHEN rel.status = 3
					THEN 'Blocked'
				END) AS "RelationStatusName",
			TO_CHAR(longtodatec(scl.book_start_time, p.center),'YYYY-MM-DD HH24:MI') AS "RelationFromDate",
			TO_CHAR(longtodatec(scl.book_end_time, p.center),'YYYY-MM-DD HH24:MI') AS "RelationToDate",
			rel.expiredate AS "RelationExpiryDate"                               
FROM		persons p
			JOIN persons cp ON 
				cp.center = p.transfers_current_prs_center AND 
				cp.id = p.transfers_current_prs_id AND
				cp.external_id=:PersonExternalId
			JOIN relatives rel ON
				rel.relativecenter = p.center
				AND rel.relativeid = p.id
				AND rel.rtype = 12
			LEFT JOIN state_change_log scl ON
				scl.center = rel.center
				AND scl.id = rel.id
				AND scl.subid = rel.subid
				AND scl.entry_type = 4
				AND scl.stateid = 1    
			JOIN persons rperson ON
				rperson.center = rel.center
				AND rperson.id = rel.id
			JOIN persons rcp ON 
				rcp.center = rperson.transfers_current_prs_center AND 
				rcp.id = rperson.transfers_current_prs_id) a
ORDER BY "ExternalId"