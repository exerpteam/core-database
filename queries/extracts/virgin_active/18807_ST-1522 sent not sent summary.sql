SELECT
    COUNT(1)
  , sc.CENTER
  , pa.CLEARINGHOUSE
  , CASE
        WHEN sc.STATE = pa.STATE
        THEN 'N'
        ELSE 'Y'
    END state_changed
  , DECODE(sc.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') PREV_STATE
  , DECODE(pa.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') CURR_STATE
FROM
    BCK_ST1522 sc
JOIN
    PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = sc.CENTER
    AND pa.id = sc.id
    AND pa.SUBID = sc.SUBID
GROUP BY
    sc.CENTER
  , pa.CLEARINGHOUSE
  , CASE
        WHEN sc.STATE = pa.STATE
        THEN 'N'
        ELSE 'Y'
    END 
  , sc.STATE
  , pa.STATE 