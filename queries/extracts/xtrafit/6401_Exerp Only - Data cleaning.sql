SELECT 
        count(*)
/*
--            NTILE(10) over () AS apply_step_group,
        prev.center || 'p' || prev.id as "person key",
        CASE prev.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
        (CASE
                WHEN prev.STATUS = 7 THEN 'Run Annonymize apply step'
                ELSE 'Run Delete apply step'
        END) AS action
        */
FROM persons p
JOIN persons prev
        ON prev.current_person_center = p.center
        AND prev.current_person_id     = p.id
        AND prev.status                NOT IN (8)
WHERE p.status = 8 -- anonymized person

--and prev.STATUS = 7 --deleted

--ORDER BY 3