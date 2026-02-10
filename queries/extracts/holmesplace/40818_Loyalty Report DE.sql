-- The extract is extracted from Exerp on 2026-02-08
-- Active and Temp Inactive, not inc Staff or under 12 years old
SELECT
     
     c.ID AS CENTER_ID,
     p.EXTERNAL_ID,
     p.CENTER||'p'||p.ID AS PERSON_KEY,
     p.FIRSTNAME,
     p.LASTNAME,
     peaEmail.TXTVALUE  AS "EMAIL",
     CASE WHEN p.SEX = 'M' THEN 'MALE'
          WHEN p.SEX = 'F' THEN 'FEMALE'
          ELSE p.SEX
     END    AS "SEX",
     peaChannelEmail.TXTVALUE    AS "ALLOW_CHANNEL_EMAIL",
     peaGDPROPTIN.TXTVALUE   AS "GDPR_OPTIN",
    peaLOYALTYDE.TXTVALUE AS "LOYALTY",
	peaLOYALTYDEREG.TXTVALUE AS "LOYYREG",
	peaLOYALTYDEADDON.TXTVALUE AS "LOYADDON",
    peaOSD.TXTVALUE AS  "ORIGINAL_START_DATE",
     extract('year' from age(to_date(peaOSD.TXTVALUE,'YYYY-MM-DD'))) "MEMBER_YEARS",
CASE WHEN p.STATUS = 1 THEN 'ACTIVE'
	WHEN p.STATUS = 3 THEN 'TEMP INACTIVE'
	END AS "STATUS",
	CASE WHEN extract('year' from age(to_date(peaOSD.TXTVALUE,'YYYY-MM-DD'))) IN (1,2) THEN 'BRONZE'
	WHEN extract('year' from age(to_date(peaOSD.TXTVALUE,'YYYY-MM-DD'))) IN (3) THEN 'SILVER'
	WHEN extract('year' from age(to_date(peaOSD.TXTVALUE,'YYYY-MM-DD'))) >= 4 THEN 'GOLD'
	ELSE '1st Year'
END AS "LEVEL"

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
    PERSON_EXT_ATTRS peaPRICEINCREASE
 ON
    p.center = peaPRICEINCREASE.PERSONCENTER
    AND p.id = peaPRICEINCREASE.PERSONID
    AND peaPRICEINCREASE.name = 'PRICEINCREASE'


 WHERE
    p.CENTER in ($$Scope$$)
    AND peaOSD.NAME = 'OriginalStartDate'
    --All active members with membership anniversary
    AND p.STATUS in (1,3)
   --Filter out members of staff
    AND p.PERSONTYPE <> 2
    --Filter out members under 12
    AND age(p.birthdate) > interval '12 year'
   

