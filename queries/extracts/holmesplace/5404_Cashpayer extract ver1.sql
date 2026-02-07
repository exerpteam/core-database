
SELECT
    ar.CUSTOMERCENTER || 'p' ||  ar.CUSTOMERID as personId,
    CASE p.persontype
        WHEN 0 THEN 'privat'
        WHEN 1 THEN 'Student'
        WHEN 2 THEN 'staff'
        WHEN 3 THEN 'Friend'
        WHEN 4 THEN 'Corporate'
        WHEN 5 THEN 'One-Man Corp'
        WHEN 6 THEN 'Family'
        WHEN 7 THEN 'Senior'
        WHEN 8 THEN 'Guest'
        WHEN 9 THEN 'Child'
        WHEN 10 THEN 'External Staff'
    END AS CUSTOMERTYPE,
   p.firstname as firstnae,
p.lastname as lastamne_Company,
 /*   cr.CREDITOR_NAME, */
ch.name,

    replace('' || pr.REQ_AMOUNT, '.', ',') amount,
   pr.REQ_DELIVERY sendt_fil,
    pr.XFR_DELIVERY modt_fil, 
    CASE pr.STATE
      WHEN '1' THEN 'New'
      WHEN '2' THEN 'Sent'
      WHEN '3' THEN 'Done'
      WHEN '4' THEN 'Done maual'
      WHEN '5' THEN 'Rejected, clearinghouse'
      WHEN '6' THEN 'Rejected, bank'
      WHEN '7' THEN 'Rejected, debtor'
      WHEN '8' THEN 'Cancelled'
    END AS state
FROM
    PAYMENT_REQUESTS pr
JOIN ACCOUNT_RECEIVABLES ar
ON
    ar.center = pr.center
    AND ar.id = pr.id
JOIN CLEARINGHOUSES ch
ON
    ch.id = pr.CLEARINGHOUSE_ID
JOIN CLEARINGHOUSE_CREDITORS cr
ON
    cr.CLEARINGHOUSE = ch.id
join persons p on 
    ar.customercenter = p.center
    AND ar.customerid = p.id

WHERE
    pr.REQ_DATE = :ReqDate
	and pr.center in( :scope)
/* and pr.state not in (8) */

ORDER BY
    cr.CREDITOR_NAME,
    pr.state