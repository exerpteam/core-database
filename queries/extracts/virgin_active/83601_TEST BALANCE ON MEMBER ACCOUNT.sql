with 
     params as materialized 
     (   
        select
                center,
                id,
                UNSETTLED_AMOUNT
        from AR_TRANS art        
        where  
           ( art.DUE_DATE IS NULL  OR  art.DUE_DATE > CURRENT_TIMESTAMP)
        AND art.UNSETTLED_AMOUNT !=0 
     )
 SELECT
     ar.CUSTOMERCENTER,
     ar.CUSTOMERID,
     PERSONS.firstname,
     PERSONS.lastname,
 case  persons.status  when 0 then 'Lead'  when 1 then 'Active'  when 2 then 'Inactive'  when 3 then 'Temporary Inactive'  when 4 then 'Transferred'  when 5 then 'Duplicate'  when 6 then 'Prospect'  when 7 then 'Deleted' when 8 then  'Anonymized'  when 9 then  'Contact'  else 'Unknown' end as "Person status",
     ar.BALANCE,
     COALESCE(SUM(params.UNSETTLED_AMOUNT), 0) AS "Open, Not Due Balance"
 FROM
     ACCOUNT_RECEIVABLES ar
 JOIN
     persons
 ON
     ar.customercenter = PERSONS.center
 AND ar.customerid = PERSONS.id
 LEFT JOIN
     params
 ON
     ar.center = params.CENTER
 AND ar.ID = params.ID
 WHERE
     ar.CENTER IN ($$scope$$)
 AND ar.AR_TYPE = 4
 AND ar.BALANCE > -100000
 AND ar.BALANCE < -4
 GROUP BY
     ar.CUSTOMERCENTER,
     ar.CUSTOMERID,
     PERSONS.firstname,
     PERSONS.lastname,
     PERSONS.STATUS,
     ar.BALANCE