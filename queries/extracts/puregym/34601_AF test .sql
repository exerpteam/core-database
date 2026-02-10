-- The extract is extracted from Exerp on 2026-02-08
-- testing
SELECT
    COUNT(m.Center),
    TO_CHAR(TRUNC(longtodate(m.SENTTIME),'MONTH'),'MMMM yyyy') AS MONTH,
    subject
FROM
    MESSAGES m
JOIN
    SMS
ON
    sms.MESSAGE_CENTER = m.center
AND sms.MESSAGE_ID = m.ID
AND sms.MESSAGE_SUB_ID = m.SUBID
JOIN
    SMS_SPLITS ssp
ON
    ssp.SMS_CENTER = sms.center
AND ssp.SMS_ID = sms.ID
WHERE
    m.SENTTIME > datetolong('2017-01-01 00:00')
AND m.SENTTIME < datetolong('2017-03-31 23:59')
AND m.DELIVERYMETHOD = 2 -- SMS
AND ssp.ok = 1 -- actually delivered
GROUP BY
    m.subject,
    TO_CHAR(TRUNC(longtodate(m.SENTTIME),'MONTH'),'MMMM yyyy')
ORDER BY
    COUNT(sms.ID) DESC
