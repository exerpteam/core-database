SELECT
    p.lastname as company,
    ar.customercenter||'p'||ar.customerid as customerID,
    pa.creditor_id,
    DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') as agreement_state
FROM 
    account_receivables ar
join payment_agreements pa
    on
    ar.center = pa.center
    and ar.id = pa.id
join persons p
    on
    ar.customercenter = p.center
    and ar.customerid = p.id
where
    p.sex = 'C'
    and ar.customercenter between 100 and 200
order by
    ar.customercenter, ar.customerid
