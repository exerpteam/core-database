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
        WHERE
            parent IS NULL
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
    v_bi_roles AS
    (
        SELECT
            r.id,
            r.rolename
        FROM
            roles r
        WHERE
            r.rolename LIKE 'BI%'
        AND r.is_action = True
    )
    ,
    v_subroles AS
    (
        SELECT
            r.id AS root,
            r.id,
            r.parent,
            r.rolename,
            r.rolename AS actionname
        FROM
            (
                SELECT
                    r.id,
                    r.rolename,
                    imp.roleid AS parent
                FROM
                    v_bi_roles r
                LEFT JOIN
                    impliedemployeeroles imp
                ON
                    r.id = imp.implied ) r
        UNION
        SELECT
            s.root AS root,
            r.id,
            r.parent,
            r.rolename,
            s.actionname
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
            s.parent = r.id
    )
    ,
    v_person_roles AS
    (
        SELECT DISTINCT
            /*+ materialize */
            e.center || 'emp' || e.id    loginid ,
            p.center || 'p' || p.id   AS personid ,
            cp.external_id ,
            pea.txtvalue AS email ,
            -- NVL(rac.childname, rac.rootname) AS actionname ,
            er.scope_type AS SCOPE_TYPE,
            er.scope_id,
            --rac.namepath ,
            r.actionname,
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
            --  AND NVL(e.passwd_expiration, SYSDATE+1) >= TRUNC(SYSDATE)
        JOIN
            persons cp
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
            r.id = er.roleid
        LEFT JOIN
            person_ext_attrs pea
        ON
            pea.personcenter = p.center
        AND pea.personid = p.id
        AND pea.name = '_eClub_Email'
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
    c.id AS center
FROM
    v_person_roles vp
CROSS JOIN
    centers c
WHERE
    vp.scope_type IN ( 'G')
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