WITH
    RECURSIVE v_subareas AS
    (
        SELECT
            a.id AS root,
            a.id,
            a.parent,
            a.name
        FROM
            areas a
        UNION
        SELECT
            s.root,
            a.id,
            a.parent,
            a.name
        FROM
            areas a
        INNER JOIN
            v_subareas s
        ON
            s.id = a.parent
    )
    ,
    v_subroles AS
    (
        SELECT
            r.id AS root,
            r.id,
            r.parent,
            r.rolename
        FROM
            (
                SELECT
                    r.id,
                    r.rolename,
                    imp.roleid AS parent
                FROM
                    roles r
                LEFT JOIN
                    impliedemployeeroles imp
                ON
                    r.id = imp.implied
                WHERE
                    r.blocked = 0 ) r
        UNION
        SELECT
            s.id AS root,
            r.id,
            r.parent,
            r.rolename
        FROM
            (
                SELECT
                    r.id,
                    r.rolename,
                    imp.roleid AS parent
                FROM
                    roles r
                LEFT JOIN
                    impliedemployeeroles imp
                ON
                    r.id = imp.implied
                WHERE
                    r.blocked = 0) r
        INNER JOIN
            v_subroles s
        ON
            s.id = r.parent
    )
    ,
    v_person_roles AS
    (
        SELECT
            /*+ materialize */
            e.center || 'emp' || e.id    loginid ,
            p.center || 'p' || p.id   AS personid ,
            cp.external_id ,
            pea.txtvalue AS email ,
            -- NVL(rac.childname, rac.rootname) AS actionname ,
            er.scope_type AS SCOPE_TYPE,
            er.scope_id,
            --rac.namepath ,
            r.ROLENAME                   AS actionname,
            er.scope_type || er.scope_id    namescope
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
            --  AND NVL(e.passwd_expiration, SYSDATE+1) >= TRUNC(SYSDATE)
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
            v_subroles r
        ON
            r.root = er.roleid
        JOIN
            v_bi_roles bi_roles
        ON
            bi_roles.id = r.id
        LEFT JOIN
            person_ext_attrs pea
        ON
            pea.personcenter = p.center
        AND pea.personid = p.id
        AND pea.name = '_eClub_Email'
    )
    ,
    v_bi_roles AS
    (
        SELECT
            r.id
        FROM
            roles r
        WHERE
            r.rolename LIKE 'BI%'
        AND r.is_action = True
    )
SELECT
    vp.loginid ,
    vp.personid ,
    vp.external_id ,
    vp.email ,
    vp.actionname ,
    ac.center AS center
FROM
    v_person_roles vp
JOIN
    v_subareas sa
ON
    sa.root = vp.scope_id
AND vp.scope_type IN ('A',
                      'G',
                      'T')
JOIN
    AREA_CENTERS ac
ON
    sa.id = ac.area
UNION
SELECT
    vp.loginid ,
    vp.personid ,
    vp.external_id ,
    vp.email ,
    vp.actionname ,
    vp.scope_id AS center
FROM
    v_person_roles vp
WHERE
    vp.scope_type = 'C'
ORDER BY
    1,2,3,4,5,6