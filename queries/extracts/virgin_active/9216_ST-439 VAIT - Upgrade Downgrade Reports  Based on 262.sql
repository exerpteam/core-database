-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT DISTINCT
     c.NAME                  club,
     p.CENTER || 'p' || p.id pid,
     p.FULLNAME "NOME_COGNOME",
     p.ZIPCODE                         "CODICE POSTALE",
     longToDate(scl.ENTRY_START_TIME) MODIFICA,
     pemp.FULLNAME PERSONALE,
     CASE
         WHEN scl.SUB_STATE = 5
         THEN 'Extended'
         WHEN scl.SUB_STATE = 4
         THEN 'Downgrade'
         WHEN scl.SUB_STATE = 4
         THEN 'Upgrade'
         WHEN st2.RANK > st.RANK
         THEN 'Upgrade'
         WHEN st2.RANK < st.RANK
         THEN 'Downgrade'
         ELSE 'RANK MISSING OR SAME RANK'
     END                        GENERE,
     s.CENTER || 'ss' || s.ID   "PRECEDENTE NUMERO SOCIO",
     prod.NAME                  "PRECEDENTE NOME ABBONAMENTO",
     s2.CENTER || 'ss' || s2.ID "NUOVO NUMERO SOCIO",
     prod2.NAME                 "NUOVO NOME ABBONAMENTO"
 FROM
     STATE_CHANGE_LOG scl
 left join EMPLOYEES emp on emp.CENTER = scl.EMPLOYEE_CENTER and emp.ID = scl.EMPLOYEE_ID
 left join PERSONS pemp on pemp.CENTER = emp.PERSONCENTER and pemp.ID = emp.PERSONID
 JOIN
     SUBSCRIPTIONS s
 ON
     s.CENTER = scl.CENTER
     AND s.id = scl.ID
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND prod.id = s.SUBSCRIPTIONTYPE_ID
 JOIN
     SUBSCRIPTIONTYPES st
 ON
     st.CENTER = prod.CENTER
     AND st.ID = prod.ID
 JOIN
     PERSONS p
 ON
     p.CENTER = s.OWNER_CENTER
     AND p.id = s.OWNER_ID
 JOIN
     CENTERS c
 ON
     c.id = p.CENTER
 JOIN
     SUBSCRIPTIONS s2
 ON
     s2.OWNER_CENTER = p.CENTER
     AND s2.OWNER_ID = p.id
 JOIN
     PRODUCTS prod2
 ON
     prod2.CENTER = s2.SUBSCRIPTIONTYPE_CENTER
     AND prod2.id = s2.SUBSCRIPTIONTYPE_ID
 JOIN
     SUBSCRIPTIONTYPES st2
 ON
     st2.CENTER = prod2.CENTER
     AND st2.ID = prod2.ID
 JOIN
     STATE_CHANGE_LOG scl2
 ON
     scl2.CENTER = s2.CENTER
     AND scl2.ID = s2.id
     AND scl2.ENTRY_TYPE = scl.ENTRY_TYPE
     AND (
         scl2.CENTER,scl2.ID) NOT IN ((scl.CENTER,
                                       scl.ID))
     AND scl2.STATEID IN (8)
 WHERE
     scl.ENTRY_TYPE = 2
     AND scl.STATEID IN (2,4,8)
     AND scl.SUB_STATE IN (5,3,4,1)
     AND s2.START_DATE - s.END_DATE <= 1
     AND s2.START_DATE >= s.END_DATE
     AND p.CENTER in ($$scope$$)
     AND scl2.ENTRY_START_TIME BETWEEN $$fromDate$$ AND $$toDate$$ + (1000*60*60*24)
