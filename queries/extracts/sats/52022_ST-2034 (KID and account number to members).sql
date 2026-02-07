
SELECT
    p.CENTER || 'p' || p.ID pid
  ,p.FIRSTNAME
  ,p.LASTNAME
  ,email.TXTVALUE  email
  ,mob.TXTVALUE    mobile
  ,phoneH.TXTVALUE home_phone
  ,phoneW.TXTVALUE work_phone
  , pa.REF         PA_REF
  , pa.BANK_REGNO
  , pa.BANK_ACCNO
  ,DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,
    'Agreement information incomplete') AGREEMENT_STATE
  ,ch.NAME                              CLEARING_HOUSE
  ,chc.CREDITOR_NAME
FROM
    PAYMENT_AGREEMENTS pa
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.ACTIVE_AGR_CENTER = pa.CENTER
    AND pac.ACTIVE_AGR_ID = pa.ID
    AND pac.ACTIVE_AGR_SUBID = pa.SUBID
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = pac.CENTER
    AND ar.ID = pac.ID
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID
    AND p.STATUS IN (1,3)
    AND p.SEX != 'C'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = p.CENTER
    AND email.PERSONID = p.ID
    AND email.NAME = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS mob
ON
    mob.PERSONCENTER = p.CENTER
    AND mob.PERSONID = p.ID
    AND mob.NAME = '_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS phoneH
ON
    phoneH.PERSONCENTER = p.CENTER
    AND phoneH.PERSONID = p.ID
    AND phoneH.NAME = '_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS phoneW
ON
    phoneW.PERSONCENTER = p.CENTER
    AND phoneW.PERSONID = p.ID
    AND phoneW.NAME = '_eClub_PhoneWork'
JOIN
    CENTERS c
ON
    c.id = p.CENTER
    AND c.COUNTRY = 'NO'
JOIN
    CLEARINGHOUSES ch
ON
    ch.ID = pa.CLEARINGHOUSE
JOIN
    CLEARINGHOUSE_CREDITORS chc
ON
    chc.CLEARINGHOUSE = ch.id
    AND chc.CREDITOR_ID = pa.CREDITOR_ID
WHERE
    pa.STATE NOT IN (4,13) 

