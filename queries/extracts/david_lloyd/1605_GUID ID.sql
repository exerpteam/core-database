-- This is the version from 2026-02-05
--  
select p.external_id,p.center||'p'||p.id AS MemberID ,pea.txtvalue AS GUID
 from persons p
JOIN
person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
where p.center||'p'||p.id in (:Pnumber)
and pea.name = '_eClub_OldSystemPersonId'