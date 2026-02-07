SELECT
    *
FROM
    (
        SELECT
            trans.center,
            TO_CHAR(longtodate(TRANS_TIME), 'YYYY-MON') maaned,
            trans.book_day,
            acc.EXTERNAL_ID,
            acc.NAME,
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
                            act.CENTER = 9
                            AND act.TRANS_TIME >= datetolong('2010-10-01 00:00')
                            AND act.TRANS_TIME <= datetolong('2010-10-31 23:59')
                            AND act.TRANSFERRED = 1
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
                            act.CENTER = 9
                            AND act.TRANS_TIME >= datetolong('2010-10-01 00:00')
                            AND act.TRANS_TIME <= datetolong('2010-10-31 23:59')
                            AND act.TRANSFERRED = 1
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
            acc.center, acc.name,
            acc.External_ID
    )
    PIVOT ( SUM(amt) FOR book_day IN ('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16',
    '17','18','19','20','21','22','23','24','25','26','27','28','29','30','31') )
