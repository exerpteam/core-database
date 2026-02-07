SELECT
    acc.center||'acc'||acc.id AS "ID",
    CASE acc.ATYPE
        WHEN 1
        THEN 'Asset'
        WHEN 2
        THEN 'Liability'
        WHEN 3
        THEN 'Income'
        WHEN 4
        THEN 'Expense'
        ELSE 'Undefined'
    END AS "TYPE",
    name as "NAME",
    external_id as "EXTERNAL_ID",
    globalid as "GLOBAL_ID",
    blocked as "BLOCKED",
    acc.center as "CENTER_ID"
FROM
    accounts acc