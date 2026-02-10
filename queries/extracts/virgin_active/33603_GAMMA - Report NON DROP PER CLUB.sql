-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
 NUMEROABBONAMENTO,
 NOME,
 COGNOME,
 ETA,
 PRODOTTO,
 "PREZZO ABBONAMENTO",
 "DATA INIZIO ABBONAMENTO",
 "DATA FINE ABBONAMENTO",
 STATE,
 SUB_STATE,
 INGRESSI,
  "ULTIMO INGRESSO",
  "ID EXERP SOCIO",
  EMAIL,
  TELEFONO,
  CELLULARE,
  COALESCE(SUM(INSOLUTO),0) AS INSOLUTO,
 MC,
         TITOLARE,
   "ID EXERP TITOòLARE" FROM(
   SELECT
 DISTINCT
 cc.center, cc.id,
 concat(concat(cast(s.center as varchar(4)),'ss'),cast(s.ID as varchar(6))) as NUMEROABBONAMENTO,
 p.FIRSTNAME AS NOME,
 P.LASTNAME AS COGNOME,
  FLOOR((TRUNC(CURRENT_TIMESTAMP) - P.BIRTHDATE) /365.242199) AS ETA,
   PR.NAME AS PRODOTTO,
   S.SUBSCRIPTION_PRICE AS "PREZZO ABBONAMENTO",
  S.START_DATE AS "DATA INIZIO ABBONAMENTO",
  S.BINDING_END_DATE AS "DATA FINE ABBONAMENTO",
 CASE  s.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS STATE,
 CASE  s.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' ELSE 'UNKNOWN' END AS SUB_STATE,
  CASE WHEN CK.ID IS NULL THEN NULL ELSE CK.CHECKINS END AS INGRESSI,
   CASE WHEN CK.ID IS NULL THEN NULL ELSE CK.LAST_CHECKIN END AS "ULTIMO INGRESSO",
  concat(concat(cast(P.CENTER as char(3)),'p'), cast(P.ID as varchar(10))) as "ID EXERP SOCIO",
 email.TXTVALUE as EMAIL,
 home.TXTVALUE as TELEFONO,
 mobile.TXTVALUE as CELLULARE,
  case when op.ID IS NOT NULL THEN cc2.AMOUNT ELSE cc.AMOUNT END AS INSOLUTO,
   CASE
                 WHEN salesPersonOverride.CENTER IS NOT NULL
                     AND (salesPersonOverride.CENTER <> salesperson.CENTER
                         OR salesPersonOverride.ID <> salesperson.ID)
                 THEN salesPersonOverride.FULLNAME
                 ELSE salesperson.FULLNAME
             END MC,
                         payer.FULLNAME as TITOLARE,
                          concat(concat(cast(Payer.CENTER as char(3)),'p'), cast(Payer.ID as varchar(10))) as "ID EXERP TITOòLARE"
 FROM SUBSCRIPTIONS S
 LEFT JOIN
     INVOICELINES invl
 ON
     invl.CENTER = s.INVOICELINE_CENTER
     AND invl.ID = s.INVOICELINE_ID
         AND invl.SUBID = s.INVOICELINE_SUBID
 LEFT JOIN
     INVOICES inv
 ON
     inv.CENTER = invl.CENTER
     AND inv.ID = INVL.id
  LEFT JOIN
             PERSON_EXT_ATTRS email
         ON
             s.owner_center = email.PERSONCENTER
             AND s.owner_id = email.PERSONID
             AND email.name = '_eClub_Email'
 LEFT JOIN
             PERSON_EXT_ATTRS home
         ON
             s.owner_center = home.PERSONCENTER
             AND s.owner_id = home.PERSONID
             AND home.name = '_eClub_PhoneHome'
         LEFT JOIN
             PERSON_EXT_ATTRS mobile
         ON
             s.owner_center = mobile.PERSONCENTER
             AND s.owner_id = mobile.PERSONID
             AND mobile.name = '_eClub_PhoneSMS'
 LEFT JOIN PERSONS Payer
 ON inv.PAYER_CENTER =  payer.CENTER
 AND inv.PAYER_ID = payer.ID
 LEFT JOIN SUBSCRIPTION_SALES SS
 on S.ID = SS.SUBSCRIPTION_ID AND S.CENTER = SS.SUBSCRIPTION_CENTER
 LEFT JOIN
             EMPLOYEES emp
         ON
             ss.EMPLOYEE_CENTER = emp.CENTER
             AND ss.EMPLOYEE_ID = emp.ID
 LEFT JOIN
             PERSONS salesperson
         ON
             salesperson.CENTER = emp.PERSONCENTER
             AND salesperson.ID = emp.PERSONID
         LEFT JOIN
             PERSON_EXT_ATTRS salesPersonOverrideExt
         ON
             s.owner_center = salesPersonOverrideExt.PERSONCENTER
             AND s.owner_id = salesPersonOverrideExt.PERSONID
             AND salesPersonOverrideExt.name = 'MC_IT'
         LEFT JOIN
             PERSONS salesPersonOverride
         ON
             salesPersonOverride.CENTER || 'p' || salesPersonOverride.ID = salesPersonOverrideExt.TXTVALUE
 LEFT JOIN PERSONS P ON P.CENTER = S.OWNER_CENTER  AND P.ID = S.OWNER_ID
 LEFT JOIN
     RELATIVES rel
 ON
     rel.RTYPE = 12
     AND rel.STATUS = 1
     AND rel.RELATIVECENTER = p.CENTER
     AND rel.RELATIVEID = p.ID
 LEFT JOIN
     PERSONS op
 ON
     op.CENTER = rel.CENTER
     AND op.ID = rel.ID
 LEFT JOIN PRODUCTS PR ON PR.CENTER = S.SUBSCRIPTIONTYPE_CENTER AND PR.ID = S.SUBSCRIPTIONTYPE_ID
 LEFT  JOIN
 PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
 on pr.CENTER  = ppgl.product_center
 and pr.id = ppgl.product_id
 LEFT JOIN
     CASHCOLLECTIONCASES
  cc
 ON
     cc.PERSONCENTER = p.CENTER
     AND cc.PERSONID = p.id
         AND cc.MISSINGPAYMENT = 1 AND cc.CLOSED = 0
 LEFT JOIN
     CASHCOLLECTIONCASES cc2
 ON
     cc2.PERSONCENTER = op.CENTER
     AND cc2.PERSONID = op.ID
     AND cc2.CLOSED = 0
     AND cc2.MISSINGPAYMENT = 1
 LEFT OUTER JOIN
 (
 SELECT COUNT(*) AS CHECKINS, MAX(CHECKIN_TIME) AS LAST_CHECKIN,
 CENTER, ID
 FROM(
 SELECT
  P.ID, P.CENTER,  LONGTODATE(CHECKIN_TIME) AS CHECKIN_TIME
 FROM
 persons p
 INNER JOIN
  subscriptions s
 ON S.OWNER_CENTER = P.CENTER AND S.OWNER_ID = P.ID
 INNER JOIN
 CHECKINS C
 ON P.ID = C.PERSON_ID AND P.CENTER = C.PERSON_CENTER
 AND LONGTODATE(C.CHECKIN_TIME) >= S.START_DATE AND
  LONGTODATE(C.CHECKIN_TIME) <= S.BINDING_END_DATE
 where
 P.CENTER IN( $$club$$)
 AND S.BINDING_END_DATE >= $$End_Date_From$$ AND S.BINDING_END_DATE <= $$End_Date_To$$
 AND S.END_DATE IS NULL
 --AND S.SUB_STATE IN(1,9)
 and CHECKIN_RESULT = 1
 GROUP BY P.ID, P.CENTER, LONGTODATE(CHECKIN_TIME)) P
 GROUP  BY CENTER, ID
 ) CK
 ON P.CENTER = CK.CENTER AND P.ID = CK.ID
 --AND ppgl.PRODUCT_GROUP_ID  = 7601
 WHERE P.CENTER IN($$club$$) AND S.BINDING_END_DATE >= $$End_Date_From$$ AND S.BINDING_END_DATE <= $$End_Date_To$$
 AND S.SUB_STATE IN(1,9)
 AND (pr.NAME LIKE 'Open%'
  OR ppgl.PRODUCT_GROUP_ID  IN(7601,5409)
 OR pr.NAME LIKE 'Corporate%'
  OR pr.NAME LIKE 'DT%'
  OR pr.NAME LIKE 'Partnership%'
  OR pr.NAME LIKE 'Senior%'
  OR pr.NAME LIKE 'Young%'
   OR pr.NAME LIKE 'Flexi%'
    OR pr.NAME LIKE 'Active%'
         OR pr.NAME LIKE 'Staff Friends%'
         OR pr.NAME LIKE 'Staff Friends Cash%'
 )
 AND S.END_DATE IS NULL
 AND (( Extract(month from S.BINDING_END_DATE) = Extract(month FROM CURRENT_DATE)
 AND Extract(year from S.BINDING_END_DATE)::integer = Extract(year FROM CURRENT_DATE)::integer) or ((Extract(month from S.BINDING_END_DATE)::integer != Extract(month FROM CURRENT_DATE)::integer OR   Extract(year from S.BINDING_END_DATE)::integer! = Extract(year FROM CURRENT_DATE)::integer)) AND p.STATUS NOT IN(1,3,4))) p -- updated
 GROUP BY
 NUMEROABBONAMENTO,
 NOME,
 COGNOME,
 ETA,
 PRODOTTO,
 "PREZZO ABBONAMENTO",
 "DATA INIZIO ABBONAMENTO",
 "DATA FINE ABBONAMENTO",
 STATE,
 SUB_STATE,
 INGRESSI,
  "ULTIMO INGRESSO",
  "ID EXERP SOCIO",
  EMAIL,
  TELEFONO,
  CELLULARE,
   "ID EXERP TITOòLARE",
  MC,
 TITOLARE
