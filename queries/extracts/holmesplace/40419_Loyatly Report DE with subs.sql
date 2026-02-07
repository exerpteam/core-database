SELECT
     
     c.ID AS CenterID,
     p.EXTERNAL_ID AS ExtID,
     p.CENTER||'p'||p.ID AS PersonID,
     p.FIRSTNAME AS FirstName,
     p.LASTNAME AS LastName,
     peaEmail.TXTVALUE  AS "Email",
     CASE WHEN p.SEX = 'M' THEN 'MALE'
          WHEN p.SEX = 'F' THEN 'FEMALE'
          ELSE p.SEX
     END    AS "Sex",
	p.birthdate as "BirthDate",
     peaChannelEmail.TXTVALUE    AS "AllowEmail",
     peaGDPROPTIN.TXTVALUE   AS "GdprOptin",
    peaLOYALTYDE.TXTVALUE AS "LOYALTY",
	peaLOYALTYDEREG.TXTVALUE AS "LOYYREG",
	peaLOYALTYDEADDON.TXTVALUE AS "LOYADDON",
    peaOSD.TXTVALUE AS  "OrigStartDate",
     extract('year' from age(to_date(peaOSD.TXTVALUE,'YYYY-MM-DD'))) "Years",
CASE WHEN p.STATUS = 1 THEN 'ACTIVE'
	WHEN p.STATUS = 3 THEN 'TEMP INACTIVE'
	END AS "Status",
	pr.name AS "Membership",
	CASE WHEN s.state = 2 THEN 'active'
		WHEN s.state = 4 THEN 'frozen'
		WHEN s.state = 8 THEN 'created'
END AS "SubscriptionState",
	s. start_date AS "StartDate",
	s.SUBSCRIPTION_PRICE MemberPrice,
	CASE WHEN extract('year' from age(to_date(peaOSD.TXTVALUE,'YYYY-MM-DD'))) IN (1) THEN 'BRONZE'
	WHEN extract('year' from age(to_date(peaOSD.TXTVALUE,'YYYY-MM-DD'))) IN (2,3) THEN 'SILVER'
	WHEN extract('year' from age(to_date(peaOSD.TXTVALUE,'YYYY-MM-DD'))) >= 4 THEN 'GOLD'
	ELSE '1st Year'
END AS "PotentialLevel"

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
    PERSON_EXT_ATTRS peaChannelSMS
 ON
    p.center = peaChannelSMS.PERSONCENTER
    AND p.id = peaChannelSMS.PERSONID
    AND peaChannelSMS.name = '_eClub_AllowedChannelSMS'
 LEFT JOIN
    PERSON_EXT_ATTRS peaChannelPhone
 ON
    p.center = peaChannelPhone.PERSONCENTER
    AND p.id = peaChannelPhone.PERSONID
    AND peaChannelPhone.name = '_eClub_AllowedChannelPhone'
 LEFT JOIN
    PERSON_EXT_ATTRS peaGDPROPTIN
 ON
    p.center = peaGDPROPTIN.PERSONCENTER
    AND p.id = peaGDPROPTIN.PERSONID
    AND peaGDPROPTIN.name = 'GDPROPTIN'
 LEFT JOIN
    PERSON_EXT_ATTRS peaGDPRDOUBLEOPTINdate
 ON
    p.center = peaGDPRDOUBLEOPTINdate.PERSONCENTER
    AND p.id = peaGDPRDOUBLEOPTINdate.PERSONID
    AND peaGDPRDOUBLEOPTINdate.name = 'GDPRDOUBLEOPTINdate'
 LEFT JOIN
    PERSON_EXT_ATTRS peaGDPROPTINDATE
 ON
    p.center = peaGDPROPTINDATE.PERSONCENTER
    AND p.id = peaGDPROPTINDATE.PERSONID
    AND peaGDPROPTINDATE.name = 'GDPROPTINDATE'
LEFT JOIN
    PERSON_EXT_ATTRS peaLOYALTYDE
 ON
    p.center = peaLOYALTYDE.PERSONCENTER
    AND p.id = peaLOYALTYDE.PERSONID
    AND peaLOYALTYDE.name = 'LOYALTYDE'
LEFT JOIN
    PERSON_EXT_ATTRS peaLOYALTYDEREG
 ON
    p.center = peaLOYALTYDEREG.PERSONCENTER
    AND p.id = peaLOYALTYDEREG.PERSONID
    AND peaLOYALTYDEREG.name = 'LOYALTYDEREG'
LEFT JOIN
    PERSON_EXT_ATTRS peaLOYALTYDEADDON
 ON
    p.center = peaLOYALTYDEADDON.PERSONCENTER
    AND p.id = peaLOYALTYDEADDON.PERSONID
    AND peaLOYALTYDEADDON.name = 'LOYALTYDEADDON'


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
    AND peaOSD.NAME = 'OriginalStartDate'
    --All active members with membership anniversary
    AND p.STATUS IN (1,3)--ACTIVE TEMP INACTIVE
	AND s.state IN (2,4) --Active Frozen 8 is Created
	AND pg.ID NOT IN (2802,1605,19815,1601,6,1201) --not coaching ptdd gymin pt clipcards free membership
	
	AND p.PERSONTYPE <> 2 --not staff
    --Filter out members under 12
    AND age(p.birthdate) > interval '12 year'
   

