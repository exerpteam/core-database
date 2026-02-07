SELECT
        t1.clubid,
        t1.clubname,
        (CASE WHEN t1.state IN ('ACTIVE') THEN t1.total ELSE 0 END) AS "Active",
        (CASE WHEN t1.state IN ('DRAFT') THEN t1.total ELSE 0 END) AS "Draft",
        (CASE WHEN t1.state IN ('INACTIVE') THEN t1.total ELSE 0 END) AS "Inactive",
        (CASE WHEN t1.state IN ('STOP_NEW_AGREEMENTS') THEN t1.total ELSE 0 END) AS "StopNewAgreements"
FROM
(
        SELECT
                c.id AS clubid,
                c.name AS clubname,
                chc.state,
                count(*) AS total
        FROM vivagym.clearinghouse_creditors chc
        JOIN vivagym.clearinghouses ch ON chc.clearinghouse = ch.id
        JOIN vivagym.centers c ON chc.scope_id = c.id
        WHERE
                chc.scope_type = 'C'
                AND ch.ctype = 185
        GROUP BY
                c.id,
                c.name,        
                chc.state
) t1
ORDER BY 1