-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     p.CENTER || 'p' ||  p.ID pid,
     p.LASTNAME AS name,
     ar.BALANCE CREIT_BALANCE,
     ar.DEBIT_MAX MAX_CREDIT_LIMIT,
     round(case ar.BALANCE when 0 then 1 else ar.BALANCE * -1 end / ar.DEBIT_MAX ,2) * 100 PERCENTAGE_CREDIT_USED
 FROM
     PERSONS p
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = p.CENTER
     AND ar.CUSTOMERID = p.ID
     and ar.AR_TYPE = 4
 WHERE
     p.SEX = 'C'
     and ar.BALANCE < 0
     and round(case ar.BALANCE when 0 then 1 else ar.BALANCE * -1 end / ar.DEBIT_MAX ,2) * 100 > 70
         and p.center in ($$scope$$)
