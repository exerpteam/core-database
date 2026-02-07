-- This is the version from 2026-02-05
--  
select
    p.center, 
    p.id,
    p.fullname,
    pr.bank_regno,
    pr.BANK_ACCNO
from 
     fw.PAYMENT_AGREEMENTS pr
join fw.ACCOUNT_RECEIVABLES ar 
     on ar.center=pr.center 
     and ar.id=pr.id
join fw.PERSONS p 
     on ar.customercenter=p.center 
     and ar.customerid=p.id
where 
     p.center in (:scope)
group by
    p.center, 
    p.id,
    p.fullname,
    pr.bank_regno,
    pr.BANK_ACCNO