-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    par.center||'par'||par.id AS participation_id,
    par.recurring_participation_key,
    par.participant_center||'p'||par.participant_id as participant,
    par.booking_center||'book'||par.booking_id AS booking_id,
    bp.name as program_name,
    longtodate(par.creation_time)              AS par_creation_time,
    longtodate(bk.starttime)                   AS booking_start,
    cc.center||'cc'||cc.id||'id'||cc.subid     AS clipcard_id,
    pr.name                                    AS clipcard_name,
    ac.id                                      AS activity_id_booking,
    bp.activity as activity_id_program,
    ac.name                                    AS activity_name/*,
    pc.ACCESS_GROUP_ID                            required_access_group,
    bp.group_id                                AS granted_access_group*/
FROM
    lifetime.participations par
JOIN
    lifetime.clipcards cc
ON
    cc.recurring_participation_key = par.recurring_participation_key
    join lifetime.recurring_participations rpar on rpar.id = par.recurring_participation_key
    join lifetime.booking_programs bp on bp.id = rpar.booking_program_id
JOIN
    lifetime.products pr
ON
    pr.center = cc.center
AND pr.id = cc.id
JOIN
    bookings bk
ON
    bk.center = par.booking_center
AND bk.id = par.booking_id
JOIN
    lifetime.activity ac
ON
    ac.id = bk.activity
/*JOIN
    participation_configurations pc
ON
    ac.id = pc.activity_id
AND pc.ACCESS_GROUP_ID IS NOT NULL
JOIN
    lifetime.masterproductregister mpr
ON
    mpr.globalid = pr.globalid
JOIN
    lifetime.privilege_grants pg
ON
    pg.granter_service = 'GlobalCard'
AND pg.GRANTER_ID = mpr.id
JOIN
    BOOKING_PRIVILEGES bp
ON
    bp.PRIVILEGE_SET = pg.privilege_set*/
WHERE
    par.state = 'TENTATIVE'
AND par.after_sale_process