SELECT DISTINCT
    lpad(' ',2*(level-1)) || TO_CHAR(tree.name) name,
    tree.is_action,
    sys_connect_by_path( DECODE(tree.is_action,0,'1',1,'0','ERROR') || tree.name, '/' ) path,
    tree.child,
    tree.parent
FROM
    (
        SELECT
            r.ID child,
            NULL parent,
            r.ROLENAME name,
            r.IS_ACTION
        FROM
            ROLES r
        WHERE
            r.IS_ACTION = 0
            AND r.BLOCKED = 0
        UNION
        SELECT
            ir.IMPLIED child,
            ir.ROLEID parent,
            r.ROLENAME name,
            r.IS_ACTION
        FROM
            IMPLIEDEMPLOYEEROLES ir
        JOIN ROLES r
        ON
            r.ID = ir.IMPLIED
    )
    tree START
WITH tree.parent IS NULL CONNECT BY prior tree.child = tree.parent
ORDER BY
    path