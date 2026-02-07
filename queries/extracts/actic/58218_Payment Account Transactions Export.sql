WITH
    plist AS materialized
    (
        SELECT
            center,
            id
        FROM
            persons p
        WHERE
            p.status IN (0,
                         1,
                         2,
                         3,
                         6,
                         9)
        AND p.sex != 'C'
        AND p.center IN (731,759,744,7035,736,734,726,748,778,729,7078,756,760,773,779,735,732,766,
                         700,730,
                         733,728,762,783,782,737,743,7084,725)
    )
SELECT
    p.CENTER || 'p' || p.ID AS PersonId,
    art.text                AS Text,
    art.UNSETTLED_AMOUNT    AS Amount,
    payment_account.BALANCE,
    TO_CHAR(longtodate(art.TRANS_TIME), 'YYYY-MM-DD') AS TransactionDate,
    art.DUE_DATE                                      AS DueDate
FROM
    plist p
JOIN
    ACCOUNT_RECEIVABLES payment_account
ON
    payment_account.CUSTOMERCENTER=p.CENTER
AND payment_account.CUSTOMERID=p.ID
AND payment_account.AR_TYPE=4
JOIN
    AR_TRANS art
ON
    payment_account.CENTER = art.CENTER
AND payment_account.ID = art.ID
AND art.UNSETTLED_AMOUNT != 0
WHERE
    payment_account.BALANCE != 0