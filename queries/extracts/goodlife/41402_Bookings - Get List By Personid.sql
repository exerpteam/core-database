-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT

TO_CHAR(LONGTODATEC(b.starttime,b.center),'YYYY-MM-DD HH24:MI:SS')  AS "Start Time (Local)"
,b.name AS "Booking Name"
,a.name AS "Activity Name"
,b.center||'book'||b.id AS Booking_ID
,b.state
,par.participant_center||'p'||par.participant_id AS "Member Person ID"
,p.fullname AS "Member Name"

,CASE
    WHEN par.user_interface_type = 0
    THEN 'System'
    WHEN par.user_interface_type = 1
    THEN 'Exerp Desktop Client'
    WHEN par.user_interface_type = 2
    THEN 'Web'
    WHEN par.user_interface_type = 3
    THEN 'Kiosk'
    WHEN par.user_interface_type = 4
    THEN 'Script'
    WHEN par.user_interface_type = 6
    THEN 'Member App'
    WHEN par.user_interface_type = 7
    THEN 'Staff App'
    WHEN par.user_interface_type IS NULL
    THEN NULL
    ELSE 'Unknown'
END AS "Booking Method"
,p1.fullname AS "Booking Creator"
,CASE
    WHEN par.showup_interface_type = 0
    THEN 'System'
    WHEN par.showup_interface_type = 1
    THEN 'Exerp Desktop Client'
    WHEN par.showup_interface_type = 2
    THEN 'Web'
    WHEN par.showup_interface_type = 3
    THEN 'Kiosk'
    WHEN par.showup_interface_type = 4
    THEN 'Script'
    WHEN par.showup_interface_type = 6
    THEN 'Member App'
    WHEN par.showup_interface_type = 7
    THEN 'Staff App'
    WHEN par.showup_interface_type IS NULL
    THEN NULL
    ELSE 'Unknown'
END AS "Show-Up Method"
,p2.fullname AS "Shown Up By"
,CASE
    WHEN par.cancelation_interface_type = 0
    THEN 'System'
    WHEN par.cancelation_interface_type = 1
    THEN 'Exerp Desktop Client'
    WHEN par.cancelation_interface_type = 2
    THEN 'Web'
    WHEN par.cancelation_interface_type = 3
    THEN 'Kiosk'
    WHEN par.cancelation_interface_type = 4
    THEN 'Script'
    WHEN par.cancelation_interface_type = 6
    THEN 'Member App' 
    WHEN par.cancelation_interface_type = 7
    THEN 'Staff App'    
    WHEN par.cancelation_interface_type IS NULL
    THEN NULL
    ELSE 'Unknown'
END AS "Cancel Method"
,p3.fullname AS "Cancelled By"
,par.state AS "Participation State"
,pu.state AS "Privilege Usage State"
,pu.misuse_state AS "Misuse State"


FROM

participations par


JOIN persons p
ON par.participant_center = p.center
AND par.participant_id = p.id
AND(p.center,p.id) IN (:personid)

JOIN bookings b
ON par.booking_center = b.center
AND par.booking_id = b.id

JOIN activity a
ON b.activity = a.id

JOIN privilege_usages pu
ON pu.target_center = par.center
AND pu.target_id = par.id
AND pu.target_service = 'Participation'

JOIN persons p1
ON par.creation_by_center = p1.center
AND par.creation_by_id = p1.id

LEFT JOIN persons p2
ON par.showup_by_center = p2.center
AND par.showup_by_id = p2.id

LEFT JOIN persons p3
ON par.cancelation_by_center = p3.center
AND par.cancelation_by_id = p3.id

