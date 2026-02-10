-- The extract is extracted from Exerp on 2026-02-08
-- Shows all exported transactions per account per day of the month
SELECT
    *
FROM
    (
        SELECT
            TO_CHAR(longtodate(TRANS_TIME), 'YYYY-MON') maaned,
            trans.book_day,
            acc.EXTERNAL_ID,
            amt
        FROM
            (
                SELECT
                    center,
                    accountcenter,
                    accountid,
                    round(SUM(amount),2) amt,
                    trans_time,
                    book_date,
                    book_day
                FROM
                    (
                        SELECT
                            act.CENTER,
                            act.DEBIT_ACCOUNTCENTER accountcenter,
                            act.DEBIT_ACCOUNTID accountid,
                            act.AMOUNT amount,
                            act.TRANS_TIME,
                            TO_CHAR(longtodate(act.TRANS_TIME), 'YYYY-MM-DD') book_date,
                            TO_CHAR(longtodate(act.TRANS_TIME), 'DD') book_day
                        FROM
                            ACCOUNT_TRANS act
                        WHERE
                            act.CENTER in (:Center)
                            AND act.TRANS_TIME >= :FromDate
                            AND act.TRANS_TIME < :ToDate + 1000 * 3600 * 24
                            AND act.TRANSFERRED = 1
							AND act.AGGREGATED_TRANSACTION_CENTER is not null
                        UNION ALL
                        SELECT
                            act.CENTER,
                            act.CREDIT_ACCOUNTCENTER accountcenter,
                            act.CREDIT_ACCOUNTID accountid,
                            act.AMOUNT * -1 amount,
                            act.TRANS_TIME,
                            TO_CHAR(longtodate(act.TRANS_TIME), 'YYYY-MM-DD') book_date,
                            TO_CHAR(longtodate(act.TRANS_TIME), 'DD') book_day
                        FROM
                            ACCOUNT_TRANS act
                        WHERE
                            act.CENTER in (:Center)
                            AND act.TRANS_TIME >= :FromDate 
                            AND act.TRANS_TIME < :ToDate + 1000 * 3600 * 24
                            AND act.TRANSFERRED = 1
							AND act.AGGREGATED_TRANSACTION_CENTER is not null
                    )
                GROUP BY
                    center,
                    accountcenter,
                    accountid,
                    trans_time,
                    book_date,
                    book_day
            )
            trans
        JOIN ACCOUNTS acc
        ON
            trans.ACCOUNTCENTER = acc.CENTER
            AND trans.ACCOUNTID = acc.ID
        ORDER BY
            External_ID
    )
    PIVOT ( SUM(amt) FOR book_day IN ('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16',
    '17','18','19','20','21','22','23','24','25','26','27','28','29','30','31') )
