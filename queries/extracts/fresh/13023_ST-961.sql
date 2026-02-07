SELECT
    act.ID ,
    act.TOP_NODE_ID,
    act.NAME,
    act.STATE,
    act.DESCRIPTION,
    act.EXTERNAL_ID,
    act.SCOPE_TYPE,
    act.SCOPE_ID,
    CASE
        WHEN act.SCOPE_TYPE = 'A'
        THEN a.NAME
        WHEN act.SCOPE_TYPE = 'C'
        THEN C.NAME
        ELSE 'GLOBAL'
    END AS scope
FROM
    ACTIVITY act
LEFT JOIN
    AREAS a
ON
    a.ID = act.SCOPE_ID
    AND act.SCOPE_TYPE = 'A'
LEFT JOIN
    CENTERS c
ON
    c.ID = act.SCOPE_ID
    AND act.SCOPE_TYPE = 'C'