SELECT
		P.CENTER,
		P.ID,
		P.CENTER || 'p' || P.ID AS "PERSON ID",
		PG.NAME,
		PR.NAME,
		S.ID,
		S.END_DATE,
		S.STATE,
		phone.NAME,
		phone.TXTVALUE,
		email.TXTVALUE
		
FROM
            PERSONS P
JOIN
            SUBSCRIPTIONS S
				ON
					(
						S.OWNER_CENTER = P.CENTER
						AND s.OWNER_ID = P.ID )

JOIN
            SUBSCRIPTIONTYPES ST
                ON
                    (
                        S.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
                        AND S.SUBSCRIPTIONTYPE_ID = ST.ID )
						
JOIN
            PRODUCTS PR
                ON
                    (
                        ST.CENTER = PR.CENTER
                        AND ST.ID = PR.ID )
JOIN
            PRODUCT_GROUP PG
                ON
					(
                   		PG.ID = PR.PRIMARY_PRODUCT_GROUP_ID
                    	AND PG.NAME LIKE 'Mem Cat%' )

LEFT JOIN
			TASKS T  -- Exclude members who have a task already
				ON
					(
						T.PERSON_CENTER = P.CENTER
						AND T.PERSON_ID = P.ID )
						-- add in T.Type_ID = ? when known
JOIN
			PERSON_EXT_ATTRS phone
				ON
					(
						    P.CENTER = phone.PERSONCENTER
    						AND P.ID = phone.PERSONID 
							AND phone.NAME IN ('_eClub_PhoneHome','_eClub_PhoneSMS','_eClub_PhoneWork') )
LEFT JOIN
			PERSON_EXT_ATTRS email
				ON
					(
						    P.CENTER = email.PERSONCENTER
    						AND P.ID = email.PERSONID 
							AND email.NAME IN ('_eClub_Email') )
LEFT JOIN
			CASHCOLLECTIONCASES ccc
				ON
					(
							P.center = ccc.personcenter
							AND p.ID = ccc.personID	)
WHERE
	s.END_DATE is NOT NULL -- Stop date is present
AND
	S.STATE NOT IN (3,7) -- Ended, Extended
AND	
	P.STATUS IN (1,3,4) -- Active, Temporary Inactive, Transferred
AND 
	PG.ID NOT IN (247,268) -- Mem Cat: Prudential, Mem Cat: Racquets Prudential
AND 
	PG.ID NOT IN (239,242,249,209) -- Mem Cat: Kids, 16plus
AND
	PG.ID NOT IN (219) -- Mem Cat: Complimentary
AND	
	PR.NAME NOT LIKE '%Upfront%'
AND	
	PR.NAME NOT LIKE '%Annual%'
AND	
	PR.NAME NOT LIKE '%Temp%'
AND	
	PR.NAME NOT LIKE '%Life%'
AND	
	PR.NAME NOT LIKE '%Funded%'
AND	
	PR.NAME NOT LIKE '%Gymflex%'
AND
	p.CENTER <> 405 -- Exclude Chiswick Riverside
AND
	T.PERSON_ID IS NULL -- They don't have a task already
AND
	phone.TXTVALUE IS NOT NULL -- Exclude members with no phone number
AND
	(email.TXTVALUE IS NULL OR PR.NAME LIKE '%Corporate%' OR PR.NAME LIKE '%Joint%') -- Exclude members who have an e-mail address, unless they are Joint or Corporate, in which case include them if they have an e-mail address
AND
	P.CENTER IN (SELECT C.ID FROM CENTERS C WHERE C.COUNTRY = 'GB') -- Only include UK Clubs
AND
            NOT EXISTS
            (
                SELECT
                    1
                FROM
                    CASHCOLLECTIONCASES ccc
                WHERE
                    ccc.PERSONCENTER = p.CENTER
                    AND ccc.PERSONID = p.ID 
					AND ccc.closed = 0 )	
