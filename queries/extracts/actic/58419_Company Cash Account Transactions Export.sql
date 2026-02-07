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
    ,
    comps AS
    (
        SELECT DISTINCT
            comp.*
        FROM
            plist p
        JOIN
            RELATIVES rel_comp
        ON
            p.CENTER = rel_comp.RELATIVECENTER
        AND p.ID = rel_comp.RELATIVEID
        AND rel_comp.RTYPE = 2
        AND rel_comp.STATUS=1
        JOIN
            persons comp
        ON
            comp.center = rel_comp.center
        AND comp.id = rel_comp.id
    )
SELECT
    c.CENTER || 'p' || c.ID AS PersonId,
    art.text                AS Text,
    art.UNSETTLED_AMOUNT    AS Amount,
    payment_account.BALANCE,
    TO_CHAR(longtodate(art.TRANS_TIME), 'YYYY-MM-DD') AS TransactionDate,
    art.DUE_DATE                                      AS DueDate
FROM
    comps c
JOIN
    ACCOUNT_RECEIVABLES payment_account
ON
    payment_account.CUSTOMERCENTER=c.CENTER
AND payment_account.CUSTOMERID=c.ID
AND payment_account.AR_TYPE=1
JOIN
    AR_TRANS art
ON
    payment_account.CENTER = art.CENTER
AND payment_account.ID = art.ID
AND art.UNSETTLED_AMOUNT != 0
WHERE
    payment_account.BALANCE != 0