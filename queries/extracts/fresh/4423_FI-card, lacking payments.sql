SELECT
    ar.balance,
    p.center||'p'||p.id        AS customerID
FROM
    PAYMENT_REQUESTS pr
JOIN ACCOUNT_RECEIVABLES ar
ON
    ar.center= pr.center
    AND ar.id= pr.id
JOIN PERSONS p
ON
    ar.customercenter= p.center
    AND ar.customerid= p.id
WHERE
    pr.XFR_INFO LIKE 'PBS FI-kort'
    AND pr.req_date > to_date(TO_CHAR(exerpsysdate(), 'yyyy-mm-dd'),'yyyy-mm-dd')-:days_back_in_time
    AND ar.balance < -:debt_max
    and pr.req_amount > XFR_AMOUNT    --xfr_amount only set once transfered
	and p.center in (:scope)