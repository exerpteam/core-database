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
        ar.customercenter||'p'||ar.customerid                           AS "Company ID"
        ,p.fullname                                                     AS "Company name"
        ,emppam.fullname                                                AS "Account manager"
        ,art.ref_center||'acc'||art.ref_id||'tr'||art.ref_subid         AS "Transaction reference"
        ,TO_CHAR(longtodatec(art.trans_time,art.center),'yyyy-MM-dd')   AS "Transaction date"
        ,art.text                                                       AS "Transaction text"
        ,art.amount                                                     AS "Transaction amount"
        ,pemp.fullname                                                  AS "Employee"
        ,acdebit.name                                                   AS "GL account"
FROM
        account_receivables ar
JOIN
        ar_trans art   
        ON art.center = ar.center    
        AND art.id = ar.id
        AND art.info IS NULL
JOIN
        leejam.account_trans act
        ON act.center = art.ref_center
        AND act.id = art.ref_id
        AND act.subid = art.ref_subid         
JOIN
        leejam.persons p             
        ON p.center = ar.customercenter
        AND p.id = ar.customerid
        AND p.sex = 'C'
LEFT JOIN
        leejam.relatives AccountMGR
        ON AccountMGR.center = p.center
        AND AccountMGR.id = p.id
        AND AccountMGR.rtype = 10
        AND AccountMGR.status = 1
        AND (AccountMGR.expiredate IS NULL OR AccountMGR.expiredate > Current_Date)
LEFT JOIN
        leejam.persons emppam
        ON emppam.center = AccountMGR.relativecenter
        AND emppam.id = AccountMGR.relativeid  
JOIN
        leejam.employees emp
        ON emp.center = art.employeecenter
        AND emp.id = art.employeeid
JOIN
        leejam.persons pemp
        ON pemp.center = emp.personcenter
        AND pemp.id = emp.personid    
JOIN
        leejam.accounts acdebit
        ON acdebit.center = act.debit_accountcenter
        AND acdebit.id = act.debit_accountid  
JOIN
        params
        ON params.CENTER_ID = act.center                                    
WHERE
        art.amount > 0
        AND
        ar.customercenter IN (:Scope)
        AND
        art.trans_time BETWEEN params.FromDate AND params.ToDate
        AND
        ar.balance > 0
        AND 
        art.status != 'CLOSED'        