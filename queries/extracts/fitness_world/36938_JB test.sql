-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    be.id                      AS job_id,
    be.scope_type||be.scope_id AS job_scope,
    be.entity_key,
    to_timestamp(ef.entry_time/1000) AS exchange_file_entrytime,
    ef.status                        AS file_status,
    efe.status                       AS export_status,
    efe.attempt                      AS export_attemps,
    efe.configuration                AS export_configuration,
    ef.filename,
    efs.name                 schedule_name,
    efs.id                   AS schedule_id,
    efs.filename_pattern     AS schedule_filename_pattern,
    efs.agency_configuration AS schedule_agency_config,
    efs.schedule_configuration,
    efs.status                      schedule_status,
    efs.attempts                    schedule_attempts,
    efs.scope_type||efs.scope_id AS schedule_scope,
    efs.next_schedule_day ,
    COUNT(bed.to_exec)
FROM
    batch_executions be
JOIN
    exchanged_file ef
ON
    ef.id = CAST(be.entity_key AS INT)
JOIN
    exchanged_file_sc efs
ON
    ef.schedule_id = efs.id
LEFT JOIN
    exchanged_file_exp efe
ON
    efe.exchanged_file_id = ef.id
JOIN
    batch_executions_dependencies bed
ON
    bed.from_exec = be.id
JOIN
    areas a
ON
    a.id = be.scope_id
WHERE
    be.scope_type IN ('T',
                      'A')
AND be.job_class = 'ExchangedFilesHandling'
AND be.execution_date > '2024-12-12'
GROUP BY
    be.id ,
    job_scope,
    be.entity_key,
    efs.name,
    efs.status,
    efs.attempts,
    efs.id,
    schedule_scope,
    schedule_agency_config,
    schedule_configuration,
    schedule_filename_pattern,
    ef.filename,
    efs.next_schedule_day,
    ef.status,
    efe.status ,
    efe.attempt ,
    efe.configuration,
    ef.entry_time;