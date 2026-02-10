-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    EXCHANGED_FILE_SC.NAME extract_job_name,
    EXCHANGED_FILE_SC.SCHEDULE extract_job_schedule,    
    TO_CHAR(longtodateTZ(EXCHANGED_FILE.ENTRY_TIME, 'Europe/London'), 'YYYY-MM-DD') batch_date,
    longtodateTZ(EXCHANGED_FILE_OP.START_TIME, 'Europe/London')   extract_start_time,
    longtodateTZ(EXCHANGED_FILE_OP.STOP_TIME, 'Europe/London')    extract_stop_time,   
    EXCHANGED_FILE.status extract_status,   
    EXCHANGED_FILE.FILENAME,    
    longtodateTZ(EXCHANGED_FILE_EXP.EXPORT_TIME, 'Europe/London') extract_export_time,
    EXCHANGED_FILE_EXP.status export_status
FROM
    EXCHANGED_FILE_SC,
    EXCHANGED_FILE,
    EXCHANGED_FILE_OP,
    EXCHANGED_FILE_EXP
WHERE
    EXCHANGED_FILE_SC.agency = EXCHANGED_FILE.agency
AND EXCHANGED_FILE.ID = EXCHANGED_FILE_OP.EXCHANGED_FILE_ID (+)
AND EXCHANGED_FILE.ID = EXCHANGED_FILE_EXP.EXCHANGED_FILE_ID (+)
AND EXCHANGED_FILE_SC.status = 'ACTIVE'
AND EXCHANGED_FILE_SC.service = 'Extract'
AND EXCHANGED_FILE_SC.schedule in ('daily', 'weekly', 'monthly')
AND (EXCHANGED_FILE.status != 'GENERATED'
     OR (EXCHANGED_FILE_EXP.status IS NOT NULL AND EXCHANGED_FILE_EXP.status!= 'EXPORTED')
    )
AND EXCHANGED_FILE.ENTRY_TIME > datetolong(to_char(trunc(sysdate), 'YYYY-MM-DD HH24:MI'))
order by 1,2,3