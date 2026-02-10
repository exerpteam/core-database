-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    child.external_id                             AS child_ext_id,
    pa.participant_center||'p'||pa.participant_id AS child,
    parent.external_id                            AS parent_ext_id,
    pa.owner_center||'p'||pa.owner_id             AS parent,
    bp.name,
    bk.center                                      AS booking_center,
    bk.id                                          AS booking_id,
    bk.main_booking_center                           AS main_booking_center,
    bk.main_booking_id                                AS main_booking_id,
    longtodateTZ(pa.start_time, 'America/Toronto')    AS "booking_start_time",
    longtodateTZ(pa.creation_time, 'America/Toronto') AS "Pa_creation_time",
    longtodateTZ(pa.last_modified, 'America/Toronto') AS "Pa_last_modified_time",
    pa.state,
    pa.*,
    bk.*,
    bp.* ,
    pu.*
    --, pu.*
FROM
    participations pa
JOIN
    persons child
ON
    pa.participant_center = child.center
AND pa.participant_id = child.id
JOIN
    persons parent
ON
    pa.owner_center = parent.center
AND pa.owner_id = parent.id
JOIN
    bookings bk
ON
    bk.center = pa.booking_center
AND bk.id = pa.booking_id
JOIN
    booking_programs bp
ON
    bk.booking_program_id = bp.id
JOIN
    booking_program_types bpt
ON
    bpt.id = bp.program_type_id
LEFT JOIN
    privilege_usages pu
ON
    pu.target_service = 'Participation'
AND pu.target_center = pa.center
AND pu.target_id = pa.id
WHERE
pa.state = 'TENTATIVE'
AND pa.creation_time > datetolongTZ('2025-01-01 00:01','America/Toronto')
-- and   pa.participant_center = 173 --and pa.participant_id = 12462
--and child.external_id = '112692393'