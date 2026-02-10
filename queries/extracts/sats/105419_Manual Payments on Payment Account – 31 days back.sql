-- The extract is extracted from Exerp on 2026-02-08
-- EC-10235
WITH params AS MATERIALIZED
                (
                        SELECT
                                CAST(datetolong(TO_CHAR(current_date - interval '31 day', 'YYYY-MM-DD')) AS BIGINT) AS fromDateLong,
                                CAST(datetolong(TO_CHAR(current_date, 'YYYY-MM-DD')) AS BIGINT) AS toDateLong,
                                c.id as center_id,
                                c.name as center_name
                                
                       
                                        FROM 
                                                centers c
                                           
            where  c.id in (:scope) 
            
                  )                      
SELECT distinct
                r3.*
        FROM
        (
              Select
                       ar.CUSTOMERCENTER|| 'p'|| ar.CUSTOMERID AS "Member ID",
c.country,
                        longToDateC(act.ENTRY_TIME, art.center) AS "Payment date",
                        art.amount as "Paid amount"                                              
                      --  act.text
                       -- act.info_type,
                   --     art.employeecenter,
                       -- art.employeeid
                   
   
   
FROM ACCOUNT_TRANS act

join params
on params.center_id = act.center


JOIN
    AR_TRANS art
ON
  art.REF_TYPE = 'ACCOUNT_TRANS'
  and   art.REF_CENTER = act.center
    AND art.REF_ID = act.id
    AND art.REF_SUBID = act.subid
and art.entry_TIME >=  params.fromDateLong 
AND art.entry_TIME < params.toDateLong  
and art.employeecenter = 100   and art.employeeid = 41098

JOIN
    ACCOUNT_RECEIVABLES AR
ON
    AR.CENTER = art.CENTER
    AND AR.ID = ART.ID
   
     
JOIN
    PERSONS P
ON
    P.CENTER = AR.CUSTOMERCENTER
    AND P.ID = AR.CUSTOMERID
JOIN
    centers c
ON
    P.CENTER = c.id
   
where    
act.entry_TIME >=  params.fromDateLong 
AND act.entry_TIME < params.toDateLong 
and act.info_type  in  (23)
and act.AMOUNT > 0 

)r3