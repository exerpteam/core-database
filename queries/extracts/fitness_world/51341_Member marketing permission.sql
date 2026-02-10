-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-6505
SELECT
   actives.member_count          AS "Active Memberships",
   a.NAME		         		 AS "Region", 
   c.SHORTNAME	                 AS "Center", 
   total_checkins.total_count    AS "Total check-ins",
   unique_checkins.total_count   AS "Unique check-ins",
   acceptnews.total              AS "Accepting news letter",
   accept_old_new.new_count      AS "New members accepting",
   accept_old_new.old_count      AS "Old members accepting",
   ROUND(unique_checkins.total_count/total_checkins.total_count,2)*100||'%' AS "Percent unique accepting",
   ROUND(acceptnews.total/actives.member_count,2)*100||'%' AS "Percent total accepting",
   ROUND(accept_old_new.old_count/actives.member_count,2)*100||'%' AS "Percent old accepting"
FROM
   CENTERS c
JOIN
   AREAS a
ON
   a.ROOT_AREA = 69   
JOIN
   AREA_CENTERS ac
ON
   ac.CENTER = c.ID
   AND ac.AREA = a.ID
LEFT JOIN
   (
   SELECT 
      p.CENTER, count(*) member_count 
   FROM	
      PERSONS p
   JOIN
      SUBSCRIPTIONS s
   ON
      p.CENTER = s.OWNER_CENTER
      AND p.id = s.OWNER_ID
   WHERE    
      s.STATE IN (2,4,8)
   GROUP BY p.CENTER
   ) actives
ON
   actives.CENTER = c.ID
LEFT JOIN
   (SELECT ch.PERSON_CENTER, COUNT(*) total_count
    FROM checkins ch
    WHERE ch.CHECKIN_RESULT <> 3 --accessDenied
    AND ch.CHECKIN_TIME >= :Date_From
    AND ch.CHECKIN_TIME <  :Date_To + 24*3600*1000
    GROUP BY ch.PERSON_CENTER
    ) total_checkins
ON
   total_checkins.PERSON_CENTER = c.ID
LEFT JOIN
   (SELECT ch.PERSON_CENTER, COUNT(DISTINCT ch.PERSON_CENTER||'p'||ch.PERSON_ID)  total_count
    FROM checkins ch
    WHERE ch.CHECKIN_RESULT <> 3 --accessDenied
    AND ch.CHECKIN_TIME >= :Date_From
    AND ch.CHECKIN_TIME <  :Date_To + 24*3600*1000
    GROUP BY ch.PERSON_CENTER
    ) unique_checkins
ON
   unique_checkins.PERSON_CENTER = C.ID
LEFT JOIN
   (SELECT p.CENTER, COUNT(*) total
    FROM
        PERSONS p
     JOIN
        SUBSCRIPTIONS s
     ON
        p.CENTER = s.OWNER_CENTER
        AND p.id = s.OWNER_ID
        AND s.STATE IN (2,4,8)
    JOIN
        PERSON_EXT_ATTRS pea
    ON
        p.CENTER = pea.PERSONCENTER
        AND p.ID = pea.PERSONID
    WHERE
        pea.NAME = 'eClubIsAcceptingEmailNewsLetters'
        AND pea.TXTVALUE = 'true'
    GROUP BY p.CENTER
) acceptnews
ON
  acceptnews.CENTER = c.ID
LEFT JOIN
   (
   SELECT 
     Center,
     NVL(SUM(old_one),0) old_count,
     NVL(SUM(new_one),0) new_count
   FROM
   (
   WITH
      PARAMS AS 
   (SELECT 
     datetolongTZ(TO_CHAR(trunc(add_months(exerpsysdate(),-1), 'MONTH'), 'YYYY-MM-DD HH24:MI'),'Europe/Copenhagen') AS last30days  
   FROM dual
   )
   SELECT 
        p.CENTER, 
        CASE WHEN s.CREATION_TIME < PARAMS.last30days THEN 1 END  old_one, 
        CASE WHEN s.CREATION_TIME >= PARAMS.last30days THEN 1 END  new_one
    FROM
        PARAMS,        
        PERSONS p
    JOIN
        SUBSCRIPTIONS s
    ON
        p.CENTER = s.OWNER_CENTER
        AND p.id = s.OWNER_ID
        AND s.STATE IN (2,4,8)
    JOIN
        PERSON_EXT_ATTRS pea
    ON
        p.CENTER = pea.PERSONCENTER
        AND p.ID = pea.PERSONID
    WHERE
        pea.NAME = 'eClubIsAcceptingEmailNewsLetters'
        AND pea.TXTVALUE = 'true'
    )    
    GROUP BY CENTER
) accept_old_new
ON
  accept_old_new.CENTER = c.ID

WHERE
   c.ID in (:Scope)
GROUP BY 
   a.NAME, 
   c.SHORTNAME, 
   actives.member_count,
   total_checkins.total_count, 
   unique_checkins.total_count, 
   acceptnews.total, 
   accept_old_new.new_count, 
   accept_old_new.old_count






