-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     ar.CUSTOMERCENTER,
     ar.CUSTOMERID person,
     pr.REJECTED_REASON_CODE reasoncode,
     pr.REQ_AMOUNT
 ,pa.*
 FROM
     PAYMENT_REQUESTS pr
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CENTER = pr.CENTER
     AND ar.ID = pr.ID
 JOIN
     PERSONS p
 ON
     ar.CUSTOMERCENTER = p.CENTER
     AND ar.CUSTOMERID = p.ID
 join PAYMENT_ACCOUNTS pac on pac.CENTER = ar.CENTER and pac.ID = ar.ID
 join PAYMENT_AGREEMENTS pa on pa.CENTER = pac.ACTIVE_AGR_CENTER and
 pa.ID = pac.ACTIVE_AGR_ID and
 pa.SUBID = pac.ACTIVE_AGR_SUBID
 join CLEARINGHOUSES ch on ch.ID = pa.CLEARINGHOUSE and ch.NAME IN ('Carta Si Milano Durini')
 WHERE
         floor(months_between(CURRENT_TIMESTAMP, p.BIRTHDATE) / 12) > 17
