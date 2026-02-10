-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    -- Find input role or action id
    params AS
    (
        SELECT
            r.id paramid
        FROM
            roles r
        WHERE
            r.rolename LIKE 'BI%'
    )
    -- Make a vector showing roles and actions as base and also their implied roles and actions
    ,
    v_rolesactions AS
    (
        SELECT
            r.id ,
            r.rolename name ,
            0          implied ,
            NULL       impliedname
        FROM
            roles r
        WHERE
            r.blocked = 0
        UNION
        SELECT
            i.roleid    id ,
            r.rolename  name ,
            i.implied   implied ,
            ir.rolename impliedname
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
    -- Make a vector showing immediate child roles and actions hierarchy. In effect this along with the level makes a new identifying connector
    ,
    v_rolesactionsbasehierarchy AS
    (
        SELECT DISTINCT
            id ,
            name ,
            implied ,
            impliedname
        FROM
            v_rolesactions CONNECT BY id = PRIOR implied
        ORDER BY
            2 ASC NULLS FIRST,
            4 ASC NULLS FIRST
    )
    --Make a vector showing all hierarchies / connectors for any or all roles and actions
    ,
    v_rolesactionsconnectors AS
    (
        SELECT DISTINCT
            connect_by_root id                                              rootid ,
            connect_by_root name                                            rootname ,
            id                                                              parentid ,
            name                                                            parentname ,
            implied                                                         childid ,
            impliedname                                                     childname ,
            CONNECT_BY_ROOT id || SYS_CONNECT_BY_PATH ( implied,'~' )       idpath ,
            CONNECT_BY_ROOT name || SYS_CONNECT_BY_PATH ( impliedname,'~' ) namepath ,
            level ,
            CONNECT_BY_ISLEAF AS isleaf
        FROM
            v_rolesactionsbasehierarchy
        CROSS JOIN
            params
        WHERE
            (
                id = paramid
                OR implied = paramid ) CONNECT BY id = PRIOR implied
            AND implied != 0 -- Only link with roles that have a leaf role or action or if its the base
        ORDER BY
            2 ASC NULLS FIRST,
            level,
            6 ASC NULLS FIRST --4 ASC NULLS FIRST, 6 ASC NULLS FIRST
    )
    ,
    v2_persons AS
    (
        SELECT
            /*+ materialize */
            e.center || 'emp' || e.id    loginid ,
            p.center || 'p' || p.id   AS personid ,
            cp.external_id ,
            pea.txtvalue                     AS email ,
            NVL(rac.childname, rac.rootname) AS actionname ,
            er.scope_type ,
            DECODE(er.scope_type, 'G', 1, er.scope_id) scope_id,
            rac.namepath ,
            er.scope_type || er.scope_id namescope
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
            AND e.blocked = 0
            AND e.passwd IS NOT NULL
            AND NVL(e.passwd_expiration, exerpsysdate()+1) >= TRUNC(exerpsysdate())
        JOIN
            PERSONS cp
        ON
            cp.center = p.CURRENT_PERSON_CENTER
            AND cp.id = p.CURRENT_PERSON_ID
        JOIN
            employeesroles er
        ON
            e.center = er.center
            AND e.id = er.id
        JOIN
            v_rolesactionsconnectors rac
        ON
            er.roleid = rac.rootid
        LEFT JOIN
            person_ext_attrs pea
        ON
            pea.personcenter = p.center
            AND pea.personid = p.id
            AND pea.name = '_eClub_Email'
    )
SELECT
    ah.loginid ,
    ah.personid ,
    ah.external_id ,
    ah.email ,
    ah.actionname ,
    to_char(ac.center) as center,
    ah.namepath,
    ah.namescope
FROM
    (
        SELECT DISTINCT
            vp.* ,
            a.id
        FROM
            v2_persons vp ,
            areas a
        WHERE
            NVL(vp.scope_type, 'Z') IN ('A',
                                        'G',
                                        'T') START WITH a.id = vp.scope_id CONNECT BY PRIOR a.id = a.parent
            AND PRIOR vp.actionname = vp.actionname
            AND prior vp.external_id=vp.external_id
        ORDER BY
            vp.loginid,
            vp.actionname,
            a.id ) ah
JOIN
    AREA_CENTERS ac
ON
    ah.id = ac.area
UNION
SELECT
    vp.loginid ,
    vp.personid ,
    vp.external_id ,
    vp.email ,
    vp.actionname ,
    to_char(vp.scope_id) center,
    vp.namepath,
    vp.namescope
FROM
    v2_persons vp
WHERE
    NVL(vp.scope_type, 'Z') = 'C'
ORDER BY
    1,2,3,4,5,6