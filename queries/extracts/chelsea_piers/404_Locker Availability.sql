--Seats within resources are used as the inventory of available lockers.  Resource group containing
-- lockers is 'Lockers'.
--Resource name shauld start with either 'Mens - ...' or 'Womens - ...' to match the extended
-- attribute name identifying which locker are it is
SELECT
    t.*
FROM
    (
        WITH
            locker_master AS
            (
                SELECT
                    c.id                            AS center_id,
                    c.name                          AS business_unit,
                    trim(split_part(br.name,'-',2)) AS area,
                    trim(split_part(br.name,'-',3)) AS locker_size,
                    bs.ref                          AS locker_number
                FROM
                    booking_seats bs,
                    booking_resources br,
                    centers c,
                    booking_resource_groups brg,
                    booking_resource_configs brc
                WHERE
                    bs.resource_center = br.center
                AND bs.resource_id = br.id
                AND br.center = c.id
                AND brg.name = 'Lockers'
                AND brc.booking_resource_center = br.center
                AND brc.booking_resource_id = br.id
                AND brg.id = brc.group_id
                AND bs.status = 'READY'
            )
        SELECT
            business_unit AS "Center",
            area          AS "Locker Gender",
            locker_size   AS "Locker Size",
            locker_number AS "Locker Number" --Get all lockers from master list that are not
            -- assigned to any member
        FROM
            locker_master
        WHERE
            (
                center_id, area, locker_number) NOT IN
            (
                SELECT
                    s.center,
                    --p.center,
                    REPLACE(lockArea.txtvalue, '''', '') AS area,
                    lockNumber.txtvalue
                FROM
                    person_ext_attrs lockArea,
                    person_ext_attrs lockNumber,
                    -- persons p
                    subscriptions s
                JOIN
                    products pr
                ON
                    s.subscriptiontype_id = pr.id
                   AND  pr. name IN ('Locker Small',
                         'Locker Medium',
                         'Locker Large')
                   AND s.state IN (2,4)
                WHERE
                
                    lockArea.personcenter = s.owner_center
                AND lockArea.personid = s.owner_id
                AND lockArea.name = 'MensorWomensLockerRoom'
                AND lockArea.txtvalue IS NOT NULL
                AND lockNumber.personcenter = s.owner_center
                AND lockNumber.personid = s.owner_id
                AND lockNumber.name IN ('LockerNumber',
                                        'LockerNumber2')
                AND lockNumber.txtvalue IS NOT NULL)
            --AND upper(locker_size) != 'LARGE'
        AND center_id IN (:Scope)
        ORDER BY
            business_unit,
            area,
            locker_size,
            CAST(substring(locker_number FROM '[0-9]+') AS INTEGER) ) t
WHERE
    t."Locker Gender" IN (:Gender)
AND t."Locker Size" IN (:Locker_Size)