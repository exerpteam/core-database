-- This is the version from 2026-02-05
--  
SELECT 
    P.CENTER || 'p' || P.ID AS memberid,
    P.FullNAME,
	p.BIRTHDATE,
    CASE P.STATUS
        WHEN 1 THEN 'ACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        ELSE 'Undefined'
    END AS PERSON_STATUS,
    s.start_date as Sub_startdate,
	A.center AS agreement_center,
    A.id AS agreement_id,
    A.subid AS agreement_subid,
    A.state AS agreement_state,
    A.ref AS agreement_reference,
    
    CASE A.state 
        WHEN 1 THEN 'Created'
        WHEN 2 THEN 'Sent'
        WHEN 3 THEN 'Failed'
        WHEN 4 THEN 'OK'
        WHEN 5 THEN 'Ended, bank'
        WHEN 6 THEN 'Ended, clearing house'
        WHEN 7 THEN 'Ended, debtor'
        WHEN 8 THEN 'Cancelled, not sent'
        WHEN 9 THEN 'Cancelled, sent'
        WHEN 10 THEN 'Ended, creditor'
        WHEN 11 THEN 'No agreement (deprecated)'
        WHEN 12 THEN 'Cash payment (deprecated)'
        WHEN 13 THEN 'Agreement not needed (invoice payment)'
        WHEN 14 THEN 'Agreement information incomplete'
    END AS state,
    P.last_active_start_date AS latest_active_membership,
    rel.CENTER || 'p' || rel.ID AS other_payer,
	CASE p.persontype
    WHEN 0 THEN 'Private'
    WHEN 1 THEN 'Student'
    WHEN 2 THEN 'Staff'
    WHEN 3 THEN 'Friend'
    WHEN 4 THEN 'Corporate'
    WHEN 5 THEN 'Onemancorporate'
    WHEN 6 THEN 'Family'
    WHEN 7 THEN 'Senior'
    WHEN 8 THEN 'Guest'
    WHEN 9 THEN 'Child'
    WHEN 10 THEN 'External_Staff'
    ELSE 'Undefined'
END AS PersonType


FROM 
    PERSONS P

JOIN account_receivables AR 
    ON AR.customercenter = P.center
    AND AR.customerid = P.id
    AND AR.ar_type = 4

LEFT JOIN RELATIVES rel 
    ON rel.RELATIVECENTER = P.center
    AND rel.RELATIVEID = P.id
    AND rel.RTYPE = 12
    AND rel.STATUS <> 3

LEFT JOIN payment_agreements A 
    ON AR.center = A.center 
    AND AR.id = A.id

JOIN
    FW.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND s.STATE IN (2,4)

WHERE 
    P.center IN (:Center)
	AND (rel.CENTER IS NULL OR rel.ID IS NULL)
	AND P.STATUS IN (1, 3)
    AND A.subid IS NULL
	AND EXTRACT(YEAR FROM AGE(p.BIRTHDATE)) BETWEEN 11 AND 17
order by s.start_date desc