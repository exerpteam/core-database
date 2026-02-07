SELECT
    p.CENTER || 'p' || p.id "Payer PID"
  , p.FULLNAME "Payer full name"
  , pc.SHORTNAME "Payer home club"
  , pc.ID "Payer home club id"
  , pa.REF "Payer PA REF"
  ,DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,
    'Agreement information incomplete') agreement_state
  ,ch.NAME "Clearing house"
  , chc.CREDITOR_NAME "Clearing house creditor"
  ,chc.FIELD_1 "Bank source code"
  ,chc.FIELD_3 "Bank account number"
  ,chc.FIELD_6 "Service user number"
  , paid.CENTER || 'p' || paid.ID "Paid PID"
  , paid.FULLNAME "Paid full name"
  , paidC.SHORTNAME "Paid home club"
  , paidC.ID "Paid home club id"
FROM
    PAYMENT_AGREEMENTS pa
JOIN
    CLEARINGHOUSE_CREDITORS chc
ON
    chc.CLEARINGHOUSE = pa.CLEARINGHOUSE
    AND chc.CREDITOR_ID = pa.CREDITOR_ID
JOIN
    CLEARINGHOUSES ch
ON
    ch.ID = chc.CLEARINGHOUSE
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
    AND ar.id = pac.ID
    AND ar.AR_TYPE = 4
JOIN
    PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.id = ar.CUSTOMERID
JOIN
    CENTERS pc
ON
    pc.ID = p.CENTER
LEFT JOIN
    RELATIVES rel
ON
    rel.CENTER = ar.CUSTOMERCENTER
    AND rel.id = ar.CUSTOMERID
    AND rel.RTYPE = 12
    AND rel.STATUS = 1
LEFT JOIN
    PERSONS paid
ON
    paid.CENTER = rel.RELATIVECENTER
    AND paid.ID = rel.RELATIVEID
LEFT JOIN
    CENTERS paidC
ON
    paidC.ID = paid.CENTER
WHERE
	pa.state in (1,4) and 
    (pa.CENTER in ($$scope$$) or paid.CENTER in ($$scope$$))
    and (
    pa.CENTER IN (427)
    OR (
        pa.CENTER,pa.id,pa.SUBID) IN
    (
        SELECT
            pa2.CENTER
          ,pa2.ID
          ,pa2.SUBID
        FROM
            RELATIVES rel2
        JOIN
            ACCOUNT_RECEIVABLES ar2
        ON
            ar2.CUSTOMERCENTER = rel2.CENTER
            AND ar2.CUSTOMERID = rel2.ID
        JOIN
            PAYMENT_ACCOUNTS pac2
        ON
            pac2.CENTER = ar2.CENTER
            AND pac2.ID = ar2.ID
        JOIN
            PAYMENT_AGREEMENTS pa2
        ON
            pa2.CENTER = pac2.ACTIVE_AGR_CENTER
            AND pa2.ID = pac2.ACTIVE_AGR_ID
            AND pa2.SUBID = pac2.ACTIVE_AGR_SUBID
        WHERE
            rel2.RTYPE = 12
            AND rel2.STATUS = 1
            AND rel2.RELATIVECENTER IN (427) ))