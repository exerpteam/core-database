-- The extract is extracted from Exerp on 2026-02-08
--  
WITH PARAMS AS
(
        SELECT
                /*+ materialize */
                   c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
        WHERE
                c.COUNTRY = 'DE'
)
SELECT distinct (s.owner_center||'p'||s.owner_id) "Member" 
FROM 
SUBSCRIPTIONS s
join PARAMS par
 ON par.CenterId = s.owner_CENTER
JOIN
  ACCOUNT_RECEIVABLES ar
ON 
  ar.CUSTOMERCENTER = s.OWNER_CENTER and ar.CUSTOMERID = s.OWNER_ID
 join payment_requests pr
on ar.center = pr.center 
AND ar.ID = pr.ID
JOIN
  PAYMENT_ACCOUNTS pac
ON 
  pac.center = ar.center AND pac.ID = ar.ID AND ar.AR_TYPE = 4
JOIN
  PAYMENT_AGREEMENTS pag
ON 
  pac.ACTIVE_AGR_CENTER = pag.center AND pac.ACTIVE_AGR_ID = pag.ID 
WHERE 
  pag.PAYMENT_CYCLE_CONFIG_ID in (2605,2604,2606,2404)
  --and s.owner_Center=13 and s.owner_id=21356 
  and s.billed_until_date= to_date('30-04-2020','dd-mm-yyyy')
  and pag.state=4
  and pr.state <> 1