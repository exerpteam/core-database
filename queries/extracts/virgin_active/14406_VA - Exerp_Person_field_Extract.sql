-- The extract is extracted from Exerp on 2026-02-08
--  
select 
OldPID.txtvalue as OldPersonID,
P.Center,
P.FIRSTNAME,
P.LASTNAME,
Salut.txtvalue as Salutation,
P.BIRTHDATE,
P.SEX,
P.ADDRESS1,
P.ADDRESS2,
P.ADDRESS3,
P.ZIPCODE,
P.CITY,
HP.txtvalue as HomePhone,
Email.txtvalue as Email,
TO_date(CRDT.txtvalue,'YYYY-MM-DD')as CR_DATE,
P.PERSONTYPE,
DECODE(P.PERSONTYPE,0,'Private',2,'Staff',3,'Student',4,'Corporate') as PersonType,
ei.IDENTITY as MembercardID,
PA.REF AS PaymentAgreementReferenceId,
DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') PaymentAgreementState,
PA.BANK_REGNO,
PA.BANK_BRANCH_NO,
PA.BANK_ACCNO,
longtodate(PA.CREATION_TIME) as PaymentAgreementCreationDate,
(comp.CENTER)||'p' ||(COMP.ID) as ComapnyID,
otherPayer.txtvalue as OtherPayerID,
PA.BANK_ACCOUNT_HOLDER,
PruEntityNum.txtvalue as PruEntityNum,
PA.PAYMENT_CYCLE_CONFIG_ID,
PA.REQUESTS_SENT,
Decode(EmailChnl.txtvalue,'true',1,'false',0) as ChannelEmail,
Decode(LetterChnl.txtvalue,'true',1,'false',0) as ChannelLetter,
Decode(PhoneChnl.txtvalue,'true',1,'false',0) as ChannelPhone,
Decode(SMSChnl.txtvalue,'true',1,'false',0) as ChannelSMS
from 
persons P
LEFT JOIN ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
    AND ar.AR_TYPE = 4
LEFT JOIN PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
LEFT JOIN PAYMENT_AGREEMENTS PA
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.ID = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
left join PERSON_EXT_ATTRS Salut
on 
   P.ID = Salut.Personid 
   and Salut.name = '_eClub_Salutation'
   and Salut.personcenter = P.CENTER
left join PERSON_EXT_ATTRS Email 
on 
   P.ID = Email.Personid
   and Email.personcenter = P.CENTER  
   and Email.name = '_eClub_Email'
left join PERSON_EXT_ATTRS HP 
on 
   P.ID = HP.Personid
   and HP.personcenter = P.CENTER  
   and HP.name = '_eClub_PhoneHome'
left join PERSON_EXT_ATTRS WP 
on 
   P.ID = WP.Personid
   and WP.personcenter = P.CENTER  
   and WP.name = '_eClub_WorkHome'
left join PERSON_EXT_ATTRS CRDT 
on 
   P.ID = CRDT.Personid
   and CRDT.personcenter = P.CENTER  
   and CRDT.name = 'CREATION_DATE'
left join PERSON_EXT_ATTRS Mobile 
on 
   P.ID = Mobile.Personid
   and Mobile.personcenter = P.CENTER  
   and Mobile.name = '_eClub_PhoneSMS'
left join PERSON_EXT_ATTRS OldPID 
on 
   P.ID = OldPID.Personid
   and OldPID.personcenter = P.CENTER  
   and OldPID.name = '_eClub_OldSystemPersonId'
left join PERSON_EXT_ATTRS CmpAgEmNum 
on 
   P.ID = CmpAgEmNum.Personid
   and CmpAgEmNum.personcenter = P.CENTER  
   and CmpAgEmNum.name = 'COMPANY_AGREEMENT_EMPLOYEE_NUMBER'
left join PERSON_EXT_ATTRS PruEntityNum
on 
   P.ID = PruEntityNum.Personid
   and PruEntityNum.personcenter = P.CENTER  
   and PruEntityNum.name = '_eClub_PBLookupPartnerPersonId'
left join PERSON_EXT_ATTRS EmailChnl
on 
   P.ID = EmailChnl.Personid
   and EmailChnl.personcenter= P.CENTER  
   and EmailChnl.name = '_eClub_AllowedChannelEmail'
left join PERSON_EXT_ATTRS LetterChnl
on 
   P.ID = LetterChnl.Personid
   and LetterChnl.personcenter= P.CENTER  
   and LetterChnl.name = '_eClub_AllowedChannelLetter'
left join PERSON_EXT_ATTRS PhoneChnl
on 
   P.ID = PhoneChnl.Personid
   and PhoneChnl.personcenter= P.CENTER  
   and PhoneChnl.name = '_eClub_AllowedChannelPhone'
left join PERSON_EXT_ATTRS SMSChnl
on 
   P.ID = SMSChnl.Personid
   and SMSChnl.personcenter= P.CENTER  
   and SMSChnl.name = '_eClub_AllowedChannelSMS'
LEFT JOIN RELATIVES rel
ON
    rel.RELATIVECENTER = p.CENTER
    AND rel.RELATIVEID = p.ID
    AND rel.RTYPE = 12
    AND rel.STATUS = 1
left join PERSON_EXT_ATTRS otherPayer 
on 
   otherPayer.Personid = rel.ID
   and otherPayer.personcenter = rel.CENTER   
   and otherPayer.name = '_eClub_OldSystemPersonId'
LEFT JOIN RELATIVES relcomp
ON
    relcomp.CENTER = p.CENTER
    AND relcomp.ID = p.ID
    AND relcomp.RTYPE = 3
    AND relcomp.STATUS = 1
LEFT JOIN COMPANYAGREEMENTS ca
ON
    ca.CENTER = relcomp.RELATIVECENTER
    AND ca.ID = relcomp.RELATIVEID
    AND ca.SUBID = relcomp.SUBID
LEFT JOIN PERSONS comp
ON
    comp.CENTER = relcomp.RELATIVECENTER
    AND comp.ID = relcomp.RELATIVEID
Left JOIN ENTITYIDENTIFIERS ei
ON
    ei.REF_CENTER = p.CENTER
    AND ei.REF_ID = p.ID
    AND ei.REF_TYPE = 1
	and IDMethod = 1
	and entitystatus=1
where OldPID.txtvalue is not null
AND P.CENTER =401
order by OldPID.txtvalue asc
   