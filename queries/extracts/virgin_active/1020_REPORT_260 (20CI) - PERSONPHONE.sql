SELECT
    p.EXTERNAL_ID "PERSONPHONEID",
    p.EXTERNAL_ID "PERSONID",
    DECODE(atts.NAME,'_eClub_PhoneHome','HOME','_eClub_PhoneSMS','CELLULAR','_eClub_PhoneSMS','WORK','UNDEFINED') "PHONETYPE",
    atts.TXTVALUE "PHONENUMBER",
    longToDateC(MAX(pcl.ENTRY_TIME),p.center) "LASTSEENDATE"
FROM
    PERSON_EXT_ATTRS atts
JOIN PERSONS pOld
ON
    pOld.CENTER = atts.PERSONCENTER
    AND pOld.ID = atts.PERSONID
JOIN PERSONS p
ON
    p.CENTER = pOld.CURRENT_PERSON_CENTER
    AND p.ID = pOld.CURRENT_PERSON_ID
LEFT JOIN PERSON_CHANGE_LOGS pcl
ON
    pcl.PERSON_CENTER = p.CENTER
    AND pcl.PERSON_ID = p.ID
    AND
    (
        (
            pcl.CHANGE_ATTRIBUTE = 'HOME_PHONE'
            AND atts.NAME = '_eClub_PhoneHome'
        )
        OR
        (
            pcl.CHANGE_ATTRIBUTE = 'MOB_PHONE'
            AND atts.NAME = '_eClub_PhoneSMS'
        )
        OR
        (
            pcl.CHANGE_ATTRIBUTE = 'WORK_PHONE'
            AND atts.NAME = '_eClub_PhoneWork'
        )
    )
WHERE
    atts.NAME IN ('_eClub_PhoneHome','_eClub_PhoneSMS','_eClub_PhoneWork')
and p.SEX != 'C'
and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'GB')
GROUP BY
	p.center,
    p.EXTERNAL_ID,
    atts.NAME,
    atts.TXTVALUE