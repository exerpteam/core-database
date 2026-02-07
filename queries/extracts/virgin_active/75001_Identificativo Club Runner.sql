 SELECT DISTINCT
     p.center as center_id,
     p.center||'p'||p.id as person_id,
     PEA.TXTVALUE as club_runner_id,
     CASE  p.PERSONTYPE  
		WHEN 0 THEN 'PRIVATE'  
		WHEN 1 THEN 'STUDENT'  
		WHEN 2 THEN 'STAFF'  
		WHEN 3 THEN 'FRIEND'  
		WHEN 4 THEN 'CORPORATE'  
		WHEN 5 THEN 'ONEMANCORPORATE' 
		WHEN 6 THEN 'FAMILY' 
		WHEN 7 THEN 'SENIOR'  
		WHEN 8 THEN 'GUEST' 
		ELSE 'UNKNOWN' 
		END AS person_type,
	 CASE p.status 
		WHEN 1 THEN 'ACTIVE'
		WHEN 3 THEN 'TEMPORARY INACTIVE'
		WHEN 9 THEN 'CONTACT'
		ELSE ''
		END as person_status
    FROM 
		PERSONS P
 	LEFT JOIN
    	PERSON_EXT_ATTRS PEA
    ON
        p.center=PEA.PERSONCENTER
        AND p.id=PEA.PERSONID
        AND PEA.name='_eClub_OldSystemPersonId'
        AND PEA.TXTVALUE IS NOT NULL
	JOIN
    	SUBSCRIPTIONS s
    ON
             s.OWNER_CENTER = p.CENTER
             AND s.OWNER_ID = p.ID
             AND s.STATE IN (2,4)
			--WINDOW, FROZEN
	where p.center in ($$scope$$)

