-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    recursive
    -- Find input role or action id
    params AS
    (
        SELECT
            r.id paramid
        FROM
            roles r
        WHERE
            r.rolename = :RoleOrActionName
    )
    -- Make a vector showing roles and actions as base and also their implied roles and actions
    -- A row per role and all the roles/actions immediately implied by them
    ,
    v_rolesactions AS
    (
        SELECT
            r.id ,
            r.rolename AS name ,
            0             implied ,
            NULL          impliedname
        FROM
            roles r
        WHERE
            r.blocked = 0
        UNION
        SELECT
            i.roleid    id ,
            r.rolename  AS name ,
            i.implied      implied ,
            ir.rolename    impliedname
        FROM
            impliedemployeeroles i
        JOIN
            roles r
        ON
            i.roleid = r.id
        AND r.blocked = 0
        JOIN
            roles ir
        ON
            i.implied = ir.id
        AND ir.blocked = 0
        ORDER BY
            1,
            3
    )
    ,
    v_rolesactionsbasehierarchy0 AS
    (
        SELECT DISTINCT
            id ,
            name ,
            implied ,
            impliedname
        FROM
            v_rolesactions
        WHERE
            implied = 0
        UNION ALL
        SELECT DISTINCT
            o.id ,
            o.name ,
            o.implied ,
            o.impliedname
        FROM
            v_rolesactions o
        LEFT JOIN
            v_rolesactions im
        ON
            o.id = im.implied
    )
    ,
    v_rolesactionsbasehierarchy AS
    (
        SELECT DISTINCT
            id ,
            name ,
            implied ,
            impliedname
        FROM
            v_rolesactionsbasehierarchy0
    )
    ,
    v_rolesactionsconnectors AS
    (
        SELECT
            id                     parentid ,
            name                   parentname ,
            implied                childid ,
            impliedname            childname,
            id                     AS rootid ,
            id||'~'||implied       AS idpath,
            name||'~'||impliedname AS namepath
        FROM
            v_rolesactionsbasehierarchy
        --select * from v_rolesactionsconnectors;-- Only link with roles that have a leaf role or
        -- action or if its the
        -- base
        --4 ASC NULLS FIRST, 6 ASC NULLS FIRST
        UNION ALL
        SELECT
            o.id                            parentid ,
            o.name                          parentname ,
            o.implied                       childid ,
            o.impliedname                   childname,
            im.rootid                       AS rootid ,
            im.idpath||'~'||o.implied       AS idpath,
            im.namepath||'~'||o.impliedname AS namepath
        FROM
            v_rolesactionsbasehierarchy o
        JOIN
            v_rolesactionsconnectors im
        ON
            o.id = im.childid
            -- AND im.childid != 0
    )
    ,
    v_rolesactionsconnectors2 AS
    (
        SELECT
            *
        FROM
            params,
            v_rolesactionsconnectors
        WHERE
            (childid= params.paramid
            OR  parentid = params.paramid)
            and childid != 0
    )
SELECT
    e.center || 'emp' || e.id "Login ID"
    --, p.center || 'p' || p.id "Person ID"
    ,
    p.status ,
    c.name     "Center" ,
    p.fullname "Name" ,
    REPLACE( RTRIM ( REPLACE ( RTRIM(rac.namepath, '~') || '~', '~',
    CASE COALESCE(er.scope_type, 'Z')
        WHEN 'G'
        THEN '[Global]'
        WHEN 'T'
        THEN '[' || a.name || ']'
        WHEN 'A'
        THEN '[' || a.name || ']'
        WHEN 'C'
        THEN '[' || cs.name || ']'
        ELSE 'Unknown'
    END ||'~' ), '~'), '~', '->') "Path" ,
    CASE COALESCE(er.scope_type, 'Z')
        WHEN 'G'
        THEN 'Global'
        WHEN 'T'
        THEN a.name
        WHEN 'A'
        THEN a.name
        WHEN 'C'
        THEN cs.name
        ELSE 'Unknown'
    END "Assigned Scope" ,
    TO_CHAR(TRUNC(e.last_login), 'DD/MM/YYYY') "Last login" ,
    TO_CHAR(TRUNC(e.passwd_expiration), 'DD/MM/YYYY') "Password expiration"
FROM
    employees e
JOIN
    centers c
ON
    e.center = c.id
JOIN
    persons p
ON
    e.personcenter = p.center
AND e.personid = p.id
AND p.persontype = 2 --Staff
    --AND PERSONS.STATUS = PersonStatus.getEditable()
AND e.blocked = 0
AND e.passwd IS NOT NULL
JOIN
    employeesroles er
ON
    e.center = er.center
AND e.id = er.id
JOIN
    v_rolesactionsconnectors2 rac
ON
    er.roleid = rac.rootid
LEFT JOIN
    areas a
ON
    ( COALESCE(er.scope_type, 'Z') IN ('A',
                                       'T')
    AND a.id = er.scope_id )
LEFT JOIN
    centers cs
ON
    ( COALESCE(er.scope_type, 'Z') = 'C'
    AND cs.id = er.scope_id )
WHERE
    NOT EXISTS
    (
        SELECT
            1
        FROM
            person_ext_attrs pea
        WHERE
            pea.personcenter = p.center
        AND pea.personid = p.id
        AND pea.name = '_eClub_Email'
        AND LOWER(pea.txtvalue) LIKE '%exerp.com%' )
ORDER BY
    1