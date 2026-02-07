SELECT distinct
    ar.CUSTOMERCENTER||'p'|| ar.CUSTOMERID,
    p.FULLNAME,
    longtodate(art.TRANS_TIME),
    art.AMOUNT,
    art.DUE_DATE,
    art.TEXT
  
    --  inv.*
    -- pr.REQ_AMOUNT,
    -- pr.REQ_DATE,
    --DECODE(pr.REQUEST_TYPE,1,'Payment',6,'Representation',8,'Zero',5,'Refund',TO_CHAR(pr.REQUEST_TYPE))                                                                                                                                                                                      AS REQUEST_TYPE,
    -- DECODE(pr.state,1, 'New',2, 'Sent',3, 'Done',4, 'Done, manuel',5, 'Rejected, clearinghouse',6, 'Rejected, bank',7, 'Rejected, debtor',8, 'Cancelled',10, 'Reversed, new',11, 'Reversed, sent',12, 'Failed, not creditor',13, 'Reversed, rejected',14, 'Reversed, confirmed','UNDEFINED') AS STATE
FROM
    PUREGYM.ACCOUNT_RECEIVABLES ar
JOIN
    PUREGYM.PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.id = ar.ID
JOIN
    PUREGYM.PAYMENT_AGREEMENTS pa
ON
    pa.center = ar.center
    AND pa.id = ar.id
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
JOIN
    PUREGYM.PAYMENT_REQUESTS pr
ON
    pr.center = ar.CENTER
    AND pr.id = ar.id
JOIN
    PUREGYM.PERSONS p
ON
    p.center = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
join PUREGYM.AR_TRANS art on art.center =ar.center and art.id = ar.id
WHERE
    ar.AR_TYPE = 4
    AND art.TRANS_TIME BETWEEN $$from_date$$ AND $$to_date$$
	and (
	(
	pa.BANK_ACCOUNT_DETAILS = 'i0hykTHPIhX6BVXkHOKVy5ZBk9d2ee1mN39EARNE8AyHlyJp4TL7Lj2FgrR4UDRcXCIPFhdqXRTT' 
	|| chr(10) || 'R8SydSwmUYa9J4S13paSoJmFVQj5JlRldwrUHwmwg+zTbx+CjG9z'
	and :AccountNumber = 10958302
	)
	or 
	(
	pa.BANK_ACCOUNT_DETAILS = 'i0hykTHPIhX6BVXkHOKVy8ifvoQhBtAXzDIjGCm6eypRSUdSmyCDc8pPuLYEsdVeclkwQMV+lH42' 
	|| chr(10) || '6hMu1HofGJ7xfHgpp7BhYpa4riC4lRDtDmXQm5l0Kb3mg/5/dLNW'
	and :AccountNumber = 28373340
	)
	or 
	pa.BANK_ACCOUNT_DETAILS = 'i0hykTHPIhX6BVXkHOKVy8ifvoQhBtAXzDIjGCm6eypRSUdSmyCDc8pPuLYEsdVe+LuN4po+A1W/' 
	|| chr(10) || 'Y1GHZaDrGpJIbV99LuPWRT6yMncfphGjbZgt7XjT55oT3nEyKXwk'
	and :AccountNumber = 28373049
)

