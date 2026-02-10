-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
COUNT(m.Center),
COUNT(DISTINCT sms.CENTER + sms.ID*1000),
COUNT(ssp.REF_NO),
subject
FROM PUREGYM.MESSAGES m
JOIN PUREGYM.SMS 
ON sms.MESSAGE_CENTER = m.center AND sms.MESSAGE_ID = m.ID AND sms.MESSAGE_SUB_ID = m.SUBID
JOIN PUREGYM.SMS_SPLITS ssp ON ssp.SMS_CENTER = sms.center AND ssp.SMS_ID = sms.ID
WHERE
m.SENTTIME BETWEEN :Fromdate AND :Todate
AND m.DELIVERYMETHOD = 2
and ssp.ok = 1
GROUP BY m.subject
ORDER BY COUNT(sms.ID) DESC