-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
        params AS
        (
        SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate                        
      FROM
          centers c
        )        
SELECT 
        c.name AS Club
        ,c.id AS ClubID        
        ,ar.customercenter||'p'||ar.customerid AS "Person ID"
        ,p.external_id AS "External ID"
        ,CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE
        ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PersonStatus
        ,p.fullname AS MemberName
        ,CASE
                WHEN ar.ar_type = 1 THEN 'CASH Account'
                WHEN ar.ar_type = 4 THEN 'Payment Account'
        END AS "Account Type" 
        ,CASE
                WHEN art.ref_type = 'INVOICE' THEN art.ref_center||'inv'||art.ref_id
                WHEN art.ref_type = 'CREDIT_NOTE' THEN art.ref_center||'cred'||art.ref_id
                WHEN art.ref_type = 'ACCOUNT_TRANS' THEN art.ref_center||'acc'||art.ref_id||'tr'||art.ref_subid  
        END AS "Transaction ID" 
        ,art.amount
        ,art.due_date
        ,art.text                               
        ,longtodatec(art.trans_time,art.center) AS "Book Date"
        ,longtodatec(art.entry_time,art.center) AS "Entry Time"
        
FROM
        evolutionwellness.account_receivables ar
JOIN
        evolutionwellness.ar_trans art
        ON ar.center = art.center
        AND ar.id = art.id
JOIN
        params
        ON params.CENTER_ID = art.center        
JOIN
        evolutionwellness.centers c
        ON c.id = art.center
JOIN
        evolutionwellness.persons p
        ON p.center = ar.customercenter
        AND p.id = ar.customerid        
WHERE
        ar.ar_type IN (1,4)
        AND
        art.entry_time BETWEEN params.FromDate AND params.ToDate
        AND
        ar.customercenter IN (:Scope)
ORDER BY 1,3