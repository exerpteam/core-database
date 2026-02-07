SELECT
    p2.center||'p'||p2.id                                                                                                                                     AS ExerpID,
    TO_CHAR(first_sub.start_date,'yyyy-MM-dd')                                                                                                                AS "Start date of person",
    TO_CHAR(s.END_DATE,'yyyy-MM-dd')                                                                                                                          AS "End date of person",
    floor(months_between(exerpsysdate(), p2.BIRTHDATE) / 12)                                                                                                         Age,
    DECODE(st.ST_TYPE, 0, 'Cash', 1, 'EFT', 3, 'Prospect')                                                                                                    AS "Payment type (EFT or cash)",
    DECODE ( p2.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS "Person type",
    NVL(ch."Number of visits January",0) "Check-ins January",
    NVL(ch."Number of visits February",0) "Check-ins February",
    NVL(ch."Number of visits March",0) "Check-ins March",
    NVL(ch."Number of visits April",0) "Check-ins April",
    NVL(ch."Number of visits May",0) "Check-ins May",
    NVL(ch."Number of visits June",0) "Check-ins June",
    NVL(ch."Number of visits July",0) "Check-ins July",
    NVL(ch."Number of visits August",0) "Check-ins August",
    NVL(par."GX participations January",0) "GX participations January",
    NVL(par."GX participations February",0) "GX participations February",
    NVL(par."GX participations March",0) "GX participations March",
    NVL(par."GX participations April",0) "GX participations April",
    NVL(par."GX participations May",0) "GX participations May" ,
    NVL(par."GX participations June",0) "GX participations June" ,
    NVL(par."GX participations July",0) "GX participations July" ,
    NVL(par."GX participations August",0) "GX participations August" ,
    SUM(DECODE(cc.GLOBALID,'PT45START1',cc.clips_used,0)) AS "PT START 1 used",
    SUM(DECODE(cc.GLOBALID,'PT45START2',cc.clips_used,0)) AS "PT START 2 used"
FROM
    SATS.PERSONS p1
JOIN
    SATS.PERSONS p2
ON
    p2.CENTER = p1.CURRENT_PERSON_CENTER
    AND p2.id = p1.CURRENT_PERSON_ID
JOIN
    (
        SELECT
            p.CURRENT_PERSON_CENTER                                  AS center,
            p.CURRENT_PERSON_ID                                      AS ID,
            MIN(exerpro.longtodate(s1.CREATION_TIME))                AS start_date,
            MAX(NVL(s1.END_DATE,to_date('2999-01-01','yyyy-MM-dd'))) AS END_DATE
        FROM
            SATS.SUBSCRIPTIONS s1
        JOIN
            SATS.PERSONS p
        ON
            p.center = s1.OWNER_CENTER
            AND p.id = s1.OWNER_ID
        WHERE
            (s1.END_DATE >= s1.START_DATE
            OR s1.END_DATE IS NULL)
            AND p.CURRENT_PERSON_CENTER IN ($$scope$$)
        GROUP BY
            p.CURRENT_PERSON_CENTER,
            p.CURRENT_PERSON_ID) first_sub
ON
    first_sub.center = p2.center
    AND first_sub.id = p2.ID
JOIN
    SATS.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p1.CENTER
    AND s.OWNER_ID = p1.id
    AND (
        s.END_DATE =first_sub.END_DATE
        OR s.END_DATE IS NULL)
JOIN
    SATS.SUBSCRIPTIONTYPES st
ON
    st.center = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    (
        SELECT
            ch.PERSON_CENTER,
            ch.PERSON_ID,
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(ch.CHECKIN_TIME)),1,1,0)) AS "Number of visits January",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(ch.CHECKIN_TIME)),2,1,0)) AS "Number of visits February",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(ch.CHECKIN_TIME)),3,1,0)) AS "Number of visits March",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(ch.CHECKIN_TIME)),4,1,0)) AS "Number of visits April",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(ch.CHECKIN_TIME)),5,1,0)) AS "Number of visits May",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(ch.CHECKIN_TIME)),6,1,0)) AS "Number of visits June",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(ch.CHECKIN_TIME)),7,1,0)) AS "Number of visits July",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(ch.CHECKIN_TIME)),8,1,0)) AS "Number of visits August"
        FROM
            SATS.CHECKINS ch
        JOIN
            persons p1
        ON
            ch.PERSON_CENTER = p1.CENTER
            AND ch.PERSON_ID = p1.id
        WHERE
            ch.CHECKIN_TIME BETWEEN exerpro.datetolong('2014-01-01 00:00') AND exerpro.datetolong('2014-08-31 23:59')
            AND p1.CURRENT_PERSON_CENTER IN ($$scope$$)
            AND p1.FIRST_ACTIVE_START_DATE < $$to_date$$
            AND (
                p1.LAST_ACTIVE_END_DATE >$$from_date$$
                OR p1.LAST_ACTIVE_END_DATE IS NULL)
        GROUP BY
            ch.PERSON_CENTER,
            ch.PERSON_ID)ch
