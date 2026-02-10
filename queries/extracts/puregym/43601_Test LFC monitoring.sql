-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    rank() over (partition BY STARTDATE ORDER BY bl.STARTTIME) as rank,
    longtodate(bl.STARTTIME) STARTTIME,
    longtodate(bl.COMPLETIONTIME) COMPLETIONTIME,
    bl.*
FROM
    PUREGYM.BATCHLOGS bl
WHERE
    bl.JOBNAME = 'Live Field Calculator'
    AND bl.STARTDATE = TRUNC (SYSDATE)
ORDER BY
    bl.STARTTIME DESC