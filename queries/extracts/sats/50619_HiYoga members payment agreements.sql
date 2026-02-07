SELECT
    p.CENTER || 'p' || p.ID pid
  , p.FULLNAME
  , p.FIRST_ACTIVE_START_DATE
  ,MAX(longToDateC(pa2.CREATION_TIME,pa.CENTER)) inactive_created
  , longToDateC(pa.CREATION_TIME,pa.CENTER)      active_created
  , DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,
    'Agreement information incomplete')  active_state
  , DECODE(p.SEX,'C','COMPANY','PERSON') TYPE
FROM
    PERSONS p
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
    AND ar.AR_TYPE = 4
JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.ID = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
    AND pa.STATE != 4
JOIN
    PAYMENT_AGREEMENTS pa2
ON
    pa2.CENTER = ar.CENTER
    AND pa2.id = ar.ID
    AND pa2.SUBID != pac.ACTIVE_AGR_SUBID
    AND pa2.STATE = 4
WHERE
    p.STATUS IN (0,1,2,3,9)
    AND p.CENTER in ($$scope$$)
GROUP BY
    p.CENTER
  ,p.ID
  , p.FULLNAME
  , p.FIRST_ACTIVE_START_DATE
  , longToDateC(pa.CREATION_TIME,pa.CENTER)
  , DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,
    'Agreement information incomplete')
  , DECODE(p.SEX,'C','COMPANY','PERSON')