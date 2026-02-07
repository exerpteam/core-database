-- This is the version from 2026-02-05
--  
SELECT
    par.PARTICIPANT_CENTER,
    pu.target_center as privilege_usage_center,
    pp.name as punishment_type,
    count(pu.misuse_state) as number_of_penalties
FROM
     FW.PARTICIPATIONS par
JOIN FW.PRIVILEGE_USAGES pu
ON
    pu.TARGET_CENTER = par.CENTER
    AND pu.TARGET_ID = par.ID
JOIN FW.privilege_grants pg
ON
    pu.grant_id = pg.id
JOIN FW.privilege_punishments pp
ON  
    pg.punishment = pp.id
WHERE
    par.STATE = 'CANCELLED' 
and pu.misuse_state = 'PUNISHED'
and pu.target_start_time >= :StartDate 
and pu.target_start_time <= :EndDate +1
/* and par.PARTICIPANT_CENTER in () */
and pu.target_center in (:scope)
group by
    par.PARTICIPANT_CENTER,
    pu.target_center,
    pp.name 
order by
    par.PARTICIPANT_CENTER,
    pp.name   
