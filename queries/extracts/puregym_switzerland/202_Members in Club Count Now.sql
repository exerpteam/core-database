-- The extract is extracted from Exerp on 2026-02-08
-- Number of members in a club right now
 WITH
    tmp AS 
    (
      -- this temporary variable is created to fake the Exerp Extract editor (/*) is treated as comment line
      SELECT '/WEEKLY/'||'*' as fake_weekly, 'name(/'||'*)' as fake_name, './/'||'*/@TO' as fake_to, './/'||'*/@FROM' as fake_from
    ),
    dayOfWeek AS
    (
         SELECT
             TRIM(TO_CHAR(TO_DATE(getcentertime(100),'YYYY-MM-DD HH24:MI'),'day'))   AS DOW,
             TO_TIMESTAMP(getcentertime(100),'YYYY-MM-DD HH24:MI')                        AS TODAY,
             TO_CHAR(TO_DATE(getcentertime(100),'YYYY-MM-DD HH24:MI'), 'YYYY-MM-DD') AS TODAY_DATE_CHAR 
    )     
 SELECT
     t1.CHECKIN_CENTER,
     CASE GROUPING(t1.club) WHEN 1 THEN 'Total' ELSE t1.club END AS Club,
     SUM(t1."Member count")                      AS "Member Count",
     SUM(t1."TotalInClasses")                    AS "Total In Classes"
 FROM
     (
         SELECT
             c.CHECKIN_CENTER,
             CASE GROUPING(CE.NAME) WHEN 1 THEN 'Total' ELSE ce.name END AS Club,
             COUNT(c.PERSON_CENTER||'p'||c.PERSON_ID)    AS "Member count",
             COUNT(par.PARTICIPANT_ID)                   AS "TotalInClasses"
         FROM
		     CENTERS ce
			 CROSS JOIN
             (
                 SELECT
                     CAST(DATETOLONGC(getcentertime(100),100) AS BIGINT)     AS currentTime,
                     date_trunc('day', TO_DATE(getcentertime(100),'YYYY-MM-DD HH24:MI')) AS currentDate,
                     CAST(300*60*1000 AS BIGINT)                             AS MaxDuration
                  ) params
             JOIN
             CHECKINS c
             ON
             ce.id = c.CHECKIN_CENTER
         LEFT JOIN
             PARTICIPATIONS par
         ON
             c.PERSON_CENTER = par.PARTICIPANT_CENTER
             AND c.PERSON_ID = par.PARTICIPANT_ID
             AND par.START_TIME <= PARAMS.currentTime
             AND par.STOP_TIME >= PARAMS.currentTime
             AND par.STATE <> 'CANCELLED'
         WHERE
             ce.ID IN ( :scope )
             AND ce.STARTUPDATE < PARAMS.currentDate
             AND
             -- checkin less than maxduration before the report time
             c.CHECKIN_TIME BETWEEN (PARAMS.currentTime - PARAMS.MaxDuration) AND PARAMS.currentTime
             AND (
                 c.CHECKOUT_TIME IS NULL
                 OR c.CHECKOUT_TIME > PARAMS.currentTime)
             AND CHECKIN_RESULT !=0
         GROUP BY
             c.CHECKIN_CENTER,
             ce.name ) t1
 CROSS JOIN
     dayOfWeek
 LEFT JOIN
     (     
WITH topscope AS
(
SELECT
    s.ID, s.GLOBALID, s.SCOPE_TYPE, s.SCOPE_ID, s.CLIENT, s.TXTVALUE, s.MIMETYPE, s.LINK_TYPE, s.LINK_ID,
    CAST((xpath(tmp.fake_from, xml_element))[1] AS VARCHAR(10)) AS "FROM_TIME",
    CAST((xpath(tmp.fake_to,xml_element))[1] AS VARCHAR(50))    AS "TO_TIME"
FROM
    SYSTEMPROPERTIES s, tmp,
    unnest(xpath('//SIMPLETIMEINTERVAL',xmlparse(document convert_from(MIMEVALUE, 'UTF-8')))) AS xml_element
WHERE
    s.GLOBALID = 'CenterOpeningHours'
    AND s.TXTVALUE = 'dk.procard.eclub.time.schedule.DailySchedule'
    AND s.SCOPE_TYPE = 'T'      
)
SELECT
   c.ID,
   oh.TXTVALUE,
(
 CASE
     WHEN oh.ID IS NULL
     THEN topscope."FROM_TIME"
     ELSE oh."FROM_TIME"
 END) AS FROM_TIME,
(
 CASE
     WHEN oh.ID IS NULL
     THEN topscope."TO_TIME"
     ELSE oh."TO_TIME"
 END) AS TO_TIME,
oh.DAY_OF_WEEK
FROM
   CENTERS c
CROSS JOIN
   topscope
LEFT JOIN
(
SELECT
    s.ID, s.GLOBALID, s.SCOPE_TYPE, s.SCOPE_ID, s.CLIENT, s.TXTVALUE, s.MIMETYPE, s.LINK_TYPE, s.LINK_ID,
    CAST((xpath(tmp.fake_from, xml_element))[1] AS VARCHAR(10)) AS "FROM_TIME",
    CAST((xpath(tmp.fake_to,xml_element))[1] AS VARCHAR(50))    AS "TO_TIME",
    NULL           AS DAY_OF_WEEK
FROM
    SYSTEMPROPERTIES s, tmp,
    unnest(xpath('//BUSINESS/SIMPLETIMEINTERVAL',xmlparse(document convert_from(MIMEVALUE, 'UTF-8')))) AS xml_element
WHERE
    s.GLOBALID = 'CenterOpeningHours'
    AND s.TXTVALUE = 'dk.procard.eclub.time.schedule.BusinessSchedule'
UNION ALL
SELECT
    s.ID, s.GLOBALID, s.SCOPE_TYPE, s.SCOPE_ID, s.CLIENT, s.TXTVALUE, s.MIMETYPE, s.LINK_TYPE, s.LINK_ID,
    CAST((xpath(tmp.fake_from, xml_element))[1] AS VARCHAR(10)) AS "FROM_TIME",
    CAST((xpath(tmp.fake_to,xml_element))[1] AS VARCHAR(50))    AS "TO_TIME",
    NULL           AS DAY_OF_WEEK
FROM
    SYSTEMPROPERTIES s, tmp,
    unnest(xpath('//SIMPLETIMEINTERVAL',xmlparse(document convert_from(MIMEVALUE, 'UTF-8')))) AS xml_element
WHERE
    s.GLOBALID = 'CenterOpeningHours'
    AND s.TXTVALUE = 'dk.procard.eclub.time.schedule.DailySchedule'
UNION ALL
SELECT
    s.ID, s.GLOBALID, s.SCOPE_TYPE, s.SCOPE_ID, s.CLIENT, s.TXTVALUE, s.MIMETYPE, s.LINK_TYPE, s.LINK_ID,
    CAST((xpath(tmp.fake_from, xml_element))[1] AS VARCHAR(10)) AS "FROM_TIME",
    CAST((xpath(tmp.fake_to,xml_element))[1] AS VARCHAR(50))    AS "TO_TIME",
    CAST((xpath(tmp.fake_name, xml_element))[1] AS VARCHAR(255))  AS DAY_OF_WEEK
FROM
    SYSTEMPROPERTIES s,
    tmp,
    unnest(xpath(tmp.fake_weekly ,xmlparse(document convert_from(MIMEVALUE, 'UTF-8'))))  AS xml_element 
WHERE
    s.GLOBALID = 'CenterOpeningHours'
AND s.TXTVALUE = 'dk.procard.eclub.time.schedule.WeeklySchedule'
AND s.MIMETYPE = 'text/xml' 
) oh
ON
   oh.SCOPE_TYPE = 'C'
   AND c.ID = oh.SCOPE_ID  ) t2
ON
     t1.CHECKIN_CENTER = t2.ID
WHERE
     (
         t2.TXTVALUE IS NULL
         OR t2.TXTVALUE != 'dk.procard.eclub.time.schedule.WeeklySchedule'
         OR (
             t2.TXTVALUE = 'dk.procard.eclub.time.schedule.WeeklySchedule'
             AND t2.DAY_OF_WEEK = dayOfWeek.DOW ) )
     AND (
         TO_TIMESTAMP(dayOfWeek.TODAY_DATE_CHAR || ' ' ||t2.FROM_TIME,'YYYY-MM-DD HH24:MI') < dayOfWeek.TODAY
         AND TO_TIMESTAMP(dayOfWeek.TODAY_DATE_CHAR || ' ' ||t2.TO_TIME,'YYYY-MM-DD HH24:MI') > dayOfWeek.TODAY )
 GROUP BY
     rollup( (t1.CHECKIN_CENTER, t1.club))
 ORDER BY
     t1.club