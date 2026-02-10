-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     *
 FROM
     (
         SELECT
             ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID pid,
             oldId.TXTVALUE                            oldSysId,
             SUM(art.AMOUNT)                           balance,
             SUM(
                 CASE
                     WHEN art.DUE_DATE IS NOT NULL
                         AND art.DUE_DATE < CURRENT_TIMESTAMP
                     THEN art.UNSETTLED_AMOUNT
                     ELSE 0
                 END) AS overdue_debt,
             SUM(
                 CASE
                     WHEN art.EMPLOYEECENTER = 100
                         AND art.EMPLOYEEID = 1
                         AND art.REF_TYPE = 'ACCOUNT_TRANS'
                         AND art.AMOUNT < 0
                     THEN art.AMOUNT
                     ELSE 0
                 END) AS converted_debt
         FROM
             AR_TRANS art
         JOIN
             ACCOUNT_RECEIVABLES ar
         ON
             ar.CENTER = art.CENTER
             AND ar.ID = art.ID
         LEFT JOIN
             PERSON_EXT_ATTRS oldId
         ON
             oldId.PERSONCENTER = ar.CUSTOMERCENTER
             AND oldId.PERSONID = ar.CUSTOMERID
             AND oldId.NAME = '_eClub_OldSystemPersonId'
         WHERE
             ar.AR_TYPE = 4
             AND EXISTS
             (
                 SELECT
                     1
                 FROM
                     AR_TRANS art2
                 WHERE
                     art2.CENTER = ar.CENTER
                     AND art2.ID = ar.ID
                     AND art2.EMPLOYEECENTER = 100
                     AND art2.EMPLOYEEID = 1
                     AND art2.REF_TYPE = 'ACCOUNT_TRANS'
                     AND art2.AMOUNT < 0 )
         GROUP BY
             ar.CUSTOMERCENTER,
             ar.CUSTOMERID,
             oldId.TXTVALUE ) t1
