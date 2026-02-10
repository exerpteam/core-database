-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
        p.EXTERNAL_ID AS "EXTERNALID",
        --sub.end_date,
        CASE
            WHEN sub.end_date > TRUNC (longtodateC (sc.CHANGE_TIME, sub.center))
            THEN 'MEMBER'
            ELSE 'PUREFITNESS'
        END                                                              AS "CANCELLATIONSOURCE",
        TO_CHAR (longtodateC (sc.CHANGE_TIME, sub.center), 'YYYY-MM-DD') AS "CANCELLATIONDATE"
 from SUBSCRIPTIONS sub
 join SUBSCRIPTION_CHANGE sc on sc.OLD_SUBSCRIPTION_CENTER = sub.center and sc.OLD_SUBSCRIPTION_ID = sub.id
 join PERSONS p on p.CENTER = sub.OWNER_CENTER and p.id = sub.OWNER_ID
 join SUBSCRIPTIONTYPES st on st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER and st.ID = sub.SUBSCRIPTIONTYPE_ID
 left join ACCOUNT_RECEIVABLES ar on ar.CUSTOMERCENTER = p.center and ar.CUSTOMERID = p.id and ar.AR_TYPE = 4
 left join PAYMENT_REQUESTS pr on pr.center = ar.center and pr.id = ar.id and pr.REQUEST_TYPE = 1 and pr.REQ_DATE >= (to_timestamp(getcentertime(sub.center), 'YYYY-MM-DD HH24:MI:SS') - interval '7' day) and pr.state in (2,3,4) and pr.req_date >= trunc(longtodateC(sc.CHANGE_TIME, sub.center)) - 1
 where
 st.ST_TYPE = 1
 and sc.CANCEL_TIME is null
 and sc.OLD_SUBSCRIPTION_CENTER in ($$scope$$)
 and sc.TYPE = 'END_DATE' and sc.CHANGE_TIME >= datetolongC(to_char((to_timestamp(getcentertime(sub.center), 'YYYY-MM-DD HH24:MI:SS') - interval '3' day), 'YYYY-MM-DD HH24:MI'),sub.center)
 and p.CURRENT_PERSON_CENTER = p.CENTER and p.CURRENT_PERSON_ID = p.ID
 and not exists(
 select 1 from SUBSCRIPTIONS os join SUBSCRIPTIONTYPES ost on ost.CENTER = os.SUBSCRIPTIONTYPE_CENTER and ost.ID = os.SUBSCRIPTIONTYPE_ID
 where os.STATE in (2,4,8) and os.OWNER_CENTER = p.CENTER and os.OWNER_ID = p.ID and os.END_DATE is null and (os.center != sub.center or os.id != sub.id) and (ost.ST_TYPE = 0 or os.END_DATE is null)
 )
 and (sub.end_date <= trunc(longtodateC(sc.CHANGE_TIME, sub.center)) or pr.CENTER is null)
UNION ALL
     SELECT 
        NULL AS "EXTERNALID",
        NULL AS "CANCELLATIONSOURCE",
        NULL AS "CANCELLATIONDATE"