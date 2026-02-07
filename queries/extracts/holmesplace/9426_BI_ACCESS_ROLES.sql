SELECT 
biview.*
FROM (WITH
    v_bi_roles AS
    (
        SELECT
            r.id,
            r.rolename
        FROM
            roles r
        WHERE
            r.rolename LIKE 'BI%'
        AND r.is_action = 1
        AND r.blocked = 0
    )
    ,
    v_implied_bi_roles AS
    (
        SELECT
            id,
            rolename,
            NULL AS rolepath
        FROM
            v_bi_roles
        UNION ALL
        SELECT
            imp.ROLEID,
            v_bi_roles.rolename,
            r.rolename AS rolepath
        FROM
            impliedemployeeroles imp
        JOIN
            v_bi_roles
        ON
            imp.IMPLIED = v_bi_roles.id
        JOIN
            roles r
        ON
            r.id = imp.ROLEID
        WHERE
            r.blocked = 0
    )
    ,
    v2_persons AS
    (
        SELECT
            /*+ materialize */
            e.center || 'emp' || e.id    loginid ,
            p.center || 'p' || p.id   AS personid ,
            cp.external_id ,
            pea.txtvalue                AS email ,
            v_implied_bi_roles.rolename AS actionname ,
            v_implied_bi_roles.rolepath AS rolepath ,
            er.scope_type ,
            DECODE(er.scope_type, 'G', 1, er.scope_id) scope_id,
            er.scope_type || er.scope_id               namescope
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
        AND NVL(e.passwd_expiration, SYSDATE+1) >= TRUNC(SYSDATE)
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
            v_implied_bi_roles
        ON
            er.roleid = v_implied_bi_roles.id
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
    ah.rolepath,
    TO_CHAR(ac.center) AS center,
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
                                        'T') START WITH a.id = vp.scope_id CONNECT BY PRIOR a.id =
            a.parent
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
    vp.rolepath,
    TO_CHAR(vp.scope_id) center,
    vp.namescope
FROM
    v2_persons vp
WHERE
    NVL(vp.scope_type, 'Z') = 'C'
ORDER BY
    1,2,3,4,5,6) biview