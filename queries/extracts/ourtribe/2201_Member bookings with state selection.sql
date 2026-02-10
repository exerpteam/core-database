-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
params AS
        (
        SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate         
        FROM
          centers c)

Select
TO_CHAR(longtodateC(part.start_time,part.center), 'dd-mm-yyyy') AS "Date"
,TO_CHAR(longtodateC(part.start_time,part.center), 'HH24:MI') AS "Time"
,p.external_id "Memberid"
,p.fullname as "Name"
,b.name
,part.state as "State"
,part.cancelation_reason as "Substate"

from
participations part
join
persons p
on
p.center = part.participant_center
and
p.id = part.participant_id
join
bookings b
on
part.booking_center = b.center
and
part.booking_id = b.id
join
params
on
params.center_id = p.center
and
part.start_time BETWEEN params.FromDate AND params.ToDate 
and
part.state in (:State)
and
p.center IN (:Scope)