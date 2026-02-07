SELECT
    c2.SHORTNAME AS "Home Center",
     member_count.name as "Subscription",
    member_count.members,
    Attend_center AS Attend_Center,
    nvl(UNIQUE_ATTENDS,0) as UNIQUE_ATTENDS,
    nvl(atts,0) AS "Attends"
FROM
    (
        SELECT
            s.center,
            pr.name,
            COUNT(DISTINCT p.center||'p'||p.id) AS members
        FROM
            SUBSCRIPTIONS s
        JOIN
            PERSONS p
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
        JOIN
            PRODUCTS pr
        ON
            pr.center = s.SUBSCRIPTIONTYPE_CENTER
            AND pr.id = s.SUBSCRIPTIONTYPE_ID
        WHERE
            p.persontype <>2
            AND s.STATE in (2,4)
            AND s.center in ($$home_center$$)
        GROUP BY
            s.center ,
            pr.name) member_count
LEFT JOIN
    (
        SELECT
            s.center                                  AS "Home Center" ,
            pr.name                                   AS "Subscription",
            c.shortname                               AS Attend_center,
            COUNT (DISTINCT p.center||'p'||p.id)      AS UNIQUE_ATTENDS,
            COUNT(DISTINCT att.CENTER||'att'||att.id) AS atts
        FROM
            SUBSCRIPTIONS s
        JOIN
            PERSONS p
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
        JOIN
            ATTENDS att
        ON
            att.PERSON_CENTER = p.center
            AND att.PERSON_ID = p.id
        JOIN
            BOOKING_RESOURCES br
        ON
            br.CENTER = att.BOOKING_RESOURCE_CENTER
            AND br.id = att.BOOKING_RESOURCE_ID
            AND br.NAME='Gym Floor'
        JOIN
            centers c
        ON
            c.id = br.center
        JOIN
            PRODUCTS pr
        ON
            pr.center = s.SUBSCRIPTIONTYPE_CENTER
            AND pr.id = s.SUBSCRIPTIONTYPE_ID
        WHERE
            p.persontype <>2
            AND s.center in ($$home_center$$)
			AND s.STATE in (2,4)
            AND att.START_TIME BETWEEN $$from_date$$ AND $$to_date$$
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    ATTENDS att2
                WHERE
                    att2.PERSON_CENTER = att.PERSON_CENTER
                    AND att2.PERSON_ID = att.PERSON_ID
                    AND att2.BOOKING_RESOURCE_CENTER = att.BOOKING_RESOURCE_CENTER
                    AND att2.START_TIME BETWEEN att.START_TIME - 1000*60*60*3 AND att.START_TIME-1)
        GROUP BY
            s.center,
            pr.name ,
            c.shortname) attends_count
ON
    member_count.center = attends_count."Home Center"
    AND member_count.name = attends_count."Subscription"
JOIN
    centers c2
ON
    c2.id = member_count.center