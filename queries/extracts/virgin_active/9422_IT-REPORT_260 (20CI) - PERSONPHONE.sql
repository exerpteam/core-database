 SELECT
     p.EXTERNAL_ID "PERSONPHONEID",
     p.EXTERNAL_ID "PERSONID",
     CASE atts.NAME WHEN '_eClub_PhoneHome' THEN 'HOME' WHEN '_eClub_PhoneSMS' THEN 'CELLULAR' WHEN '_eClub_PhoneWork' THEN 'WORK' ELSE 'UNDEFINED' END "PHONETYPE",
     atts.TXTVALUE "PHONENUMBER",
     t1.entryTime AS "LASTSEENDATE"
 FROM
     PERSONS p
 JOIN CENTERS c ON p.CENTER = c.ID AND c.COUNTRY = 'IT'
 JOIN PERSON_EXT_ATTRS atts
 ON
     p.CENTER = atts.PERSONCENTER
     AND p.ID = atts.PERSONID
     AND atts.NAME IN ('_eClub_PhoneHome','_eClub_PhoneSMS','_eClub_PhoneWork')
     AND atts.TXTVALUE IS NOT NULL
 LEFT JOIN
 (
         SELECT
                 p2.CENTER,
                 p2.ID,
                 (CASE
                         WHEN pcl.CHANGE_ATTRIBUTE='HOME_PHONE' THEN '_eClub_PhoneHome'
                         WHEN pcl.CHANGE_ATTRIBUTE='MOB_PHONE' THEN '_eClub_PhoneSMS'
                         WHEN pcl.CHANGE_ATTRIBUTE='WORK_PHONE' THEN '_eClub_PhoneWork'
                 END) AS attribute,
                 longToDateC(MAX(pcl.ENTRY_TIME),p2.center) entryTime
         FROM PERSONS p2
         JOIN CENTERS c ON p2.CENTER = c.ID AND c.COUNTRY = 'IT'
         JOIN PERSON_CHANGE_LOGS pcl ON
                 pcl.PERSON_CENTER = p2.CENTER
                 AND pcl.PERSON_ID = p2.ID
                 AND pcl.PREVIOUS_ENTRY_ID IS NULL
                 AND pcl.CHANGE_ATTRIBUTE IN ('HOME_PHONE','MOB_PHONE','WORK_PHONE')
         WHERE
                 p2.STATUS IN (1,3)
                 AND p2.SEX != 'C'
         GROUP BY
                 p2.CENTER,
                 p2.ID,
                 pcl.CHANGE_ATTRIBUTE
 ) t1 ON (p.CENTER = t1.CENTER AND p.ID = t1.ID AND atts.NAME = t1.attribute)
 WHERE
         p.STATUS IN (1,3)
         AND p.SEX != 'C'
