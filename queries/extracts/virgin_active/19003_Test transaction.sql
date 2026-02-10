-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT   
OldPid.txtvalue as OldPersonID,
longtodate(art.TRANS_TIME)as Trans_Date,
art.TEXT,
art.AMOUNT,
art.INFO,
art.DUE_DATE
FROM
    PERSONS p
left join PERSON_EXT_ATTRS OldPID 
on 
   P.ID = OldPID.Personid
   and OldPID.name = '_eClub_OldSystemPersonId'
and  P.center = OldPID.personcenter
left JOIN ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
    and ar.AR_TYPE in (1,4)
right JOIN AR_TRANS art
ON
    art.CENTER = ar.CENTER
    AND art.ID = ar.ID
 and COLLECTED = 1
and REF_TYPE  = 'ACCOUNT_TRANS'

where p.CENTER = 105