SELECT 
        longtodatec(el.time_stamp, el.reference_center) AS Event_Executed,
        p.center || 'p' || p.id AS PersonId,
        p.external_id,
        pea.txtvalue AS CORPANNUALFEE
FROM vivagym.event_type_config etc
JOIN vivagym.event_log el ON etc.id = el.event_configuration_id
JOIN vivagym.persons p ON el.reference_center = p.center AND el.reference_id = p.id AND el.reference_table = 'PERSONS'
JOIN vivagym.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = 'CORPANNUALFEE'
WHERE
        etc.id = 5601