-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center || 'p' || p.id AS person_Id,
        pea.txtvalue AS legacy_Id,
        p.fullname AS fullname,
        p.external_id,
        pea.name,
        e.center || 'emp' || e.id AS employment_id,
        ces.lastupdated AS migration_datetime,
        sg.name,
        psg.scope_type,
        psg.scope_id
FROM exerp.persons p
LEFT JOIN exerp.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
LEFT JOIN exerp.employees e ON p.center = e.personcenter AND p.id = e.personid AND e.blocked = false
LEFT JOIN exerp.converter_entity_state ces ON ces.newentitycenter = p.center AND ces.newentityid = p.id AND ces.writername = 'ClubLeadPersonWriter'
LEFT JOIN exerp.person_staff_groups psg ON p.center = psg.person_center AND p.id = psg.person_id
LEFT JOIN exerp.staff_groups sg ON psg.staff_group_id = sg.id 
WHERE
        p.persontype = 2
        AND (e.center,e.id) NOT IN ((100,1))
        AND p.fullname NOT LIKE ('Exerp%')
        AND p.status NOT IN (4,5,7,8)