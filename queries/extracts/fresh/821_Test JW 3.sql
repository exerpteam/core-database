SELECT
    par.PARTICIPANT_CENTER ||'p'|| par.PARTICIPANT_ID AS Participant,
    longToDate(par.START_TIME) as participation_start,
    act.name as activity,
    ROUND(ivl.TOTAL_AMOUNT/cc.CLIPS_INITIAL,2) AS price_pr_clip,
    instructor.showup_by_center||'p'||instructor.showup_by_id as Employee
FROM
    BOOKING_PRIVILEGE_GROUPS accGroup
JOIN PARTICIPATION_CONFIGURATIONS partConf
ON
    partConf.ACCESS_GROUP_ID = accGroup.ID
JOIN ACTIVITIES_NEW act
ON
    act.ID = partConf.ACTIVITY_ID
JOIN BOOKINGS b
ON
    b.ACTIVITY = act.ID
JOIN PARTICIPATIONS par
ON
    par.BOOKING_CENTER = b.CENTER
    AND par.BOOKING_ID = b.ID
JOIN PRIVILEGE_USAGES pu
ON
    pu.TARGET_CENTER = par.CENTER
    AND pu.TARGET_ID = par.ID
JOIN CLIPCARDS cc
ON
    cc.CENTER = pu.SOURCE_CENTER
    AND cc.id = pu.SOURCE_ID
    and cc.SUBID = pu.SOURCE_SUBID
JOIN INVOICELINES ivl
ON
    ivl.CENTER = cc.INVOICELINE_CENTER
    AND ivl.ID = cc.INVOICELINE_ID
    AND ivl.SUBID = cc.INVOICELINE_SUBID
join    participations instructor
        on
        b.center = instructor.booking_CENTER
        and b.id = instructor.booking_ID
WHERE
    accGroup.NAME = 'Personal Instructor (PT)'
    AND par.STATE IN ('PARTICIPATION')
	and par.start_time >= :FromDate
    and par.start_time <= :ToDate
