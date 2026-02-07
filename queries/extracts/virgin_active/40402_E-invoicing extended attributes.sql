 SELECT
     p.CENTER || 'p' || p.ID AS ID,
     p.FIRSTNAME             AS Nome,
     p.LASTNAME              AS Cognome,
     com.txtvalue            AS Commento,
     pea3.txtvalue           AS Email,
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 
     'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS STATUS,
     pea.txtvalue                                                                     AS FatturaPEC,
     pea2.txtvalue                                                                    AS CodiceDestinatario,
     pea3.txtvalue                                                                    AS Email,
     pea4.txtvalue                                                                    AS Mobile_Number,
     CASE  p.SEX  WHEN 'C' THEN  'COMPANY'  WHEN 'F' THEN  'Female'  WHEN 'M' THEN  'MALE' END                             AS Sex,
     pea5.txtvalue AS CodiceFattura,
         CASE  p.persontype  WHEN 0 THEN 'Private'  WHEN 1 THEN 'Student'  WHEN 2 THEN 'Staff'  WHEN 3 THEN 'Friend'  WHEN 4 THEN 'Corporate'  WHEN 5 THEN 'Onemancorporate'  WHEN 6 THEN 'Family'  WHEN 7 THEN 'Senior'  WHEN 8 THEN 'Guest'  WHEN 9 THEN  'Child'  WHEN 10 THEN  'External_Staff' ELSE 'Unknown' END AS "Person Type",
     s.CENTER || 'ss' || s.ID AS Sub_ID,
     pr.name AS Sub_Name,
 CASE  s.state  WHEN 2 THEN 'Active'  WHEN 3 THEN 'Ended'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'Window'  WHEN 8 THEN 'Created' ELSE 'Unknown' END AS "SUB_STATE",
     CASE  s.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'UNKNOWN' END AS SUB_STATE
 FROM
     PERSONS p
 JOIN
     centers c
 ON
     p.CENTER = c.ID
 AND c.COUNTRY = 'IT'
 JOIN
     PERSON_EXT_ATTRS com
 ON
     com.PERSONCENTER = p.CENTER
 AND com.PERSONID = p.ID
 AND com.NAME = '_eClub_Comment'
 AND com.txtvalue IS NOT NULL
 AND com.txtvalue != ' '
 LEFT JOIN
     PERSON_EXT_ATTRS pea
 ON
     pea.PERSONCENTER = p.CENTER
 AND pea.PERSONID = p.ID
 AND pea.NAME = 'FatturaPEC'
 LEFT JOIN
     PERSON_EXT_ATTRS pea2
 ON
     pea2.PERSONCENTER = p.CENTER
 AND pea2.PERSONID = p.ID
 AND pea2.NAME = 'CodiceDestinatario'
 LEFT JOIN
     PERSON_EXT_ATTRS pea3
 ON
     pea3.PERSONCENTER = p.CENTER
 AND pea3.PERSONID = p.ID
 AND pea3.NAME = '_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS pea4
 ON
     pea4.PERSONCENTER = p.CENTER
 AND pea4.PERSONID = p.ID
 AND pea4.NAME='_eClub_PhoneSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS pea5
 ON
     pea5.PERSONCENTER = p.CENTER
 AND pea5.PERSONID = p.ID
 AND pea5.NAME='CodiceFattura'
 LEFT JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.CENTER
 AND s.OWNER_ID = p.ID
 AND s.STATE = 2
 LEFT JOIN
            PRODUCTS pr
        ON
            pr.center = s.SUBSCRIPTIONTYPE_CENTER
            AND pr.id = s.SUBSCRIPTIONTYPE_ID
 WHERE
         p.CENTER IN ($$Scope$$)
