WITH
    params AS materialized
    (
        SELECT
            name AS center,
            id   AS CENTER_ID,
            CAST(datetolongTZ(TO_CHAR(to_date($$DateFrom$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ), time_zone) AS BIGINT) AS from_date,
            CAST(datetolongTZ(TO_CHAR(to_date($$DateTo$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ), time_zone) AS BIGINT) + (24*60*60*1000) AS to_date
        FROM
            centers 
        WHERE
            id IN ($$Scope$$)
    )
, 
sub_attends AS (
SELECT 
  longtodatec(a.start_time, a.center) as start_datetime,
  TO_CHAR(longtodateC(a.start_time, a.center),'MM/DD/YYYY') as attend_date,
  TO_CHAR(longtodateC(a.start_time, a.center),'HH24:MI') as attend_time,
  params.center as club_name,
  a.start_time,
  a.person_center,
  a.person_id,
  a.booking_resource_center,
  a.booking_resource_id 
FROM
    attends a
JOIN
    params
ON
    params.center_id = a.center
    AND a.start_time >= params.from_date 
    AND a.start_time < params.to_date
)    
SELECT
  p.fullname AS  "Member Name",
  p.center||'p'||p.id                                           AS "System ID",
  a.attend_date    AS "Date",
  a.attend_time     AS "Time in",
  br.name                                                       AS "Access Point",
  pr.name                                                       AS "Subscription at the checkin time",
  a.club_name AS "Club"
FROM
    sub_attends a
JOIN
    persons p
ON
    a.person_center = p.center
    AND a.person_id = p.id       
LEFT JOIN
    booking_resources br
ON
    a.booking_resource_center = br.center
    AND a.booking_resource_id = br.id         
LEFT JOIN
    subscriptions s
ON
    s.owner_center = p.center
    AND s.owner_id = p.id
    AND s.start_date <= a.start_datetime
    AND (s.end_date is null OR s.end_date >= a.start_datetime)    
LEFT JOIN
   products pr 
ON
   s.subscriptiontype_center = pr.center
   AND s.subscriptiontype_id = pr.id            

