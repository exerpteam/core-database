-- The extract is extracted from Exerp on 2026-02-08
--  
select
   E.IDENTITY as CARDNO,
   1 as CARDSTATUS,
   P.FIRSTNAME as NAME,
   P.LASTNAME,
   P.SSN as VATNO
from ENTITYIDENTIFIERS E
join PERSONS P on  (E.REF_CENTER = P.CENTER and E.REF_ID = P.ID and E.REF_TYPE
= 1 and E.IDMETHOD = 1 and E.ENTITYSTATUS = 1)
left join SUBSCRIPTIONS S on (E.REF_CENTER = S.OWNER_CENTER and E.REF_ID =
S.OWNER_ID and S.STATE in (2,8) and S.SUB_STATE != 9)
where (S.CENTER is not null and s.CENTER < 200) or (E.REF_CENTER < 200 and
(longToDate(E.START_TIME) >= (exerpsysdate() - 30)))