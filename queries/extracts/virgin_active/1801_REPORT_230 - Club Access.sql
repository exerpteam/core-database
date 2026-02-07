 SELECT
     c.NAME CHECKIN_CLUB,
     SUM(
         CASE
             WHEN cin.CHECKIN_CENTER = cin.CHECKIN_CENTER
             THEN 1
             ELSE 0
         END) AS CHECKINS_CENTER_MEMBERS,
     SUM(
         CASE
             WHEN cin.CHECKIN_CENTER != cin.CHECKIN_CENTER
             THEN 1
             ELSE 0
         END) AS CHECKINS_EXTERNAL_MEMBERS
 FROM
     CENTERS c
 JOIN
     CHECKINS cin
 ON
     cin.CHECKIN_CENTER = c.Id
 WHERE
     cin.CHECKIN_TIME BETWEEN $$fromDate$$ AND $$toDate$$ + (1000*60*60*24)
 GROUP BY
     c.NAME
