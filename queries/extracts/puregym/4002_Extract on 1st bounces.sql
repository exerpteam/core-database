-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    distinct 
    cen.NAME,
    per.center || 'p' || per.id AS PersonKey,
    per.FULLNAME,
    failed_pr.req_date,
    email.TXTVALUE as email,
    home.TXTVALUE as homePhone,
    mobile.TXTVALUE as mobile,
    acr.BALANCE as Debt,
    EXERP_CI.MaxExerp as LastCheckin

   
FROM
    PUREGYM.PERSONS per
JOIN
    PUREGYM.MESSAGES mes
ON
    mes.CENTER = per.CENTER
    AND mes.ID = per.ID
    AND mes.MESSAGE_TYPE_ID = 97
JOIN
    PUREGYM.ACCOUNT_RECEIVABLES acr
ON
    acr.CUSTOMERCENTER = per.CENTER
    AND acr.CUSTOMERID = per.ID
    AND acr.AR_TYPE = 4
JOIN PUREGYM.PAYMENT_ACCOUNTS pac on pac.center = acr.center and pac.id = acr.id
JOIN PUREGYM.PAYMENT_AGREEMENTS pag on pag.center = pac.ACTIVE_AGR_center and pag.id = pac.ACTIVE_AGR_id and pag.SUBID = pac.ACTIVE_AGR_SUBID

JOIN
    PUREGYM.PAYMENT_REQUESTS failed_pr
ON
       failed_pr.CLEARINGHOUSE_ID = pag.CLEARINGHOUSE and failed_pr.CREDITOR_ID = pag.CREDITOR_ID and failed_pr.req_date > sysdate -30
       and failed_pr.center || 'ar' || failed_pr.id  || 'req' || failed_pr.subid = mes.reference 

LEFT JOIN
    PUREGYM.PAYMENT_REQUESTS pr
ON
    pr.CENTER = acr.CENTER
    AND pr.ID = acr.ID
    AND pr.ENTRY_TIME > mes.SENTTIME
--    AND pac.REQUEST_TYPE = 6
--    AND pac.STATE NOT IN (1,2,3,4,8,12)
--    AND pac.REJECTED_REASON_CODE = '0'  
    
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS email
ON
    email.personcenter = per.center
    AND email.personid = per.id
    AND email.name = '_eClub_Email'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS mobile
ON
    mobile.personcenter = per.center
    AND mobile.personid = per.id
    AND mobile.name = '_eClub_PhoneSMS'
    
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS home
ON
    home.personcenter = per.center
    AND home.personid = per.id
    AND home.name = '_eClub_PhoneHome' 
    
JOIN 
PUREGYM.CENTERS cen
on cen.ID = per.CENTER   

LEFT JOIN
            (
                SELECT
                    p.center,
                    p.id,
                    TO_CHAR(longtodateTZ(MAX(ci.CHECKIN_TIME), 'Europe/London'), 'YYYY-MM-DD HH24:MI') AS MaxExerp
                FROM
                    PUREGYM.PERSONS p
                LEFT JOIN PUREGYM.CHECKINS ci
                ON
                    ci.PERSON_CENTER = p.center
                    AND ci.PERSON_ID = p.id
                GROUP BY
                    p.center,
                    p.id
            )
            EXERP_CI
        ON
            EXERP_CI.center = per.center
            AND EXERP_CI.id = per.id    

WHERE
    per.CENTER = :center
    --AND per.ID = 201
    AND per.STATUS = 3
    and mes.SENTTIME > datetolong(to_char(sysdate - 15, 'YYYY-MM-DD HH24:MI'))
    and pr.CENTER is null
    and acr.balance < 0
--    AND pac.REQ_DATE > to_date('2014-04-01', 'YYYY-MM-DD')

Order by
       failed_pr.req_date 