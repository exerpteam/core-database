select
    p.center||'p'||p.id as customerID,
    decode (p.sex, 'M','Person','F','Person','C','Company') as customer_type,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') AS STATUS,
    p.address1
from
    eclub2.persons p
where
    p.address1 like 'C/O%'
    or p.address1 like 'c/o%'
    or p.address1 like 'C/o%' 
order by
    p.sex,
    p.status
