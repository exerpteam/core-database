-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     lpad(IDENTITY,16,'0') || rpad(FIRSTNAME || ' ' || LASTNAME,20) || '000' || case sign(COALESCE( SUM(AMOUNT),0)) when 0 then '0' when -1 then '0' when +1 then '-' end || lpad(CAST(ABS(COALESCE( SUM(AMOUNT),0)*100) AS VARCHAR),7,'0') || lpad(CAST(DEBIT_MAX AS VARCHAR),6,'0') as "data"
 FROM
     (
         SELECT DISTINCT
             ei.IDENTITY,
             p.CENTER,
             p.ID,
             p.FIRSTNAME,
             p.LASTNAME,
             art.CENTER art_center,
             art.ID     art_id,
             art.SUBID  art_subid,
             art.AMOUNT,
             ar.DEBIT_MAX
         FROM
             PERSONS p
         JOIN
             ACCOUNT_RECEIVABLES ar
         ON
             ar.CUSTOMERCENTER = p.CENTER
             AND ar.CUSTOMERID = p.ID
             AND ar.AR_TYPE = 1
         JOIN
             ENTITYIDENTIFIERS ei
         ON
             ei.REF_CENTER = p.CENTER
             AND ei.REF_ID = p.ID
             AND ei.REF_TYPE = 1
             AND ei.ENTITYSTATUS = 1
         LEFT JOIN
             AR_TRANS art
         ON
             art.CENTER = ar.CENTER
             AND art.ID = ar.ID
         WHERE
             ei.IDMETHOD <> 4
                         AND ar.DEBIT_MAX > 0
             AND p.center IN (:scope) ) t1
 GROUP BY
     CENTER,
     id ,
     lpad(IDENTITY,16,'0'),
     rpad(FIRSTNAME || ' ' || LASTNAME,20),
     DEBIT_MAX
