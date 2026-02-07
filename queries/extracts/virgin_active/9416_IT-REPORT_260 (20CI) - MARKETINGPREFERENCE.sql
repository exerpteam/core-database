SELECT
    p.EXTERNAL_ID "MARKETINGPREFERENCEID",
    p.EXTERNAL_ID "PERSONID",
    DECODE(atts.NAME,'_eClub_AllowedChannelEmail','ALLOW_EMAIL','_eClub_AllowedChannelLetter','ALLOW_LETTER','_eClub_AllowedChannelPhone','ALLOW_HOME_PHONE','_eClub_AllowedChannelSMS','ALLOW_CELLULAR_PHONE') "MARKETINGPREFERENCE",
    DECODE(upper(atts.TXTVALUE),'TRUE',1,'FALSE',0) "OPTIN" ,
    longToDateC(MAX(pcl.ENTRY_TIME),p.center) "PREFERENCEDATE"
FROM
    PERSON_EXT_ATTRS atts
JOIN PERSONS oldP
ON
    oldP.CENTER = atts.PERSONCENTER
    AND oldP.ID = atts.PERSONID
JOIN PERSONS p
ON
    p.CENTER = oldP.CURRENT_PERSON_CENTER
    AND p.ID = oldP.CURRENT_PERSON_ID
LEFT JOIN PERSON_CHANGE_LOGS pcl
ON
    pcl.PERSON_CENTER = p.CENTER
    AND pcl.PERSON_ID = p.ID
    AND pcl.CHANGE_ATTRIBUTE = atts.NAME
WHERE
    atts.NAME IN ('_eClub_AllowedChannelEmail','_eClub_AllowedChannelLetter','_eClub_AllowedChannelPhone','_eClub_AllowedChannelSMS')
and p.SEX != 'C'
and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
GROUP BY
	p.center,
    p.EXTERNAL_ID ,
    p.EXTERNAL_ID ,
    atts.NAME,
    DECODE(upper(atts.TXTVALUE),'TRUE',1,'FALSE',0)