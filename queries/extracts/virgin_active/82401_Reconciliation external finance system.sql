-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    CENTER,
    EXTERNAL_ID,
    REPLACE('' || round(SUM(deb),2), '.', ',') debit,
    REPLACE('' || round(SUM(cred),2), '.', ',') credit,
    REPLACE('' || round(SUM(deb+cred), 2), '.', ',') total
FROM
    (
        SELECT DISTINCT
            acc.CENTER center,
            acc.EXTERNAL_ID,
            sums.debit,
            sums.credit,
            CASE
                WHEN acc.EXTERNAL_ID = sums.debit
                    AND acc.center = sums.center
                THEN sums.amount
                ELSE 0
            END deb,
            CASE
                WHEN acc.EXTERNAL_ID = sums.credit
                    AND acc.center = sums.center
                THEN -sums.amount
                ELSE 0
            END cred
        FROM
            (
                SELECT
                    art.center center,
                    art.DEBIT_ACCOUNT_EXTERNAL_ID debit,
                    art.CREDIT_ACCOUNT_EXTERNAL_ID credit,
                    SUM(art.AMOUNT) amount
                FROM
                    AGGREGATED_TRANSACTIONS art
                WHERE
		    art.center in (:scope)  
	            AND art.BOOK_DATE >= cast(:FromDate as date)
	            AND art.BOOK_DATE < cast(:ToDate as date) + 1
	        GROUP BY
                    art.center,
                    art.DEBIT_ACCOUNT_EXTERNAL_ID,
                    art.CREDIT_ACCOUNT_EXTERNAL_ID
                ORDER BY
                    art.center
            )
            sums
        JOIN
            (
                SELECT DISTINCT
                    CENTER,
                    exteId external_id
                FROM
                    (
                        SELECT
                            CENTER,
                            DEBIT_ACCOUNT_EXTERNAL_ID exteId
                        FROM
                            AGGREGATED_TRANSACTIONS
                        WHERE    
			     center in (:scope)
                        
                        UNION
                        
                        SELECT
                            CENTER,
                            CREDIT_ACCOUNT_EXTERNAL_ID exteId
                        FROM
                            AGGREGATED_TRANSACTIONS
                        WHERE    
			    center in (:scope)
 ) t1          )
            acc
        ON
            acc.center = sums.center
            AND
            (
                sums.debit = acc.EXTERNAL_ID
                OR sums.credit = acc.EXTERNAL_ID
            )
        ORDER BY
            acc.center,
            acc.EXTERNAL_ID
    ) t2
GROUP BY
    CENTER,
    EXTERNAL_ID
HAVING
    SUM(deb) <> 0
    OR SUM(cred) <> 0
ORDER BY
    CENTER,
    EXTERNAL_ID