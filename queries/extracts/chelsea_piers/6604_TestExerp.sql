-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    list_persons AS
    (
        SELECT
            p.center as  personcenter,
            p.id as personid
        FROM
            persons p
        where p.center = 18
and p.id IN (
11512,
16023,
17144,
10954,
19305,
3575,
12001,
14453,
17147
)

    )
    ,
    list_subscriptions AS
    (
        SELECT DISTINCT
            s.owner_center,
            s.owner_id
        FROM
            list_persons lp
        JOIN
            chelseapiers.subscriptions s
        ON
            lp.personcenter = s.owner_center
            AND lp.personid = s.owner_id
            AND s.state IN (2,4,8)
    )
    ,
    list_clipcards AS
    (
        SELECT DISTINCT
            c.owner_center,
            c.owner_id
        FROM
            list_persons lp
        JOIN
            chelseapiers.clipcards c
        ON
            lp.personcenter = c.owner_center
            AND lp.personid = c.owner_id
            AND c.finished = false
            AND c.cancelled = false
            AND c.blocked = false
    )
    ,
    list_bookings AS
    (
        WITH
            params AS
            (
                SELECT
                    dateToLongC(TO_CHAR(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'), 'YYYY-MM-DD'),c.id) AS cutDate,
                    c.id
                FROM
                    chelseapiers.centers c
            )
        SELECT
            part.participant_center,
            part.participant_id,
            COUNT(*) AS total_bookings
        FROM
            list_persons lp
        JOIN
            chelseapiers.participations part
        ON
            lp.personcenter = part.participant_center
            AND lp.personid = part.participant_id
            AND part.state NOT IN ('CANCELLED')
        JOIN
            params par
        ON
            par.id = part.center
        WHERE
            part.start_time > par.cutDate
        GROUP BY
            part.participant_center,
            part.participant_id
    )
SELECT DISTINCT
    lp.personcenter || 'p' || lp.personid AS PersonId,
    (
        CASE
            WHEN ls.owner_center IS NULL
            THEN 'NO'
            ELSE 'YES'
        END) AS Has_Subscriptions,
    (
        CASE
            WHEN lc.owner_center IS NULL
            THEN 'NO'
            ELSE 'YES'
        END)          AS Has_Clipcards,
    lb.total_bookings AS Future_Bookings,
    CASE p2.STATUS
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END AS PERSON_STATUS,
    CASE p2.persontype
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        WHEN 9
        THEN 'CHILD'
        WHEN 10
        THEN 'EXTERNAL STAFF'
        ELSE 'UNKNOWN'
    END AS PersonType,
    CASE
        WHEN famrel.rtype = 19
        THEN 'PrimaryToFamily'
        WHEN famrel.rtype = 20
        THEN 'SpouseToFamily'
        WHEN famrel.rtype = 21
        THEN 'PartnerToFamily'
        WHEN famrel.rtype = 22
        THEN 'ChildToFamily'
        WHEN famrel.rtype = 23
        THEN 'OtherToFamily'
    END AS FamilyTypeReleation
FROM
    list_persons lp
JOIN
    persons p2
ON
    p2.center = lp.personcenter
    AND p2.id = lp.personid
LEFT JOIN
    list_subscriptions ls
ON
    lp.personcenter = ls.owner_center
    AND lp.personid = ls.owner_id
LEFT JOIN
    list_clipcards lc
ON
    lp.personcenter = lc.owner_center
    AND lp.personid = lc.owner_id
LEFT JOIN
    list_bookings lb
ON
    lb.participant_center = lp.personcenter
    AND lb.participant_id = lp.personid
LEFT JOIN
    relatives famrel
ON
    famrel.center = lp.personcenter
    AND famrel.id = lp.personid
    AND famrel.rtype IN ( 19,
                         20,
                         21,
                         22,
                         23)
    AND famrel.status < 2 