-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT             
					c.SHORTNAME,
				
                    sum(PR.REQ_AMOUNT) as REQUESTS_AMOUNT
					
                  
					
			 FROM
                    PAYMENT_REQUESTS pr
INNER JOIN
    ACCOUNT_RECEIVABLES ar
ON pr.CENTER = ar.CENTER
    AND pr.ID = ar.ID

INNER JOIN PERSONS p
ON p.CENTER = ar.CUSTOMERCENTER AND p.ID = ar.CUSTOMERID
INNER JOIN CENTERS c
ON c.ID = pr.CENTER

					
					WHERE extract(month from pr.REQ_DATE) = $$month$$
					 AND pr.CLEARINGHOUSE_ID IN (803)
             
			   AND pr.CENTER IN(select c.ID from CENTERS c where  c.COUNTRY = 'IT' )
			  AND pr.REQUEST_TYPE = 1 
 AND pr.REQ_DELIVERY IS NOT NULL
GROUP BY c.SHORTNAME
ORDER BY c.SHORTNAME