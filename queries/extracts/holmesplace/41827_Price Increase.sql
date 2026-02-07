SELECT
     
     c.ID AS CenterID,
     p.EXTERNAL_ID AS ExtID,
     p.CENTER||'p'||p.ID AS PersonID,
     p.FIRSTNAME AS FirstName,
     p.LASTNAME AS LastName,
     peaEmail.TXTVALUE  AS "Email",
     p.birthdate as "BirthDate",
     peaOSD.TXTVALUE AS  "OrigStartDate",
     extract('year' from age(to_date(peaOSD.TXTVALUE,'YYYY-MM-DD'))) "MemberYears",
CASE WHEN p.STATUS = 1 THEN 'ACTIVE'
	WHEN p.STATUS = 3 THEN 'TEMP INACTIVE'
	END AS "Status",
	pr.name AS "Membership",
	CASE WHEN s.state = 2 THEN 'active'
		WHEN s.state = 4 THEN 'frozen'
		WHEN s.state = 8 THEN 'created'
END AS "SubscriptionState",
	peaLASTPRICEINCREASE.TXTVALUE AS "LastPriceIncrease",
	s.binding_end_date AS "BindingEnd",
	s. start_date AS "StartDate",
	s.end_date AS "EndDate",
	s.SUBSCRIPTION_PRICE AS "MemberPrice",
	s.binding_price AS "BindingPrice",
	pr.price   AS "ProductPrice",
	CASE WHEN pr.price < s.SUBSCRIPTION_PRICE THEN 'PriceCheck' END AS "HighPrice",
	CASE WHEN s.SUBSCRIPTION_PRICE <> s.binding_price THEN 'CheckBindingPrice' END AS "PricevBinding",
	s.is_price_update_excluded AS "Exclude",
	peaPRICEINCREASE.TXTVALUE AS "PriceIncrease"
	

 FROM
     CENTERS c
 JOIN
     PERSONS p
 ON
     p.CENTER = c.ID
 
 LEFT JOIN
    PERSON_EXT_ATTRS peaOSD
 ON
    p.center = peaOSD.PERSONCENTER
    AND p.id = peaOSD.PERSONID
    AND peaOSD.name = 'OriginalStartDate'
 LEFT JOIN
    PERSON_EXT_ATTRS peaEmail
 ON
    p.center = peaEmail.PERSONCENTER
    AND p.id = peaEmail.PERSONID
    AND peaEmail.name = '_eClub_Email'
 LEFT JOIN
    PERSON_EXT_ATTRS peaPhone
 ON
    p.center = peaPhone.PERSONCENTER
    AND p.id = peaPhone.PERSONID
    AND peaPhone.name = '_eClub_PhoneSMS'
 LEFT JOIN
    PERSON_EXT_ATTRS peaChannelEmail
 ON
    p.center = peaChannelEmail.PERSONCENTER
    AND p.id = peaChannelEmail.PERSONID
    AND peaChannelEmail.name = '_eClub_AllowedChannelEmail'
 
LEFT JOIN
    PERSON_EXT_ATTRS peaLASTPRICEINCREASE
 ON
    p.center = peaLASTPRICEINCREASE.PERSONCENTER
    AND p.id = peaLASTPRICEINCREASE.PERSONID
    AND peaLASTPRICEINCREASE.name = 'LASTPRICEINCREASE'

LEFT JOIN
    PERSON_EXT_ATTRS peaPRICEINCREASE
 ON
    p.center = peaPRICEINCREASE.PERSONCENTER
    AND p.id = peaPRICEINCREASE.PERSONID
    AND peaPRICEINCREASE.name = 'PRICEINCREASE'



LEFT JOIN 
    SUBSCRIPTIONS s
ON
	s.OWNER_CENTER = p.center
	AND s.OWNER_ID = p.id
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = pr.PRIMARY_PRODUCT_GROUP_ID


 WHERE
    p.CENTER in ($$Scope$$)
    AND s.binding_end_date  >= $$FromBindingEnd$$
	AND s.binding_end_date  <= $$ToBindingEnd$$
    --All active members with membership anniversary
    AND p.STATUS IN (1,3)--ACTIVE TEMP INACTIVE
	AND s.state IN (2,4,8) --Active Frozen Created
	AND pg.ID NOT IN (2802,1605,19815,1601,6,1201,9) --not coaching ptdd gymin pt clipcards free membership ADDON
	
	AND p.PERSONTYPE <> 2 --not staff
    
   

