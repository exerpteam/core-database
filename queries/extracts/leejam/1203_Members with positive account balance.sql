SELECT
            p.center || 'p' || p.id AS "PERSONKEY",
             ar.balance
        FROM
		account_receivables ar
        JOIN
           persons p
        ON
            p.center = ar.customercenter
        AND p.id = ar.customerid
        
        WHERE
           ar.balance > 0
AND
         ar.ar_type = 1
        AND p.sex != 'C'
       AND p.center IN (:Scope)