-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ef.id                             AS id
    , longtodate(ef.entry_time)::   TEXT AS creation_datetime
    , longtodate(ef.earliest_time)::TEXT AS earliest_run_datetime
    , op.result                          AS file_generation_result
    , ex.status                          AS export_status
    ,ef.filename
    , longtodate(op.start_time)::TEXT AS file_generation_start_datetime
    ,longtodate(op.stop_time)::  TEXT AS file_generation_complete_datetime
    ,longtodate(ex.export_time)::TEXT AS export_datetime
FROM
    exchanged_file ef
JOIN
    extract ext
ON
    ext.id = ef.agency
AND ef.service = 'Extract'
JOIN
    exchanged_file_exp ex
ON
    ex.exchanged_file_id = ef.id
LEFT JOIN
    exchanged_file_op op
ON
    op.exchanged_file_id = ef.id
WHERE
    ext.id = 605
AND ex.status ='EXPORTED'
AND op.result = 'DONE'
ORDER BY
    ex.export_time DESC
LIMIT
    1