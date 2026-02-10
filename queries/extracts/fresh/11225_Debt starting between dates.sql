-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     p.FULLNAME,
     p.center||'p'||p.id,
     CASHCOLLECTIONCASES.AMOUNT,
     CASHCOLLECTIONCASES.STARTDATE
 FROM
     CASHCOLLECTIONCASES,
     PERSONS p
 WHERE
     personcenter = P.CENTER
     AND personid = P.ID
     AND closed = 0
     AND MISSINGPAYMENT = 1
     AND CASHCOLLECTIONCASES.STARTDATE BETWEEN $$from_date$$ AND $$to_date$$
