SELECT
     
     c.ID AS CENTER_ID,
     p.EXTERNAL_ID,
     cp.CENTER||'p'||cp.ID AS PERSON_KEY,
     cp.FIRSTNAME,
     cp.LASTNAME,
     peaEmail.TXTVALUE  AS "EMAIL",
     CASE WHEN cp.SEX = 'M' THEN 'MALE'
          WHEN cp.SEX = 'F' THEN 'FEMALE'
          ELSE cp.SEX
     END    AS "SEX",
     peaChannelEmail.TXTVALUE    AS "ALLOW_CHANNEL_EMAIL",
     peaGDPROPTIN.TXTVALUE   AS "GDPR_OPTIN",
    peaLOYALTYDE.TXTVALUE AS "LOYALTY",
	peaLOYALTYDEREG.TXTVALUE AS "LOYYREG",
	peaLOYALTYDEADDON.TXTVALUE AS "LOYADDON",
    peaOSD.TXTVALUE AS  "ORIGINAL_START_DATE",
     extract('year' from age(to_date(peaOSD.TXTVALUE,'YYYY-MM-DD'))) "MEMBER_YEARS",
CASE WHEN cp.STATUS = 1 THEN 'ACTIVE'
	WHEN cp.STATUS = 3 THEN 'TEMP INACTIVE'
	END AS "STATUS"
 FROM
     CENTERS c
 JOIN
     PERSONS p
 ON
     p.CENTER = c.ID
 JOIN
    PERSONS cp
 ON
    cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.ID = p.TRANSFERS_CURRENT_PRS_ID
 LEFT JOIN
    PERSON_EXT_ATTRS peaOSD
 ON
    cp.center = peaOSD.PERSONCENTER
    AND cp.id = peaOSD.PERSONID
    AND peaOSD.name = 'OriginalStartDate'
 LEFT JOIN
    PERSON_EXT_ATTRS peaEmail
 ON
    cp.center = peaEmail.PERSONCENTER
    AND cp.id = peaEmail.PERSONID
    AND peaEmail.name = '_eClub_Email'
 LEFT JOIN
    PERSON_EXT_ATTRS peaPhone
 ON
    cp.center = peaPhone.PERSONCENTER
    AND cp.id = peaPhone.PERSONID
    AND peaPhone.name = '_eClub_PhoneSMS'
 LEFT JOIN
    PERSON_EXT_ATTRS peaChannelEmail
 ON
    cp.center = peaChannelEmail.PERSONCENTER
    AND cp.id = peaChannelEmail.PERSONID
    AND peaChannelEmail.name = '_eClub_AllowedChannelEmail'
 LEFT JOIN
    PERSON_EXT_ATTRS peaChannelSMS
 ON
    cp.center = peaChannelSMS.PERSONCENTER
    AND cp.id = peaChannelSMS.PERSONID
    AND peaChannelSMS.name = '_eClub_AllowedChannelSMS'
 LEFT JOIN
    PERSON_EXT_ATTRS peaChannelPhone
 ON
    cp.center = peaChannelPhone.PERSONCENTER
    AND cp.id = peaChannelPhone.PERSONID
    AND peaChannelPhone.name = '_eClub_AllowedChannelPhone'
 LEFT JOIN
    PERSON_EXT_ATTRS peaGDPROPTIN
 ON
    cp.center = peaGDPROPTIN.PERSONCENTER
    AND cp.id = peaGDPROPTIN.PERSONID
    AND peaGDPROPTIN.name = 'GDPROPTIN'
 LEFT JOIN
    PERSON_EXT_ATTRS peaGDPRDOUBLEOPTINdate
 ON
    cp.center = peaGDPRDOUBLEOPTINdate.PERSONCENTER
    AND cp.id = peaGDPRDOUBLEOPTINdate.PERSONID
    AND peaGDPRDOUBLEOPTINdate.name = 'GDPRDOUBLEOPTINdate'
 LEFT JOIN
    PERSON_EXT_ATTRS peaGDPROPTINDATE
 ON
    cp.center = peaGDPROPTINDATE.PERSONCENTER
    AND cp.id = peaGDPROPTINDATE.PERSONID
    AND peaGDPROPTINDATE.name = 'GDPROPTINDATE'
LEFT JOIN
    PERSON_EXT_ATTRS peaLOYALTYDE
 ON
    cp.center = peaLOYALTYDE.PERSONCENTER
    AND cp.id = peaLOYALTYDE.PERSONID
    AND peaLOYALTYDE.name = 'LOYALTYDE'
LEFT JOIN
    PERSON_EXT_ATTRS peaLOYALTYDEREG
 ON
    cp.center = peaLOYALTYDEREG.PERSONCENTER
    AND cp.id = peaLOYALTYDEREG.PERSONID
    AND peaLOYALTYDEREG.name = 'LOYALTYDEREG'
LEFT JOIN
    PERSON_EXT_ATTRS peaLOYALTYDEADDON
 ON
    cp.center = peaLOYALTYDEADDON.PERSONCENTER
    AND cp.id = peaLOYALTYDEADDON.PERSONID
    AND peaLOYALTYDEADDON.name = 'LOYALTYDEADDON'


LEFT JOIN
    PERSON_EXT_ATTRS peaPRICEINCREASE
 ON
    cp.center = peaPRICEINCREASE.PERSONCENTER
    AND cp.id = peaPRICEINCREASE.PERSONID
    AND peaPRICEINCREASE.name = 'PRICEINCREASE'


 WHERE
    p.CENTER in ($$Scope$$)
    AND peaOSD.NAME = 'OriginalStartDate'
    --All active members with membership anniversary
    AND cp.STATUS in (1,3)
   --Filter out members of staff
    AND cp.PERSONTYPE <> 2
    --Filter out members under 12
    AND age(p.birthdate) > interval '12 year'
   

