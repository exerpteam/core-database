-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
old_checkin AS
(
SELECT   checkins.checkin_center
       , to_char(longtodateTZ(checkins.checkin_time, 'Europe/London'), 'YYYY-MM-DD') checkin_date
       , count(distinct person_center||'p'||person_id) old_kpi_unique_checkins_pers
       , count(1) old_all_checkins_persons
  FROM puregym.checkins
 WHERE checkins.checkin_time >= $$startdate$$
   AND checkins.checkin_time < $$enddate$$ + 86400 * 1000        
   AND checkins.checkin_center = $$center$$
GROUP BY checkins.checkin_center
       , to_char(longtodateTZ(checkins.checkin_time, 'Europe/London'), 'YYYY-MM-DD') 
)
, rebuilt_checkin as
(
SELECT   checkins.checkin_center
       , to_char(longtodateTZ(checkins.checkin_time, 'Europe/London'), 'YYYY-MM-DD') checkin_date 
       , count(distinct person_center||'p'||person_id) new_kpi_unique_checkins_pers
       , count(1) new_all_checkins_persons
       , SUM(CASE WHEN state_change_log.stateid  = 2
                  OR state_change_log.stateid  IS NULL AND persons.PERSONTYPE !=2 
                THEN 1
                ELSE 0
             END) AS new_all_checkins_members
       , SUM(CASE WHEN state_change_log.stateid  = 1
                  OR state_change_log.stateid  IS NULL AND persons.PERSONTYPE =2 
                THEN 1
                ELSE 0
             END) AS new_all_checkins_non_members
       , SUM(CASE WHEN state_change_log.stateid  = 4
                THEN 1
                ELSE 0
             END) AS new_all_checkins_extras          
  FROM puregym.checkins_1 checkins
    LEFT JOIN puregym.state_change_log 
           ON checkins.person_center = state_change_log.center
          AND checkins.person_id = state_change_log.id
          AND state_change_log.entry_type = 5                  
          AND checkins.checkin_time between state_change_log.entry_start_time and nvl(state_change_log.entry_end_time, checkins.checkin_time)
    LEFT JOIN puregym.persons
           ON persons.center = checkins.person_center
          AND persons.id = checkins.person_id           
  WHERE checkins.checkin_time >= $$startdate$$
    AND checkins.checkin_time < $$enddate$$ + 86400 * 1000           
    AND checkins.checkin_center = $$center$$
GROUP BY checkins.checkin_center
       , to_char(longtodateTZ(checkins.checkin_time, 'Europe/London'), 'YYYY-MM-DD') 
)
SELECT old_checkin.checkin_center
     , centers.name club_name
     , old_checkin.checkin_date
     , old_checkin.OLD_KPI_UNIQUE_CHECKINS_PERS
     , old_checkin.OLD_ALL_CHECKINS_PERSONS
     , rebuilt_checkin.new_kpi_unique_checkins_pers
     , rebuilt_checkin.new_all_checkins_persons
     , rebuilt_checkin.new_all_checkins_members
     , rebuilt_checkin.new_all_checkins_non_members
     , rebuilt_checkin.new_all_checkins_extras
  FROM old_checkin
    JOIN rebuilt_checkin
      ON old_checkin.checkin_center = rebuilt_checkin.checkin_center
     AND old_checkin.checkin_date = rebuilt_checkin.checkin_date
    JOIN puregym.centers
      ON centers.id = old_checkin.checkin_center  
  ORDER BY old_checkin.checkin_center, old_checkin.checkin_date