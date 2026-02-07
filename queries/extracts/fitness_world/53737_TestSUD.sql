-- This is the version from 2026-02-05
--  
select pe.personcenter || 'p' || pe.personid as PersonId, ROUND(Length(pe.mimevalue)/1024, 2) as size_in_mb from 
fw.person_ext_attrs pe
where pe.name = '_eClub_Picture'
and pe.mimevalue is not null
and pe.last_edit_time >= datetolongTZ(to_char(to_date('20-06-2021', 'dd-MM-yyyy'), 'YYYY-MM-dd HH24:MI'),  'Europe/London')