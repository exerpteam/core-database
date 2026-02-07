select distinct 
    E.IDENTITY as CARDNO,
    case
        when (CC.CENTER IS NOT NULL and CC.STARTDATE < (sysdate - 40)) then 33
        when (CC.CENTER IS NOT NULL and CC.STARTDATE >= (sysdate - 40)) then 67
        when (S.SUB_STATE = 9) then 65
        when (E.ENTITYSTATUS != 1) then 3
        else 1
    end as CARDSTATUS,
    case
        when (P.SSN is not null) then trim(replace(to_char((P.SSN) / 10000, '00000000.0000'), '.', '-'))
        when pea.TXTVALUE is not null then trim(pea.txtvalue)
        else null
    end as VATNO
from ENTITYIDENTIFIERS E
join PERSONS P on (E.REF_CENTER = P.CENTER and E.REF_ID = P.ID and E.REF_TYPE =
1 and E.IDMETHOD = 1)
left join CASHCOLLECTIONCASES CC on (CC.PERSONCENTER = P.CENTER and CC.PERSONID
= P.ID and CC.MISSINGPAYMENT = 1 and CC.CLOSED = 0)
left join SUBSCRIPTIONS S on (E.REF_CENTER = S.OWNER_CENTER and E.REF_ID =
S.OWNER_ID)
left join PERSON_EXT_ATTRS pea on pea.PERSONCENTER = p.center and pea.PERSONID = p.id and pea.name = '_eClub_OldSystemPersonId'
where E.IDENTITY not in
(
    select 
        E.IDENTITY as CARDNO
    from ENTITYIDENTIFIERS E
    join PERSONS P on  (E.REF_CENTER = P.CENTER and E.REF_ID = P.ID and
E.REF_TYPE = 1 and E.IDMETHOD = 1 and E.ENTITYSTATUS = 1)
    left join SUBSCRIPTIONS S on (E.REF_CENTER = S.OWNER_CENTER and E.REF_ID =
S.OWNER_ID and S.STATE in (2,8) and S.SUB_STATE != 9)
    where (S.CENTER is not null and S.CENTER < 200) or (E.REF_CENTER < 200 and
    (longToDate(E.START_TIME) >= (sysdate - 30)))
)
and P.CENTER < 500 and P.SEX != 'C' and E.ENTITYSTATUS != 6