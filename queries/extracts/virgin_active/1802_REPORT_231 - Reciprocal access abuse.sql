-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
         ch.name home_club,
     PERSON_CENTER || 'p' ||
     PERSON_ID member_id,
     HOME_CENTER_CHECKINS home_club_checkins,
     MAX_CHECKINS away_club_checkins,
     ac.name away_club
 FROM
     (
         SELECT
             CHECKIN_CENTER,
             PERSON_CENTER,
             PERSON_ID,
             CHECKINS,
             MAX(checkins) OVER (PARTITION BY PERSON_CENTER,PERSON_ID)                                                                max_checkins,
             first_value(CHECKIN_CENTER) OVER (PARTITION BY PERSON_CENTER,PERSON_ID ORDER BY checkins DESC)                           max_center,
             first_value(CHECKIN_CENTER) OVER (PARTITION BY PERSON_CENTER,PERSON_ID ORDER BY ABS(CHECKIN_CENTER - PERSON_CENTER) ASC) home_center,
             first_value(checkins) OVER (PARTITION BY PERSON_CENTER,PERSON_ID ORDER BY ABS(CHECKIN_CENTER - PERSON_CENTER) ASC)       home_center_checkins
         FROM
             (
                 SELECT
                     cin.CHECKIN_CENTER,
                     cin.PERSON_CENTER,
                     cin.PERSON_ID,
                     COUNT(cin.ID) checkins
                 FROM
                     CHECKINS cin
                 WHERE
                     cin.PERSON_CENTER in ($$scope$$)
                     and cin.CHECKIN_TIME BETWEEN $$fromDate$$ AND $$toDate$$ + (1000*60*60*24)
                 GROUP BY
                     cin.CHECKIN_CENTER,
                     cin.PERSON_CENTER,
                     cin.PERSON_ID
                 ORDER BY
                     cin.PERSON_CENTER,
                     cin.PERSON_ID )t1 ) t2
 join centers ch on ch.id = PERSON_CENTER
 join centers ac on ac.id = MAX_CENTER
 WHERE
     MAX_CHECKINS > HOME_CENTER_CHECKINS
     AND MAX_CENTER = CHECKIN_CENTER
