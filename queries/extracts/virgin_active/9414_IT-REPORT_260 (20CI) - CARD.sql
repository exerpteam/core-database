SELECT DISTINCT
    ei.ID                                                                                    "CARDID",
    p.EXTERNAL_ID                                                                            "PERSONID",
    ' ' || to_char(ei.IDENTITY) || ' ' "CARDNO",
    to_char(longToDateC(ei.START_TIME,p.center),'YYYY-MM-dd HH24:MI')                                                      "ISSUEDATE",
decode(ei.IDMETHOD,1,'Magnetic',2,'MagneticCard',4,'RFCard',5,'Pin') CARD_TYPE
FROM
    ENTITYIDENTIFIERS ei
JOIN
    PERSONS oldP
ON
    oldP.CENTER = ei.REF_CENTER
    AND oldP.ID = ei.REF_ID
JOIN
    PERSONS p
ON
    p.CENTER = oldP.CURRENT_PERSON_CENTER
    AND p.ID = oldP.CURRENT_PERSON_ID
WHERE
    ei.ENTITYSTATUS = 1
    AND ei.REF_TYPE = 1
	and p.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')