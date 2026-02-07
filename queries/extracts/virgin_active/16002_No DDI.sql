SELECT
        cc.PERSONCENTER,
        cc.PERSONID,
		P.CENTER || 'p' || P.ID AS "PERSON ID",
		PG.NAME,
		PR.NAME,
		S.ID,
		S.END_DATE,
		S.STATE,
		phone.NAME,
		phone.TXTVALUE
FROM
			CASHCOLLECTIONCASES cc
JOIN
			ACCOUNT_RECEIVABLES ar
				ON
                    (
						ar.CUSTOMERCENTER = cc.PERSONCENTER
						AND ar.CUSTOMERID = cc.PERSONID
						AND ar.AR_TYPE = 4
						AND ar.BALANCE >= 0 ) -- No balance or credit in the payment account
JOIN
            PERSONS P
				ON
					(
						P.CENTER = cc.PERSONCENTER
						AND P.ID = cc.PERSONID )
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
WHERE
    cc.MISSINGPAYMENT = 0 -- Missing Agreement Case
AND 
	cc.CLOSED = 0 -- Missing Agreement Case is Open
AND
	s.END_DATE is NULL -- Stop date is not present
AND
	S.STATE NOT IN (3,7) -- Ended, Extended
AND	
	P.STATUS IN (1,4) -- Active, Transferred (Do not want to include Temporary Inactive (Debt or Frozen) members)
AND 
	PG.ID NOT IN (239,242,249,209) -- Mem Cat: Kids, 16plus
AND
	T.PERSON_ID IS NULL -- They don't have a task already
AND
	phone.TXTVALUE IS NOT NULL -- Exclude members with no phone number
AND
	P.CENTER IN (SELECT C.ID FROM CENTERS C WHERE C.COUNTRY = 'GB') -- Only include UK Clubs