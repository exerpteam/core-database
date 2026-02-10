-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT 
    art.entry_time as ordered,
    ar.customercenter ||'p'|| ar.customerid as memberid,
    art.amount,
    art.text, 
    to_char(longtodate(art.entry_time), 'dd-mon-yyyy') AS entrydate,
    to_char(longtodate(art.trans_time), 'dd-mon-yyyy') AS bookdate

  FROM
    account_receivables ar

  JOIN ar_trans art ON
    art.center = ar.center
    AND art.id = ar.id
   JOIN cashcollectioncases ccc ON 
    ar.customercenter = ccc.personcenter
    and ar.customerid = ccc.personid
   
  WHERE
	ar.customercenter = :scope --in the client

    AND ar.ar_type = 5
    AND art.amount > 0
   
        
   ORDER BY 
    memberid ASC,
    ordered ASC
;