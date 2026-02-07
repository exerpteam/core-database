SELECT
     
     c.ID AS CENTER_ID,
     p.EXTERNAL_ID,
     cp.CENTER||'p'||cp.ID AS PERSON_KEY,
     cp.FIRSTNAME,
     cp.LASTNAME,
     peaEmail.TXTVALUE  AS "EMAIL",
     peaPhone.TXTVALUE  AS "PHONE",
     cp.ZIPCODE,
     cp.CITY,
     CASE WHEN cp.SEX = 'M' THEN 'MALE'
          WHEN cp.SEX = 'F' THEN 'FEMALE'
          ELSE cp.SEX
     END    AS "SEX",
     peaChannelEmail.TXTVALUE    AS "ALLOW_CHANNEL_EMAIL",
     peaLOYALTYDE.TXTVALUE AS "LOYALTY",
	mp.cached_productname AS "ADDOON",
	SUM(mp.CACHED_PRODUCTPRICE) AS "addonTotal",
	addon.end_date AS "AddonEnd",
 --ADDON PRODUCT NAME? ADDON PRODUCT END DATE?
    peaPRICEINCREASE.TXTVALUE AS "Price_Increase",
     peaOSD.TXTVALUE AS  "ORIGINAL_START_DATE",
     extract('year' from age(to_date(peaOSD.TXTVALUE,'YYYY-MM-DD'))) "MEMBER_YEARS"

FROM
    SUBSCRIPTIONS s
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

LEFT JOIN
    SUBSCRIPTION_ADDON addon
ON
    S.CENTER = addon.SUBSCRIPTION_CENTER
    AND S.ID = addon.SUBSCRIPTION_ID
    AND addon.CANCELLED = 0
LEFT JOIN
    MASTERPRODUCTREGISTER mp
ON
    addon.ADDON_PRODUCT_ID = mp.ID
	AND mp.masterproductgroup IN (24015)
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.id = s.OWNER_ID

JOIN
     CENTERS c
 ON 
	c.ID = p.CENTER

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
    PERSON_EXT_ATTRS peaPRICEINCREASE
 ON
    cp.center = peaPRICEINCREASE.PERSONCENTER
    AND cp.id = peaPRICEINCREASE.PERSONID
    AND peaPRICEINCREASE.name = 'PRICEINCREASE'

 WHERE
    c.ID in ($$Scope$$)
    AND peaOSD.NAME = 'OriginalStartDate'
    --All active members with membership anniversary
    AND cp.STATUS in (1,3)
   --Filter out members of staff
    AND cp.PERSONTYPE <> 2
    --Filter out members under 12
    AND age(p.birthdate) > interval '12 year'
   

