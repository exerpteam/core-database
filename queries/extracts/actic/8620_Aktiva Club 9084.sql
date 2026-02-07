/**
* Creator: Ronald Hofner
* Purpose: Check for active members in club 9084 (Luleå Gammelstaden).
*
*/
select
   E.IDENTITY as cardno,
   MAX(P.CENTER) as sit_nr,
   MAX(case when st.ST_TYPE is not null and st.ST_TYPE = 0 then 'Kontant' else 'Autogiro' end) as payment_type,
   MAX(P.FIRSTNAME) as NAME,
   MAX(P.LASTNAME) as lastname,
   MAX(P.ADDRESS1) as address,
   MAX(P.ZIPCODE) as zip,
   MAX(P.CITY) as city,
   MAX(case
       when (P.SSN is not null) then trim(replace(to_char((P.SSN) / 10000, '00000000.0000'), '.', '-'))
       when pea.TXTVALUE is not null then trim(pea.txtvalue)
       else null
   end) as VATNO,
   max(to_char(s.end_date, 'YYYY-MM-DD HH24:MI:SS')) as enddate
from ENTITYIDENTIFIERS E
join PERSONS P on  (E.REF_CENTER = P.CENTER and E.REF_ID = P.ID and E.REF_TYPE
= 1 and E.IDMETHOD = 1 and E.ENTITYSTATUS = 1)
left join PERSON_EXT_ATTRS pea on pea.PERSONCENTER = p.center and pea.PERSONID = p.id and pea.name = '_eClub_OldSystemPersonId'
left join SUBSCRIPTIONS S on (E.REF_CENTER = S.OWNER_CENTER and E.REF_ID =
S.OWNER_ID and S.STATE in (2) and S.SUB_STATE != 9)
left join SUBSCRIPTIONTYPES st on st.center = S.SUBSCRIPTIONTYPE_CENTER and st.id = S.SUBSCRIPTIONTYPE_ID
where (S.CENTER is not null and  s.CENTER = 84) or  (E.REF_CENTER = 84 and
(longToDate(E.START_TIME) >= (exerpsysdate() - 20)))
group by E.IDENTITY