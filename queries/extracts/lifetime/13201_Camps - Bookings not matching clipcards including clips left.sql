-- The extract is extracted from Exerp on 2026-02-08
-- List of members with the number of camp bookings starting after 2023-03-01 where main and lunch bookings are not linked to the matching clipcard as well as initial and remaining clips 
On 2023-06-05 after upgrade updated extract to look at camps after '2023-06-05'
--ES-37882
SELECT
    COUNT (*),
    parent.external_id AS parent_id,
    parent.fullname    AS parent_name,
    child.external_id  AS child_id,
    child.fullname     AS child_name,
    bk.center as center,
    ct.name as center_name,
    bk.name            AS booking_name,
    il.text            AS clipcard_invoice_entry,
    c.clips_initial,
    c.clips_left,
    bk.booking_program_id,
    bp.startdate AS program_start
FROM
    participations pa
JOIN
    bookings bk
ON
    bk.center = pa.booking_center
AND bk.id = pa.booking_id
JOIN
    privilege_usages pu
ON
    pu.target_service = 'Participation'
AND pu.target_center = pa.center
AND pu.target_id = pa.id
LEFT JOIN
    card_clip_usages cu
ON
    '' || cu.id = pu.deduction_key --slow call
LEFT JOIN
    persons parent
ON
    parent.center = pa.owner_center
AND parent.id = pa.owner_id
LEFT JOIN
    persons child
ON
    child.center = pa.participant_center
AND child.id = pa.participant_id
JOIN
    clipcards c
ON
    pu.source_center = c.center
AND pu.source_id = c.id
AND pu.source_subid = c.subid
JOIN
    lifetime.invoice_lines_mt il
ON
    c.invoiceline_center = il.center
AND c.invoiceline_id = il.id
AND c.invoiceline_subid = il.subid
JOIN
    booking_programs bp
ON
    bk.booking_program_id = bp.id
LEFT JOIN
    booking_program_types bpt
ON
    bpt.id = bp.program_type_id
join centers ct on bk.center = ct.id
WHERE
    ((
            bk.name LIKE 'Lunch%'
        AND il.text LIKE 'KCSA%')
    OR  (
            bk.name LIKE 'Kids%'
        AND il.text LIKE 'Lunch%')
    OR  (
            bk.name LIKE 'Lunch%'
        AND il.text LIKE 'KCT%')
    OR  (
            bk.name LIKE 'Lunch%'
        AND il.text LIKE 'KCJ%')
    OR  (
            bk.name LIKE 'School Break Days%'
        AND il.text LIKE 'Kids Camp - Lunch')
    OR  (
            bk.name LIKE 'School Break Lunch'
        AND il.text LIKE 'Kids Ba%')
    OR  (
            bk.name LIKE 'Track Out Camp%'
        AND il.text LIKE 'Kids Camp - Lunch'))
AND pa.state != 'CANCELLED'
AND bp.startdate > '2023-06-05'
GROUP BY
    parent.external_id,
    parent.fullname,
    child.external_id,
    child.fullname,
    bk.name,
    il.text,
    c.clips_initial,
    c.clips_left,
    bk.booking_program_id,
    bp.startdate,
    bk.center,
    ct.name
ORDER BY
    parent.external_id ,
    child.external_id,
    bp.startdate