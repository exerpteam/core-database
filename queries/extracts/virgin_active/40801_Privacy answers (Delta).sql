 WITH
     any_club_in_scope AS
     (
         SELECT id
           FROM centers
          WHERE country = 'IT'
            LIMIT 1
     ),
     params AS
     (
         SELECT
             /*+ materialize */
             datetolongC(TO_CHAR(trunc(current_timestamp-1),'YYYY-MM-DD HH24:MI'), any_club_in_scope.id)  AS FROMDATE
         FROM  any_club_in_scope
     )
 SELECT
     p.center||'p'||p.id       AS "Person ID",
     DatiSensibili.TXTVALUE    AS "consenso dati appartenenti",
     Marketing.TXTVALUE        AS "consenso marketing",
     Profilazione.TXTVALUE     AS "consenso profilazione",
     Immagine.TXTVALUE         AS "consenso immagine",
     Biometrico.TXTVALUE       AS "consenso dato biometrico"
 FROM
     PERSONS p
 CROSS JOIN
     params
 JOIN
     CENTERS cn
 ON
     cn.ID = p.CENTER
         AND cn.country = 'IT'
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
 WHERE
     (DatiSensibili.LAST_EDIT_TIME >= params.FromDate  OR
     Marketing.LAST_EDIT_TIME >= params.FromDate  OR
     Profilazione.LAST_EDIT_TIME >= params.FromDate  OR
     Immagine.LAST_EDIT_TIME >= params.FromDate  OR
     Biometrico.LAST_EDIT_TIME >= params.FromDate)
