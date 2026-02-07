select
rel.CENTER,
rel.ID,
rel.SUBID,
rel.RELATIVECENTER,
rel.RELATIVEID,
DECODE ( RTYPE, 1,'FRIEND', 2,'EMPLOYEE', 3,'COMPANYAGREEMENT', 4,'FAMILY', 5,'BUDDY', 6,'SUBCOMPANY', 7,'CONTACTPERSON', 8,'CREAT_BY', 9,'COUNSELLOR', 10,'ACCOUNTMANAGER', 11,'DUPLICATE', 12,'EFT_PAYER', 13,'REFERED_BY','UNKNOWN') AS RTYPE ,
decode(status, 0, 'INACTIVE', 1, 'ACTIVE', 2, 'INACTIVE') as STATUS,
to_char(rel.EXPIREDATE, 'YYYY-MM-DD') as EXPIREDATE
from eclub2.relatives rel
where 
exists (
select 
    1
from 
    ECLUB2.STATE_CHANGE_LOG scl
join 
    eclub2.persons pers on pers.center=scl.center and pers.id = scl.id 
where 
    scl.ENTRY_TYPE = 1 
    and scl.STATEID = 1
    and (scl.BOOK_END_TIME >= eclub2.datetolong(to_char(exerpsysdate()-3*365, 'YYYY-MM-DD HH24:MI')) or scl.BOOK_END_TIME is null)
    and pers.status not in (5,6) 
    and pers.sex != 'C'
    and pers.center = rel.CENTER and pers.id = rel.ID
) and
rel.rtype in (1,4,12)
and rel.status < 3
and
rel.center >= :FromCenter
    and rel.center <= :ToCenter
