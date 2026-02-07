SELECT distinct
    c.shortname as Club,
    p.center ||'p'|| p.id as PersonID,
    p.firstname as Nome,
    p.lastname as Cognome, 
    prod.name as Subscription,
(CASE  s.STATE  
		WHEN 2 THEN 'ACTIVE'  
		WHEN 3 THEN 'ENDED'  
		WHEN 4 THEN 'FROZEN'  
		WHEN 7 THEN 'WINDOW'  
		WHEN 8 THEN 'CREATED' 
		ELSE 'UNKNOWN' 
	END) AS Subscription_Status,

    (CASE  p.persontype  
		WHEN 0 THEN 'Private'  
		WHEN 1 THEN 'Student'  
		WHEN 2 THEN 'Staff'  
		WHEN 3 THEN 'Friend'  
		WHEN 4 THEN 'Corporate'  
		WHEN 5 THEN 'Onemancorporate'  
		WHEN 6 THEN 'Family'  
		WHEN 7 THEN 'Senior'  
		WHEN 8 THEN 'Guest'  
		WHEN 9 THEN  'Child'  
	    WHEN 10 THEN  'External_Staff' 
	    ELSE 'Unknown' END) AS Person_Type,
    (CASE p.STATUS
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
    END) AS Person_Status,
    pea.txtvalue AS Loyalty_TCs 

FROM
    products prod
JOIN 
    SUBSCRIPTIONTYPES st 
    ON prod.center = st.center AND prod.id = st.id    
JOIN 
    SUBSCRIPTIONS s
    ON st.center = s.SUBSCRIPTIONTYPE_CENTER AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PERSONS p
    ON p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID



JOIN
	centers c
	on c.id = p.center 
	and c.country = 'IT'
LEFT JOIN 
	PERSON_EXT_ATTRS pea
ON 
	pea.PERSONCENTER = p.CENTER AND pea.PERSONID = p.ID 


WHERE
    p.center  in ($$scope$$)
    and prod.blocked = 0
    and p.STATUS in (1,3)
    and s.state in (2,4)
and p.persontype in (0,1,3,4,5,6,7)
and pea.NAME = 'LoyaltyTCs'
and pea.txtvalue is not null