ON
    ch.PERSON_CENTER = p1.CENTER
    AND ch.PERSON_ID = p1.id
LEFT JOIN
    (
        SELECT
            p.CURRENT_PERSON_CENTER AS OWNER_CENTER,
            p.CURRENT_PERSON_ID     AS OWNER_ID,
            pr.GLOBALID,
            COUNT(DISTINCT pu.ID) AS clips_used
        FROM
            SATS.CLIPCARDS cc
        JOIN
            SATS.PERSONS p
        ON
            cc.OWNER_CENTER = p.CENTER
            AND cc.OWNER_ID = p.ID
        JOIN
            sats.privilege_usages pu
        ON
            pu.source_center = cc.center
            AND pu.source_id = cc.id
            AND pu.source_subid = cc.subid
        JOIN
            SATS.ATTENDS att
        ON
            att.CENTER = pu.TARGET_CENTER
            AND att.id = pu.TARGET_ID
            AND att.START_TIME BETWEEN exerpro.datetolong('2014-01-01 00:00') AND exerpro.datetolong('2014-08-31 23:59')
        JOIN
            sats.PRIVILEGE_GRANTS pg
        ON
            pg.ID = pu.GRANT_ID
            AND pg.GRANTER_SERVICE = 'GlobalCard'
        JOIN
            SATS.INVOICELINES il
        ON
            il.center = cc.INVOICELINE_CENTER
            AND il.id = cc.INVOICELINE_ID
            AND il.SUBID = cc.INVOICELINE_SUBID
        JOIN
            SATS.PRODUCTS pr
        ON
            pr.center = il.PRODUCTCENTER
            AND pr.id = il.PRODUCTID
        WHERE
            p.CURRENT_PERSON_CENTER IN ($$scope$$)
            AND p.FIRST_ACTIVE_START_DATE < $$to_date$$
            AND (
                p.LAST_ACTIVE_END_DATE >$$from_date$$
                OR p.LAST_ACTIVE_END_DATE IS NULL)
        GROUP BY
            p.CURRENT_PERSON_CENTER ,
            p.CURRENT_PERSON_ID,
            pr.GLOBALID ) cc
ON
    cc.OWNER_CENTER = p1.CENTER
    AND cc.OWNER_ID = p1.ID
LEFT JOIN
    (
        SELECT
            par.PARTICIPANT_CENTER,
            par.PARTICIPANT_ID,
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(par.START_TIME)),1,1,0)) AS "GX participations January",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(par.START_TIME)),2,1,0)) AS "GX participations February",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(par.START_TIME)),3,1,0)) AS "GX participations March",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(par.START_TIME)),4,1,0)) AS "GX participations April",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(par.START_TIME)),5,1,0)) AS "GX participations May",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(par.START_TIME)),6,1,0)) AS "GX participations June",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(par.START_TIME)),7,1,0)) AS "GX participations July",
            SUM(DECODE(extract(MONTH FROM exerpro.longtodate(par.START_TIME)),8,1,0)) AS "GX participations August"
        FROM
            SATS.PARTICIPATIONS par
        JOIN
            SATS.PERSONS p2
        ON
            par.PARTICIPANT_CENTER = p2.CENTER
            AND par.PARTICIPANT_ID = p2.ID
        WHERE
            par.STATE = 'PARTICIPATION'
            AND par.START_TIME BETWEEN exerpro.datetolong('2014-01-01 00:00') AND exerpro.datetolong('2014-08-31 23:59')
            AND p2.CURRENT_PERSON_CENTER IN ($$scope$$)
            AND p2.FIRST_ACTIVE_START_DATE < $$to_date$$
            AND (
                p2.LAST_ACTIVE_END_DATE >$$from_date$$
                OR p2.LAST_ACTIVE_END_DATE IS NULL)
        GROUP BY
            par.PARTICIPANT_CENTER,
            par.PARTICIPANT_ID) par
ON
    par.PARTICIPANT_CENTER = p2.CENTER
    AND par.PARTICIPANT_ID = p2.ID
WHERE
    p2.center IN ($$scope$$)
    AND p2.FIRST_ACTIVE_START_DATE < $$to_date$$
    AND (
        p2.LAST_ACTIVE_END_DATE >$$from_date$$
        OR p2.LAST_ACTIVE_END_DATE IS NULL)
GROUP BY
    p2.center,
    p2.id,
    p2.BIRTHDATE,
    s.END_DATE,
    first_sub.start_date,
    p2.PERSONTYPE,
    st.ST_TYPE,
    ch."Number of visits January",
    ch."Number of visits February",
    ch."Number of visits March",
    ch."Number of visits April",
    ch."Number of visits May",
    ch."Number of visits June",
    ch."Number of visits July",
    ch."Number of visits August",
    par."GX participations January",
    par."GX participations February",
    par."GX participations March",
    par."GX participations April",
    par."GX participations May",
    par."GX participations June",
    par."GX participations July",
    par."GX participations August"