        SELECT
            personexternalid as "Person External ID",
            PERSONTYPE as "Person Type",            
            PERSON_STATUS as "Person State",
            attr_name as "Extra Attribute Name"
        FROM
            (
                SELECT
                    personexternalid,              
                    PERSON_STATUS,
                    PERSONTYPE,
                    attr_name,
                    attr_value_old,
                    cast(bool_or(attribute_new_value)as varchar) as attribute_new_value
                FROM
                    (
                        SELECT DISTINCT
                            p.center as center,
                            p.external_id as personexternalid,
                            CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
                            CASE WHEN PERSONTYPE = 0 THEN 'PRIVATE' WHEN PERSONTYPE = 1 THEN 'STUDENT' WHEN PERSONTYPE = 2 THEN 'STAFF' WHEN PERSONTYPE = 3 THEN 'FRIEND' WHEN PERSONTYPE = 4 THEN 'CORPORATE' WHEN PERSONTYPE = 5 THEN 'ONEMANCORPORATE' WHEN PERSONTYPE = 6 THEN 'FAMILY' WHEN PERSONTYPE = 7 THEN 'SENIOR' WHEN PERSONTYPE = 8 THEN 'GUEST' WHEN PERSONTYPE = 9 THEN 'CHILD' WHEN PERSONTYPE = 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE,
                            -- staff members always get 1
                            atts.val AS attr_name,
                             CASE
                                WHEN p.persontype = 2
                                THEN True
                                WHEN s.state = 4 --frozen
                                THEN False
                                WHEN atts.val = 'DCABasicAtHomeWorkouts'
                                THEN  cast(t.basicathomeworkouts as BOOLEAN)
                                WHEN atts.val = 'DCABasicInClubWorkouts'
                                THEN cast(t.BasicInClubWorkouts as BOOLEAN)
                                WHEN atts.val = 'DCABasicOnDemandContent'
                                THEN  cast(t.BasicOnDemandContent as BOOLEAN)
                                WHEN atts.val = 'DCABasicTrainingPlans'
                                THEN  cast(t.BasicTrainingPlans as BOOLEAN)
                                WHEN atts.val = 'DCAFullAtHomeWorkouts'
                                THEN  cast(t.FullAtHomeWorkouts as BOOLEAN)
                                WHEN atts.val = 'DCAFullInClubWorkouts'
                                THEN  cast(t.fullinclubworkouts as BOOLEAN)
                                WHEN atts.val = 'DCAFullOnDemandContent'
                                THEN  cast(t.FullOnDemandContent as BOOLEAN)
                                WHEN atts.val = 'DCAFullTrainingPlans'
                                THEN cast(t.FullTrainingPlans as BOOLEAN)
                                WHEN atts.val = 'DCAPremiumTrainingPlans'
                                THEN cast(t.PremiumTrainingPlans as BOOLEAN)
                            END AS attribute_new_value,
                            (
                                SELECT
                                    pea.txtvalue
                                FROM
                                    person_ext_attrs pea
                                WHERE
                                    pea.personcenter = s.owner_center
                                AND pea.personid = s.owner_id
                                AND pea.name = atts.val
                                and pea.txtvalue = 'true'
                                )                          AS attr_value_old
                        FROM
                            persons p
                        LEFT JOIN
                            subscriptions s
                        ON
                            p.center = s.owner_center
                        AND p.id = s.owner_id
                        AND s.state IN (2,4) -- only active and frozen subscriptions
                        LEFT JOIN
                            products pr
                        ON
                            s.subscriptiontype_center = pr.center
                        AND s.subscriptiontype_id = pr.id
                        CROSS JOIN
                            (
                                SELECT
                                    'DCABasicAtHomeWorkouts' AS val
                                UNION ALL
                                SELECT
                                    'DCABasicInClubWorkouts'
                                UNION ALL
                                SELECT
                                    'DCABasicOnDemandContent'
                                UNION ALL
                                SELECT
                                    'DCABasicTrainingPlans'
                                UNION ALL
                                SELECT
                                    'DCAFullAtHomeWorkouts'
                                UNION ALL
                                SELECT
                                    'DCAFullInClubWorkouts'
                                UNION ALL
                                SELECT
                                    'DCAFullOnDemandContent'
                                UNION ALL
                                SELECT
                                    'DCAFullTrainingPlans'
                                UNION ALL
                                SELECT
                                    'DCAPremiumTrainingPlans') atts
                        LEFT JOIN
                            public.sync_member_attr_new t
                        ON
                            t.globalproductid = pr.globalid                       
                        WHERE
                            p.status NOT IN (7,8) -- deleted, anonymized excluded
                        AND (
                                p.persontype = 2
                            OR  t.globalproductid IS NOT NULL) --set attributes for staff or
                            -- persons with the listed products
                            and p.center in (:Scope)
                    ) t
                GROUP BY
                    personexternalid,
                    center,
                    person_status,
                    persontype,
                    attr_name,
                    attr_value_old
                    ) t
        WHERE
            attr_value_old != attribute_new_value
        and attr_value_old = 'true'