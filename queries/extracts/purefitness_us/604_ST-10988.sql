-- The extract is extracted from Exerp on 2026-02-08
-- Extract to report on ADDACS files
SELECT
    ar.CUSTOMERCENTER||'p'||ar.CUSTOMERID AS "P Number",
    CASE
        WHEN p.EXTERNAL_ID IS NULL
        THEN vp.EXTERNAL_ID
        ELSE p.EXTERNAL_ID
    END                                                                                                                                                                                                        AS "External ID",
    pag.REF                                                                                                                                                                                                        AS "BACS reference",
    TO_CHAR(longtodatec(acl.ENTRY_TIME,acl.AGREEMENT_CENTER),'YYYY-mm-DD')                                                                                                                                                                                                        AS "Entry Date",
    TO_CHAR(acl.LOG_DATE,'YYYY-mm-DD')                                                                                                                                                                                                        AS "Log date",
   /* DECODE(acl.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete',15,'Transfer',16,'Agreement Recreated',17, 'Signature missing', 'UNDEFINED') AS "Agreement State Change",*/
  CASE WHEN acl.STATE = 1 THEN 'CREATED' WHEN acl.STATE = 2 THEN 'SENT' WHEN acl.STATE = 3 THEN 'FAILED' WHEN acl.STATE = 4 THEN 'AGREEMENT CONFIRMED' WHEN acl.STATE = 5 THEN 'ENDED BY DEBITORS BANK' WHEN acl.STATE = 6 THEN 'ENDED BY THE CLEARING HOUSE' WHEN acl.STATE = 7 THEN 'ENDED BY DEBITOR' WHEN acl.STATE = 8 THEN 'SHALL BE CANCELLED' WHEN acl.STATE = 9 THEN 'END REQUEST SENT' WHEN acl.STATE = 10 THEN 'AGREEMENT ENDED BY CREDITOR' WHEN acl.STATE = 11 THEN 'NO AGREEMENT WITH DEBITOR' WHEN acl.STATE = 12 THEN 'DEPRICATED' WHEN acl.STATE = 13 THEN 'NOT NEEDED' WHEN acl.STATE = 14 THEN 'INCOMPLETE' WHEN acl.STATE = 15 THEN 'TRANSFERRED' WHEN acl.STATE = 16 THEN 'AGREEMENT RECREATED' WHEN acl.STATE = 17 THEN 'SIGNATURE MISSING' ELSE 'Undefined' END AS "Agreement State Change",

    acl.TEXT                                                                                                                                                                                                        AS "Reason",
    ci.ID                                                                                                                                                                                                        AS "File ID"
FROM
    AGREEMENT_CHANGE_LOG acl
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = acl.AGREEMENT_CENTER
    AND ar.ID = acl.AGREEMENT_ID
JOIN
    persons p
ON
    p.center = ar.customercenter
    AND p.id = ar.customerid
LEFT JOIN
    persons vp
ON
    vp.CENTER = p.CURRENT_PERSON_CENTER
    AND vp.ID = p.CURRENT_PERSON_ID
JOIN
    CLEARING_IN ci
ON
    ci.ID = acl.CLEARING_IN
JOIN
    PAYMENT_AGREEMENTS pag
ON
    pag.center = acl.AGREEMENT_CENTER
    AND pag.id = acl.AGREEMENT_ID
    AND pag.SUBID = acl.AGREEMENT_SUBID
	
WHERE
	UPPER(ci.FILENAME) LIKE '%ADDACS%'
    AND acl.ENTRY_TIME >= $$from_date$$
    AND acl.ENTRY_TIME <= $$to_date$$
    AND acl.AGREEMENT_CENTER in ($$scope$$)