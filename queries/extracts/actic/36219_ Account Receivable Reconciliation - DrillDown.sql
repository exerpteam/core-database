WITH
    params AS
    (
        SELECT
            /*+ materialize */
            r.*
        FROM
            (
                SELECT
                    rp.END_DATE,
                    rp.END_DATE+1 AS CutDate,
                    datetolongTZ(TO_CHAR(rp.end_date + 1, 'YYYY-MM-DD HH24:MI'),
                    'Europe/Rome')     AS CutDateLong,
                    rp.CLOSE_TIME      AS CloseLong,
                    rp.HARD_CLOSE_TIME AS HardCloseLong
                FROM
                    REPORT_PERIODS rp
                WHERE
                    rp.end_date IS NOT NULL
                AND rp.end_date >= $$DATEINPERIOD$$
                AND rp.SCOPE_ID = 2
                ORDER BY
                    rp.END_DATE ASC) r
        LIMIT 1
    )
SELECT
    CENTER,
    AR_TYPE,
    DEBTOR_TYPE,
    SIGN,
    ROUND(SUM(OPEN_AMOUNT),2) AS OPEN_AMOUNT,
    PERSON_ID
FROM
    (
        SELECT
            CENTER,
            AR_TYPE,
            DEBTOR_TYPE,
            ROUND(SUM(OPEN_AMOUNT),2) OPEN_AMOUNT ,
            PERSON_ID,
            CASE
                WHEN ROUND(SUM(OPEN_AMOUNT),2) > 0
                THEN 'POSITIVE'
                ELSE 'DEBT'
            END AS SIGN
        FROM
            (
                SELECT
                    ar.CENTER,
                    CASE  ar.AR_TYPE
                            WHEN 4 THEN 'payment'
                            WHEN 5 THEN 'cashcollection'
                            WHEN 1  THEN 'cash'
                            WHEN 6 THEN 'installmentPlan'
                            ELSE 'other'  END                             AR_TYPE,
                    ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS PERSON_ID,
                    (
                        SELECT
                            CASE
                                WHEN p.sex = 'C'
                                THEN 'COMPANY'
                                ELSE 'PERSON'
                            END
                        FROM
                            persons p
                        WHERE
                            p.center = ar.CUSTOMERCENTER
                        AND p.id = ar.CUSTOMERID) AS DEBTOR_TYPE,
                    art.AMOUNT                    AS OPEN_AMOUNT
                FROM
                    params
                CROSS JOIN
                    ACCOUNT_RECEIVABLES ar
                JOIN
                    AR_TRANS art
                ON
                    ar.CENTER = art.CENTER
                AND ar.ID = art.ID
                WHERE
                    art.CENTER IN
                    (
                        SELECT
                            c.id
                        FROM
                            centers c
                        WHERE
                            c.id = $$center$$  )
                AND
                    -- HERE you can filter on <0 for DEBT only and >0 for POSITIVE amounts only
                    art.AMOUNT <> 0
                AND art.ENTRY_TIME < params.CloseLong
                AND art.TRANS_TIME < params.CutDateLong
               AND (
                        ar.BALANCE <> 0
                    OR  ar.LAST_ENTRY_TIME >= params.CutDateLong - (366 * 24 * 60 * 60 * 1000::int8) )
                ORDER BY
                    art.CENTER,
                    art.ID,
                    art.SUBID) t1
        GROUP BY
            CENTER,
            AR_TYPE ,
            DEBTOR_TYPE ,
            PERSON_ID
        HAVING
            ROUND(SUM(OPEN_AMOUNT),2) <> 0 ) t2
GROUP BY
    CENTER,
    DEBTOR_TYPE,
    AR_TYPE ,
    SIGN,
    PERSON_ID
ORDER BY
    CENTER,
    DEBTOR_TYPE,
    AR_TYPE ,
    SIGN,
    PERSON_ID,
    OPEN_AMOUNT
