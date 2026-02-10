-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/servicedesk/customer/portal/9/EC-5618, https://clublead.atlassian.net/browse/EC-7094

10/12/22
https://clublead.atlassian.net/browse/ES-44889 10/12/2024
SELECT
    "Center",
    "Locker Size",
    "Subscription Owner",
    "Subscription Owner Key",
    "Owner Type",
    "Subscription Key",
    "Locker Number",
    "Subscription Price",
    "Subscription State",
    "Start Date",
    "Locker Gender"
FROM
    (
        SELECT DISTINCT
            c.id,
            c.name                    AS "Center",
            SUBSTRING(pr.name FROM 8) AS "Locker Size",
            p.fullname                AS "Subscription Owner",
            c.id || 'p' || p.id       AS "Subscription Owner Key",
            CASE p.PERSONTYPE
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
                THEN 'EXTERNAL_STAFF'
                ELSE 'Undefined'
            END                      AS "Owner Type",
            s.center || 'ss' || s.id AS "Subscription Key" ,
            lockNumber.txtvalue      AS "Locker Number",
            s.subscription_price     AS "Subscription Price",
            CASE s.STATE
                WHEN 2
                THEN 'ACTIVE'
                WHEN 3
                THEN 'ENDED'
                WHEN 4
                THEN 'FROZEN'
                WHEN 7
                THEN 'WINDOW'
                WHEN 8
                THEN 'CREATED'
                ELSE 'Undefined'
            END                                         AS "Subscription State" ,
            TO_CHAR(s.start_date :: DATE, 'mm/dd/yyyy') AS "Start Date",
            CASE
                  (
                  SELECT
                      pea.txtvalue
                  FROM
                      chelseapiers.person_ext_attrs pea
                  WHERE
                      pea.personcenter = s.owner_center
                  AND pea.personid = s.owner_id
                  AND pea.name = 'MensorWomensLockerRoom' AND pea.name NOT IN ('LockerNumber', 'LockerNumber2'))
                WHEN 'Women''s'
                THEN 'Womens'
                WHEN 'Womens'
                THEN 'Womens'
                WHEN 'Men''s'
                THEN 'Mens'
                WHEN 'Mens'
                THEN 'Mens'
                ELSE 'Undefined' 
            END AS "Locker Gender"
        FROM
            subscriptions s
        JOIN
            persons p
        ON
            (
                s.owner_center = p.center
            AND s.owner_id = p.id )
        JOIN
            person_ext_attrs lockNumber
        ON
            (
                lockNumber.personcenter = s.owner_center
            AND lockNumber.personid = s.owner_id )
        JOIN
            centers c
        ON
            s.center = c.id
        JOIN
            products pr
        ON
            s.subscriptiontype_id = pr.id
        WHERE
            lockNumber.name IN ('LockerNumber',
                                'LockerNumber2')
        AND lockNumber.txtvalue IS NOT NULL
        
             AND s.start_date < ((CAST(CAST(:cut_date AS DATE) at TIME zone 'America/New_York' AS DATE))
                 )
        AND pr. name IN ('Locker Small',
                         'Locker Medium',
                         'Locker Large')
       -- AND pr.blocked = false -- ES-44889
             AND c.id IN (:Scope)
        ORDER BY
            c.name,
            "Locker Size" ,
            "Locker Number" ) t
WHERE
    "Locker Size" IN (:Locker_Size)
AND "Locker Gender" IN (:Locker_Gender)
