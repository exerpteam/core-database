SELECT DISTINCT
	p.CENTER || 'p' || p.ID AS Person_ID,
	s.CENTER || 'ss' || s.ID AS Subscription_ID,
	c.SHORTNAME AS Club,
    CASE  p.STATUS  
		WHEN 0 THEN 'LEAD'  
		WHEN 1 THEN 'ACTIVE'  
		WHEN 2 THEN 'INACTIVE'  
		WHEN 3 THEN 'TEMPORARYINACTIVE'  
		WHEN 4 THEN 'TRANSFERED'  
		WHEN 5 THEN 'DUPLICATE'  
		WHEN 6 THEN 'PROSPECT'  
		WHEN 7 THEN 'DELETED' 
		WHEN 8 THEN  'ANONYMIZED'  
		WHEN 9 THEN  'CONTACT'  
		ELSE 'UNKNOWN' END AS Person_Status,
 	CASE  s.STATE  
		WHEN 2 THEN 'ACTIVE'  
		WHEN 3 THEN 'ENDED'  
		WHEN 4 THEN 'FROZEN'  
		WHEN 7 THEN 'WINDOW'  
		WHEN 8 THEN 'CREATED' 
		ELSE 'UNKNOWN' 
	END AS Subscription_Status,
    --CASE s.SUB_STATE  
		--WHEN 1 THEN 'NONE'  
		--WHEN 2 THEN 'AWAITING_ACTIVATION'  
		--WHEN 3 THEN 'UPGRADED'  
		--WHEN 4 THEN 'DOWNGRADED'  
		--WHEN 5 THEN 'EXTENDED'  
		--WHEN 6 THEN  'TRANSFERRED' 
		--WHEN 7 THEN 'REGRETTED' 
		--WHEN 8 THEN 'CANCELLED' 
		--WHEN 9 THEN 'BLOCKED' 
		--WHEN 10 THEN 'CHANGED' 
		--ELSE 'UNKNOWN' 
	--END AS Subscription_Sub_State,
	s.BINDING_END_DATE AS Binding_End_Date,
	sp.PRICE AS Subscription_price,
	s.start_date AS Subscription_Start_Date,
	s.end_date AS Subscription_End_Date,
	prod.name AS Subscription_Name,
    CASE
        WHEN op.fullname IS NOT NULL
        THEN cc2.AMOUNT
        ELSE cc.AMOUNT
    END AS debt_case_amount,
    CASE
        WHEN op.fullname IS NOT NULL
        THEN cc2.STARTDATE
        ELSE cc.STARTDATE
    END AS debt_case_start_date
 FROM
     SUBSCRIPTIONS s
 JOIN
     PERSONS p
 ON
     p.CENTER = s.OWNER_CENTER
     AND p.ID = s.OWNER_ID
 JOIN
     CENTERS c
 ON
     c.id = p.CENTER
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND prod.ID = s.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     SUBSCRIPTION_PRICE sp
 ON
     sp.SUBSCRIPTION_CENTER = s.CENTER
     AND sp.SUBSCRIPTION_ID = s.ID
     AND sp.FROM_DATE <= CURRENT_TIMESTAMP
     AND (
         sp.TO_DATE IS NULL
         OR sp.TO_DATE > CURRENT_TIMESTAMP)
     AND sp.APPLIED = 1
     AND sp.CANCELLED = 0
 LEFT JOIN
     RELATIVES rel
 ON
     rel.RTYPE = 12
     AND rel.STATUS = 1
     AND rel.RELATIVECENTER = p.CENTER
     AND rel.RELATIVEID = p.ID
 LEFT JOIN
     PERSONS op
 ON
     op.CENTER = rel.CENTER
     AND op.ID = rel.ID
 LEFT JOIN
     CASHCOLLECTIONCASES cc
 ON
     cc.PERSONCENTER = p.CENTER
     AND cc.PERSONID = p.ID
     AND cc.CLOSED = 0
     AND cc.MISSINGPAYMENT = 1
 LEFT JOIN
     CASHCOLLECTIONCASES cc2
 ON
     cc2.PERSONCENTER = op.CENTER
     AND cc2.PERSONID = op.ID
     AND cc2.CLOSED = 0
     AND cc2.MISSINGPAYMENT = 1
 LEFT JOIN
     SUBSCRIPTIONPERIODPARTS spp
 ON
     spp.CENTER = s.CENTER
     AND spp.ID = s.id
     AND spp.SPP_STATE = 1
     AND s.BILLED_UNTIL_DATE IS NOT NULL
     AND spp.TO_DATE = s.BILLED_UNTIL_DATE
 LEFT JOIN
     SPP_INVOICELINES_LINK link
 ON
     link.PERIOD_CENTER = spp.CENTER
     AND link.PERIOD_ID = spp.ID
     AND link.PERIOD_SUBID = spp.SUBID
 LEFT JOIN
     INVOICELINES invl
 ON
     invl.CENTER = link.INVOICELINE_CENTER
     AND invl.id = link.INVOICELINE_ID
     AND invl.SUBID = link.INVOICELINE_SUBID
WHERE 
	p.status in (1, 2, 3)
AND
	s.end_date >= ($$subscription_end_date_from$$)
AND 
	s.end_date <= ($$subscription_end_date_to$$)
AND 
	s.center in ($$scope$$)
--AND 
--	(cc.AMOUNT != 0 OR cc2.AMOUNT != 0)
AND (
        -- Se il socio è il titolare dei pagamenti ed è insoluto
        (s.OWNER_CENTER = cc.PERSONCENTER AND s.OWNER_ID = cc.PERSONID AND cc.AMOUNT != 0 AND s.SUB_STATE != 8)
        OR 
        -- Se il socio non è il titolare dei pagamenti ma ha un debito
        (s.OWNER_CENTER != cc.PERSONCENTER OR s.OWNER_ID != cc.PERSONID) AND cc2.AMOUNT != 0
        OR
        -- Se il socio non ha una relazione ma ha un debito
        (cc.PERSONCENTER IS NULL AND cc.PERSONID IS NULL AND cc.AMOUNT != 0)
    )


