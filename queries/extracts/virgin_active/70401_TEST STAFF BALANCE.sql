-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     ar.CUSTOMERCENTER,
     ar.CUSTOMERID,
     PERSONS.firstname,
     PERSONS.lastname,
	 PERSONS.persontype,
 case  persons.status  when 0 then 'Lead'  when 1 then 'Active'  when 2 then 'Inactive'  when 3 then 'Temporary Inactive'  when 4 then 'Transferred'  when 5 then 'Duplicate'  when 6 then 'Prospect'  when 7 then 'Deleted' when 8 then  'Anonymized'  when 9 then  'Contact'  else 'Unknown' end as "Person status",
     ar.BALANCE,
     COALESCE(SUM(art.UNSETTLED_AMOUNT), 0) AS "Open, Not Due Balance"
 FROM
     ACCOUNT_RECEIVABLES ar
 JOIN
     persons
 ON
     ar.customercenter = PERSONS.center
 AND ar.customerid = PERSONS.id
AND PERSONS.persontype = 2

 LEFT JOIN
     AR_TRANS art
 ON
     ar.center = art.CENTER
 AND ar.ID = art.ID
 AND (
         art.DUE_DATE IS NULL
     OR  art.DUE_DATE > CURRENT_TIMESTAMP)
 AND art.UNSETTLED_AMOUNT !=0
 WHERE
     ar.CENTER IN (:scope)
 AND ar.AR_TYPE = :Kontotype
 AND ar.BALANCE > :MoreThan
 AND ar.BALANCE < :LessThan
 GROUP BY
     ar.CUSTOMERCENTER,
     ar.CUSTOMERID,
     PERSONS.firstname,
     PERSONS.lastname,
     PERSONS.STATUS,
	 PERSONS,persontype,
     ar.BALANCE