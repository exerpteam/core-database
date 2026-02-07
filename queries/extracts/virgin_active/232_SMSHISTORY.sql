SELECT
    /* No login name type for message, subid is unique for the member */
    mess.CENTER || 'mess' || mess.ID || 'age' || mess.SUBID "SMSHistoryID",
    p.EXTERNAL_ID "PersonID",
    atts.TXTVALUE "Mobile",
    longToDate(mess.SENTTIME) "SendTime",
    DECODE (mess.DELIVERYCODE, 0, 'UNDELIVERED', 1, 'STAFF', 2, 'EMAIL', 3, 'EXPIRED',4, 'KIOSK',5, 'WEB',6, 'OK',7, 'CANCELED',8, 'LETTER',9, 'FAILED',10, 'UNCHARGABLE','UNDEFINED') "DeliveryStatus",
    'N/A' "CustomerReference",
    mess.SUBJECT "Header",
    'Needs to be unzipped' "Body",
    p.EXTERNAL_ID "MemberID",
    'EXERP' "SourceSystem",
    '?' "ExtRef"
FROM
    FW.MESSAGES mess
JOIN FW.PERSONS oldP
ON
    oldP.CENTER = mess.CENTER
    AND oldP.ID = mess.ID
JOIN FW.PERSONS p
ON
    p.CENTER = oldP.CURRENT_PERSON_CENTER
    AND p.ID = oldP.CURRENT_PERSON_ID
LEFT JOIN FW.PERSON_EXT_ATTRS atts
ON
    atts.PERSONCENTER = p.CENTER
    AND atts.PERSONID = p.ID
    AND atts.NAME = '_eClub_PhoneSMS'
WHERE
    mess.DELIVERYMETHOD = 2
