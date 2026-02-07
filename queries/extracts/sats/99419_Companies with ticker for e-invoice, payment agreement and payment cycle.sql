SELECT 
   -- p.external_id, 
    ar.CUSTOMERCENTER||'p'|| ar.CUSTOMERID, 
    p.fullname,
  -- pa.active as "payment agreement active", 
   cl.name as "Clearing house", 
   pcc.name as "payment cycle",
   p.prefer_invoice_by_email
FROM ACCOUNT_RECEIVABLES ar 
   
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
join payment_cycle_config pcc
on
pa.payment_cycle_config_id = pcc.id
join clearinghouses cl
on
cl.id = pa.clearinghouse
    
WHERE 
 
 p.sex = 'C'
 and p.status not in (7,8) 
 and pa.active = 'true'
 and p.center in (:scope)
 and p.prefer_invoice_by_email = 'true'