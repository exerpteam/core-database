-- The extract is extracted from Exerp on 2026-02-08
--  
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
		phone.TXTVALUE,
		CC.*
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
			RELATIVES op_rel
				ON	
					(
						P.CENTER = op_rel.CENTER 
						AND P.ID = op_rel.ID 
						AND op_rel.RTYPE = 12 -- Payer Link
                        AND op_rel.STATUS < 3 ) -- Active Link
						
JOIN
            SUBSCRIPTIONS S
				ON
					(
						S.OWNER_CENTER = op_rel.RELATIVECENTER
						AND s.OWNER_ID = op_rel.RELATIVEID ) -- Link to member being paid for

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
	S.END_DATE is NULL -- Stop date is not present
AND
	S.STATE NOT IN (3,7) -- Ended, Extended
AND	
	P.STATUS IN (9) -- Contacts (Non-Member Payers)
AND 
	PG.ID NOT IN (239,242,249,209) -- Mem Cat: Kids, 16plus
AND
	T.PERSON_ID IS NULL -- They don't have a task already
AND
	phone.TXTVALUE IS NOT NULL -- Exclude members with no phone number
AND
	P.CENTER IN (SELECT C.ID FROM CENTERS C WHERE C.COUNTRY = 'GB') -- Only include UK Clubs