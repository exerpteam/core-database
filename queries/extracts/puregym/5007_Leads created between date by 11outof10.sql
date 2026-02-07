SELECT 
    cen.NAME,
    p.center || 'p' || p.id AS PersonKey,
    p.FULLNAME,
    DECODE(pag.STATE,NULL,'No Agreement',1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') as DDIstatus,
    TO_CHAR(longtodateTZ(pag.CREATION_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI') as DDICreationTime,
    e.IDENTITY as PIN,
	email.TXTVALUE as Email,
    TO_CHAR(longtodateTZ(j.CREATION_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI') as PersonCreationTime
FROM
    PUREGYM.PERSONS p
LEFT JOIN
    PUREGYM.JOURNALENTRIES j
ON
    j.PERSON_CENTER = p.CENTER
    AND j.PERSON_ID = p.ID
    AND j.NAME = 'Person created'
LEFT JOIN
    PUREGYM.ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER = p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1

LEFT JOIN
     PUREGYM.CENTERS cen
     on 
     cen.ID = p.CENTER

        LEFT JOIN PUREGYM.PERSON_EXT_ATTRS email
        ON
            email.personcenter = p.center
            AND email.personid = p.id
            AND email.name = '_eClub_Email' 

left join 
     PUREGYM.ACCOUNT_RECEIVABLES acr
     on acr.CUSTOMERCENTER = p.CENTER
     and acr.CUSTOMERID = p.ID
     and acr.AR_TYPE = 4

left join
     PUREGYM.PAYMENT_ACCOUNTS pac
     on pac.CENTER = acr.CENTER
     and pac.ID = acr.ID

left join
     PUREGYM.PAYMENT_AGREEMENTS pag
     on pag.CENTER = pac.ACTIVE_AGR_CENTER
     and pag.ID = pac.ACTIVE_AGR_ID
     and pag.SUBID = pac.ACTIVE_AGR_SUBID    

WHERE
    j.CREATION_TIME between :fromDate and :toDate
    AND p.STATUS = 0
    AND j.CREATORCENTER = 100
    AND j.CREATORID = 202