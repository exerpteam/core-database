-- The extract is extracted from Exerp on 2026-02-08
-- No of people for each hour in each day for each gym
https://clublead.atlassian.net/browse/ST-4502
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            dateToLongTZ(TO_CHAR(TRUNC(SYSDATE-7),'YYYY-MM-DD') || ' 00:00','Europe/London') from_date
          , dateToLongTZ(TO_CHAR(TRUNC(SYSDATE),'YYYY-MM-DD') || ' 00:00','Europe/London')   to_date
        FROM
            dual
    )
    
SELECT
    c.SHORTNAME     club_name
  , c.ID            club_id
  , to_char(lower_date_time,'YYYY-MM-DD HH24') from_time
  ,to_char(higher_date_time ,'YYYY-MM-DD HH24')  to_time
  ,COUNT(1)         checkins
  ,COUNT(par.PARTICIPANT_ID) AS "TotalInClasses"
FROM
    (
        SELECT
            dateToLongTZ(TO_CHAR(TRUNC(SYSDATE-7),'YYYY-MM-DD') || ' 00:00','Europe/London') + ((level ) * 1000 * 60 * 60)       lower_bound
          , dateToLongTZ(TO_CHAR(TRUNC(SYSDATE-7),'YYYY-MM-DD') || ' 00:00','Europe/London') + ((level +1) * 1000 * 60 * 60) - 1 higher_bound
          , longToDateTZ(dateToLongTZ(TO_CHAR(TRUNC(SYSDATE-7),'YYYY-MM-DD') || ' 00:00','Europe/London') + ((level) * 1000 * 60 * 60),'Europe/London')                                             lower_date_time
          , longToDateTZ(dateToLongTZ(TO_CHAR(TRUNC(SYSDATE-7),'YYYY-MM-DD') || ' 00:00','Europe/London') + ((level + 1) * 1000 * 60 * 60),'Europe/London')                                         higher_date_time
        FROM
            dual CONNECT BY level <= (24 * 7 - 1) ) slots
JOIN
    CHECKINS cin
ON
    (
        cin.CHECKIN_TIME <= slots.higher_bound)
    and (
        cin.CHECKOUT_TIME >= slots.lower_bound)
    
JOIN
    CENTERS c
ON
    c.id = cin.CHECKIN_CENTER
JOIN
    PERSONS p
ON
    p.CENTER = cin.PERSON_CENTER
    AND p.ID = cin.PERSON_ID
    AND p.PERSONTYPE != 2
CROSS JOIN
    params
LEFT JOIN
    PARTICIPATIONS par
ON
  cin.PERSON_CENTER = par.PARTICIPANT_CENTER
  AND cin.PERSON_ID = par.PARTICIPANT_ID
  AND 
  ((par.START_TIME BETWEEN slots.lower_bound AND slots.higher_bound) OR
  (par.STOP_TIME BETWEEN slots.lower_bound AND slots.higher_bound) OR
  (par.START_TIME <= slots.lower_bound  AND  par.STOP_TIME >= slots.higher_bound))
  AND par.STATE <> 'CANCELLED'
WHERE
    cin.CHECKIN_CENTER in ($$scope$$)
    AND cin.CHECKIN_TIME BETWEEN params.from_date AND params.to_date
GROUP BY
    lower_date_time
  ,higher_date_time
  ,c.id
  ,c.SHORTNAME
ORDER BY
	c.ID,
    lower_date_time
  