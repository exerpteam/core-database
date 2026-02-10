-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4747
SELECT
        p.CENTER || 'p' || p.ID AS "MEMBER ID",
        DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED',
        5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS "MEMBER STATE",
        DECODE(pag.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',
        8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',
        12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete',
        15,'Transfer',16,'Agreement Recreated',17, 'Signature missing', 'UNDEFINED') AS "PAYMENT STATE",
        ch.NAME AS "CLEARINGHOUSE"
        /*(CASE 
                WHEN r.CENTER IS NOT NULL THEN 'YES'
                ELSE 'NO'
        END) "IS_PAYER",
        (CASE 
                WHEN r2.CENTER IS NOT NULL THEN 'YES'
                ELSE 'NO'
        END) "HAS__PAYER"*/
FROM FW.PAYMENT_AGREEMENTS pag 
JOIN FW.CLEARINGHOUSES ch ON ch.ID = pag.CLEARINGHOUSE
JOIN FW.PAYMENT_ACCOUNTS pac ON pac.ACTIVE_AGR_CENTER = pag.CENTER AND pac.ACTIVE_AGR_ID = pag.ID AND pac.ACTIVE_AGR_SUBID = pag.SUBID
JOIN FW.ACCOUNT_RECEIVABLES ar ON pac.CENTER = ar.CENTER AND pac.ID = ar.ID AND ar.AR_TYPE = 4
JOIN FW.PERSONS p ON p.CENTER = ar.CUSTOMERCENTER AND p.ID = ar.CUSTOMERID
LEFT JOIN FW.RELATIVES r ON r.CENTER = p.CENTER AND r.ID = p.ID AND r.RTYPE = 12 AND r.STATUS < 2
LEFT JOIN FW.PERSONS mem ON mem.CENTER = r.RELATIVECENTER AND mem.ID = r.RELATIVEID
LEFT JOIN FW.RELATIVES r2 ON r2.RELATIVECENTER = p.CENTER AND r2.RELATIVEID = p.ID AND r2.RTYPE = 12 AND r2.STATUS < 2
WHERE 
        (
                (r.CENTER IS NULL AND p.STATUS IN (1,3))
                OR
                (r.CENTER IS NOT NULL AND mem.STATUS IN (1,3))
        )
        AND p.CENTER IN (:Scope)
        AND pag.CLEARINGHOUSE IN (:Clearinghouse)