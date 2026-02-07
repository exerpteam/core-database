-- This is the version from 2026-02-05
--  
SELECT DISTINCT 
    ar.customercenter ||'p'||ar.customerid Member, per.external_id,per.firstname,per.lastname,pea.txtvalue "E-mail"
FROM
    ar_trans art
JOIN
    ACCOUNT_RECEIVABLES ar
ON
   ar.center = art.center
AND ar.id = art.id
join persons per
on per.id =ar.customerid
and per.center = ar.customercenter
JOIN person_ext_attrs pea
ON pea.PERSONCENTER = per.center
AND pea.PERSONID = per.id
WHERE

    art.text like 'Reversal%' and art.entry_time between  1566252000000 and 1566338400000
and ar.AR_TYPE = 6 AND pea.NAME = '_eClub_Email' 
--and per.status = 1
 --and pr.req_date > to_date('20-01-2020,'dd-mm-yyyy')
