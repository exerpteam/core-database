 SELECT
     p.center||'p'||p.id       AS "Person ID",
         CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'    WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'      WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS STATUS,
     DatiSensibili.TXTVALUE    AS "consenso dati appartenenti",
     Marketing.TXTVALUE        AS "consenso marketing",
     Profilazione.TXTVALUE     AS "consenso profilazione",
     Immagine.TXTVALUE         AS "consenso immagine",
     Biometrico.TXTVALUE       AS "consenso dato biometrico",
     MARKETINGVAI.TXTVALUE     AS "consenso soft optin"
 FROM
     PERSONS p
 JOIN
     CENTERS cn
 ON
     cn.ID = p.CENTER
         AND cn.Country = 'IT'
 LEFT JOIN
     PERSON_EXT_ATTRS Biometrico
 ON
     p.center=Biometrico.PERSONCENTER
     AND p.id=Biometrico.PERSONID
     AND Biometrico.name = 'BIOMETRICO'
 LEFT JOIN
     PERSON_EXT_ATTRS DatiSensibili
 ON
     p.center=DatiSensibili.PERSONCENTER
     AND p.id=DatiSensibili.PERSONID
     AND DatiSensibili.name = 'DATISENSIBILI'
 LEFT JOIN
     PERSON_EXT_ATTRS Immagine
 ON
     p.center=Immagine.PERSONCENTER
     AND p.id=Immagine.PERSONID
     AND Immagine.name = 'IMMAGINE'
 LEFT JOIN
     PERSON_EXT_ATTRS Marketing
 ON
     p.center=Marketing.PERSONCENTER
     AND p.id=Marketing.PERSONID
     AND Marketing.name = 'MARKETING'
 LEFT JOIN
     PERSON_EXT_ATTRS Profilazione
 ON
     p.center=Profilazione.PERSONCENTER
     AND p.id=Profilazione.PERSONID
     AND Profilazione.name = 'PROFILAZIONE'
 LEFT JOIN
     PERSON_EXT_ATTRS MARKETINGVAI
 ON
     p.center = MARKETINGVAI.PERSONCENTER
     AND p.id = MARKETINGVAI.PERSONID
     AND MARKETINGVAI.name = 'MARKETINGVAI'
 WHERE
     (Biometrico.TXTVALUE IS NOT null OR DatiSensibili.TXTVALUE IS NOT null OR
     Immagine.TXTVALUE IS NOT null OR Marketing.TXTVALUE IS NOT null OR Profilazione.TXTVALUE IS NOT null)
         AND p.center IN ($$scope$$)
         AND p.STATUS IN ($$status$$)
