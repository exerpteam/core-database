SELECT
            p.*,
            NULL AS new_ssn
        FROM
            persons p
        WHERE
            p.persontype != 2
        AND p.status IN (0,2)
        AND EXISTS
            (
                SELECT
                    1
                FROM
                    persons p2
                WHERE
                    p2.ssn = p.ssn
                AND NOT(p.center=p2.center
                    AND p.id = p2.id))