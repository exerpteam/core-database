select ar.CUSTOMERCENTER as PERSONCENTER, ar.CUSTOMERID as PERSONID,
 (TO_DATE('1970-01-01','yyyy-MM-dd HH24:MI:SS') + crt.TRANSTIME/(24*3600*1000) + 1/24) as TRANS_TIME, 
crt.AMOUNT, crt.CENTER as CASHREGISTER_CENTER, crt.id as CASHREGISTER_ID, crt.CRTTYPE
from ECLUB2.CASHREGISTERTRANSACTIONS crt
join ECLUB2.ACCOUNT_RECEIVABLES ar on crt.ARTRANSCENTER = ar.CENTER and crt.ARTRANSID = ar.id
where 
    crt.center = :CENTER and 
    crt.AMOUNT between :AmountFrom and :AmountTo and
    TO_DATE('1970-01-01','yyyy-MM-dd') + crt.TRANSTIME/(24*3600*1000) + 2/24 >  :OnDate
    and TO_DATE('1970-01-01','yyyy-MM-dd') + crt.TRANSTIME/(24*3600*1000) + 2/24 < :OnDate + 24*3600*1000
    and exists(
        select art.center from ECLUB2.AR_TRANS art
        where crt.ARTRANSCENTER = art.CENTER and crt.ARTRANSID = art.id and  crt.ARTRANSSUBID = art.subid
    )
