-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
are.name as "scope",
CASE
WHEN efi.id is not NULL
THEN 'EF'|| efi.id
ELSE NULL
end as "Ref",
efs.name as "name of extract",
efi.service, 
to_char(longtodatetz(efp.EXPORT_TIME,'Europe/London'), 'YYYY-MM-dd HH24:MI') as "export time",
efp.status as "Status"

from
EXCHANGED_FILE_EXP efp

left join 
EXCHANGED_FILE efi
on 
efi.id = efp.EXCHANGED_FILE_ID
left join
EXCHANGED_FILE_SC efs
on

efi.SCHEDULE_ID = efs.id
and
efs.status = 'ACTIVE'

left join areas are
on
are.id = efi.scope_id

where
efp.status = 'EXPORTED' and

efp.EXPORT_TIME >= $$from_date$$
AND efp.EXPORT_TIME <= $$to_date_not_included$$