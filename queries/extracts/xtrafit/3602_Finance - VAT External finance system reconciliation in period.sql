SELECT
    t2.CENTER,
    t2.EXTERNAL_ID,
    REPLACE('' || SUM(t2.deb), '.', ',') AS debit,
    REPLACE('' || SUM(t2.cred), '.', ',') AS credit,
    REPLACE('' || round(SUM(t2.deb+t2.cred), 2), '.', ',') AS total
FROM
    (
        SELECT DISTINCT
            acc.CENTER center,
            acc.EXTERNAL_ID,
            sums.debit,
            sums.credit,
            (CASE
                WHEN acc.EXTERNAL_ID = sums.debit AND acc.center = sums.center
                THEN sums.amount
                ELSE 0
            END) AS deb,
            (CASE
                WHEN acc.EXTERNAL_ID = sums.credit AND acc.center = sums.center
                THEN -sums.amount
                ELSE 0
            END) AS cred
        FROM
            (
                SELECT
                    art.center AS center,
                    art.DEBIT_VAT_ACCOUNT_EXTERNAL_ID AS debit,
                    art.CREDIT_VAT_ACCOUNT_EXTERNAL_ID AS credit,
                    SUM(art.VAT_AMOUNT) AS amount
                FROM
                    AGGREGATED_TRANSACTIONS art
                WHERE
		    	art.center in (:scope)  
	            AND art.BOOK_DATE >= :FromDate
	            AND art.BOOK_DATE < CAST(:ToDate AS Timestamp) + interval '1 day'
	       	 GROUP BY
                    art.center,
                    art.DEBIT_VAT_ACCOUNT_EXTERNAL_ID,
                    art.CREDIT_VAT_ACCOUNT_EXTERNAL_ID
                ORDER BY
                    art.center
            )
            sums
        JOIN
            (
                SELECT DISTINCT
                    t1.CENTER,
                    t1.exteId AS external_id
                FROM
                    (
                        SELECT
                            CENTER,
                            DEBIT_VAT_ACCOUNT_EXTERNAL_ID AS exteId
                        FROM
                            AGGREGATED_TRANSACTIONS
                        WHERE    
			     center in (:scope)
                        
                        UNION
                        
                        SELECT
                            CENTER,
                            CREDIT_VAT_ACCOUNT_EXTERNAL_ID exteId
                        FROM
                            AGGREGATED_TRANSACTIONS
                        WHERE    
			    center in (:scope)
             )  t1         
)
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
    t2.CENTER,
    t2.EXTERNAL_ID
HAVING
    SUM(t2.deb) <> 0
    OR SUM(t2.cred) <> 0
ORDER BY
    t2.CENTER,
    t2.EXTERNAL_ID