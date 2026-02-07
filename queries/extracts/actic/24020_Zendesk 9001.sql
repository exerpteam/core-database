WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS fromDate,
                datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) + 86399000 AS toDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
    ce.ID   AS CenterID,
    ce.NAME AS CenterName,
    DECODE(CRTTYPE,6,'DEBIT CARD',7,'CREDIT CARD',8,'DEBIT OR CREDIT CARD',18,'PAYOUT CREDIT CARD')
                                                              TransactionType,
    TO_CHAR(longtodate(ct.TRANSTIME),'yyyy-MM-dd hh24:mm:ss') AS TransactionTime,
    ct.TRANSTIME                                              AS TransactionTimeInMilisec,
    ct.AMOUNT,
    c.NAME AS CashregisterName
FROM
    CASHREGISTERTRANSACTIONS ct
JOIN PARAMS params ON params.CenterID = ct.CENTER
LEFT JOIN
    CASHREGISTERS c
ON
    ct.CENTER = c.CENTER
AND ct.ID = c.ID
LEFT JOIN
    CENTERS ce
ON
    ce.ID = ct.CENTER
WHERE
    ct.CRTTYPE IN (6,
                   7,
                   8,
                   18)
AND ct.TRANSTIME BETWEEN params.fromDate AND params.toDate
AND ce.COUNTRY = 'SE'
ORDER BY
    ce.ID,
    ct.TRANSTIME