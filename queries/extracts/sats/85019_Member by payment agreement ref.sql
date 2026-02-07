SELECT 
    p.external_id, 
    ar.CUSTOMERCENTER||'p'|| ar.CUSTOMERID, 
   -- pa.STATE, 
    pr.REQ_AMOUNT, 
    pr.REQ_DATE, 
    pr.CREDITOR_ID, 
    pr.ref, 
   -- pr.state, 
    prs.original_due_date 
FROM 
    PAYMENT_REQUESTS pr 
JOIN 
    ACCOUNT_RECEIVABLES ar 
    ON 
    pr.center = ar.center 
    and pr.id = ar.id 
JOIN 
    PAYMENT_ACCOUNTS pm 
    ON 
    pm.center = ar.center 
    and pm.id = ar.id 
JOIN 
    PAYMENT_AGREEMENTS pa 
    ON 
    pm.ACTIVE_AGR_CENTER    = pa.center 
    and pm.ACTIVE_AGR_ID    = pa.id 
    and pm.ACTIVE_AGR_SUBID = pa.subid 
JOIN 
    CENTERS center
    ON 
    ar.CENTER = center.ID
join persons p
on
ar.CUSTOMERCENTER = p.center
and ar.CUSTOMERID = p.id
join 
PAYMENT_REQUEST_SPECIFICATIONS prs
on
pr.INV_COLL_CENTER = prs.CENTER
AND pr.INV_COLL_ID = prs.ID
AND pr.INV_COLL_SUBID = prs.SUBID
    
WHERE 
 --    pr.state = 1 
 --   and pa.STATE = 2
 pa.ref in (:paymentagreementref)
--'26210400068614'
and pr.ref =  (:paymentrequestref)
--'000005'