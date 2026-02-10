-- The extract is extracted from Exerp on 2026-02-08
-- Check for Staff Missing Digital Attributes (FALSE)
--select t."External Person ID",
--t."Current Person Type",
--t."Current Person State",
--t."Extra Attribute Name"
SELECT
"External Person ID",
"Current Person Type",
"Current Person State",
"Extra Attribute Name" as "Missing Attribute Name" 
--STRING_AGG(CAST("Extra Attribute Name" AS TEXT),'; ' ) as "Extra Attribute Name",

   
FROM
    (
        WITH
            params AS
            (
                SELECT
                    p.center AS paramcenter,
                    p.id                AS paramid,
                    true  AS basicathomeworkouts,
                    true AS basicinclubworkouts,
                    true AS basicondemandcontent,
                    true AS basictrainingplans,
                    true AS fullathomeworkouts,
                    true AS fullinclubworkouts,
                    true AS fullondemandcontent,
                    true AS fulltrainingplans,
                    true AS premiumtrainingplans
                FROM
                    persons p where p.persontype = 2   
                    and p.status not in (4,7,8)
                    and p.center in (:Scope)          
            )
        SELECT DISTINCT
            p.center AS home_center,
            p.external_id as "External Person ID",
            CASE
                WHEN PERSONTYPE = 0
                THEN 'PRIVATE'
                WHEN PERSONTYPE = 1
                THEN 'STUDENT'
                WHEN PERSONTYPE = 2
                THEN 'STAFF'
                WHEN PERSONTYPE = 3
                THEN 'FRIEND'
                WHEN PERSONTYPE = 4
                THEN 'CORPORATE'
                WHEN PERSONTYPE = 5
                THEN 'ONEMANCORPORATE'
                WHEN PERSONTYPE = 6
                THEN 'FAMILY'
                WHEN PERSONTYPE = 7
                THEN 'SENIOR'
                WHEN PERSONTYPE = 8
                THEN 'GUEST'
                WHEN PERSONTYPE = 9
                THEN 'CHILD'
                WHEN PERSONTYPE = 10
                THEN 'EXTERNAL_STAFF'
                ELSE 'Undefined'
            END AS "Current Person Type",
            CASE p.STATUS
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
            END      AS "Current Person State",
            pea.name AS "Extra Attribute Name"
        FROM
            persons p
        JOIN
            params
        ON
            params.paramcenter = p.center
        AND params.paramid = p.id
        JOIN
            goodlife.person_ext_attrs pea
        ON
            pea.personcenter = p.center
        AND pea.personid = p.id
        AND pea.name = 'DCABasicAtHomeWorkouts'
        and p.persontype = 2
        AND pea.txtvalue <> 'true'
        and p.persontype = 2
        UNION ALL
        SELECT DISTINCT
            p.center AS home_center,
            p.external_id as "External Person ID",
            CASE
                WHEN PERSONTYPE = 0
                THEN 'PRIVATE'
                WHEN PERSONTYPE = 1
                THEN 'STUDENT'
                WHEN PERSONTYPE = 2
                THEN 'STAFF'
                WHEN PERSONTYPE = 3
                THEN 'FRIEND'
                WHEN PERSONTYPE = 4
                THEN 'CORPORATE'
                WHEN PERSONTYPE = 5
                THEN 'ONEMANCORPORATE'
                WHEN PERSONTYPE = 6
                THEN 'FAMILY'
                WHEN PERSONTYPE = 7
                THEN 'SENIOR'
                WHEN PERSONTYPE = 8
                THEN 'GUEST'
                WHEN PERSONTYPE = 9
                THEN 'CHILD'
                WHEN PERSONTYPE = 10
                THEN 'EXTERNAL_STAFF'
                ELSE 'Undefined'
            END AS "Current Person Type",
            CASE p.STATUS
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
            END       AS "Current Person State",
            pea2.name AS "Extra Attribute Name"
        FROM
            persons p
        JOIN
            params
        ON
            params.paramcenter = p.center
        AND params.paramid = p.id
        JOIN
            goodlife.person_ext_attrs pea2
        ON
            pea2.personcenter = p.center
        AND pea2.personid = p.id
        AND pea2.name = 'DCABasicInClubWorkouts'
        AND pea2.txtvalue <> 'true'
        and p.persontype = 2
        UNION ALL
        SELECT DISTINCT
            p.center AS home_center,
            p.external_id as "External Person ID",
            CASE
                WHEN PERSONTYPE = 0
                THEN 'PRIVATE'
                WHEN PERSONTYPE = 1
                THEN 'STUDENT'
                WHEN PERSONTYPE = 2
                THEN 'STAFF'
                WHEN PERSONTYPE = 3
                THEN 'FRIEND'
                WHEN PERSONTYPE = 4
                THEN 'CORPORATE'
                WHEN PERSONTYPE = 5
                THEN 'ONEMANCORPORATE'
                WHEN PERSONTYPE = 6
                THEN 'FAMILY'
                WHEN PERSONTYPE = 7
                THEN 'SENIOR'
                WHEN PERSONTYPE = 8
                THEN 'GUEST'
                WHEN PERSONTYPE = 9
                THEN 'CHILD'
                WHEN PERSONTYPE = 10
                THEN 'EXTERNAL_STAFF'
                ELSE 'Undefined'
            END AS "Current Person Type",
            CASE p.STATUS
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
            END       AS "Current Person State",
            pea3.name AS "Extra Attribute Name"
        FROM
            persons p
        JOIN
            params
        ON
            params.paramcenter = p.center
        AND params.paramid = p.id
        JOIN
            goodlife.person_ext_attrs pea3
        ON
            pea3.personcenter = p.center
        AND pea3.personid = p.id
        AND pea3.name = 'DCABasicOnDemandContent'
        AND pea3.txtvalue <> 'true'
        and p.persontype = 2
        UNION ALL
        SELECT DISTINCT
            p.center AS home_center,
            p.external_id as "External Person ID",
            CASE
                WHEN PERSONTYPE = 0
                THEN 'PRIVATE'
                WHEN PERSONTYPE = 1
                THEN 'STUDENT'
                WHEN PERSONTYPE = 2
                THEN 'STAFF'
                WHEN PERSONTYPE = 3
                THEN 'FRIEND'
                WHEN PERSONTYPE = 4
                THEN 'CORPORATE'
                WHEN PERSONTYPE = 5
                THEN 'ONEMANCORPORATE'
                WHEN PERSONTYPE = 6
                THEN 'FAMILY'
                WHEN PERSONTYPE = 7
                THEN 'SENIOR'
                WHEN PERSONTYPE = 8
                THEN 'GUEST'
                WHEN PERSONTYPE = 9
                THEN 'CHILD'
                WHEN PERSONTYPE = 10
                THEN 'EXTERNAL_STAFF'
                ELSE 'Undefined'
            END AS "Current Person Type",
            CASE p.STATUS
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
            END       AS "Current Person State",
            pea4.name AS "Extra Attribute Name"
        FROM
            persons p
        JOIN
            params
        ON
            params.paramcenter = p.center
        AND params.paramid = p.id
        JOIN
            goodlife.person_ext_attrs pea4
        ON
            pea4.personcenter = p.center
        AND pea4.personid = p.id
        AND pea4.name = 'DCABasicTrainingPlans'
        and pea4.txtvalue <> 'true'
        and p.persontype = 2
        UNION ALL
        SELECT DISTINCT
            p.center AS home_center,
            p.external_id as "External Person ID",
            CASE
                WHEN PERSONTYPE = 0
                THEN 'PRIVATE'
                WHEN PERSONTYPE = 1
                THEN 'STUDENT'
                WHEN PERSONTYPE = 2
                THEN 'STAFF'
                WHEN PERSONTYPE = 3
                THEN 'FRIEND'
                WHEN PERSONTYPE = 4
                THEN 'CORPORATE'
                WHEN PERSONTYPE = 5
                THEN 'ONEMANCORPORATE'
                WHEN PERSONTYPE = 6
                THEN 'FAMILY'
                WHEN PERSONTYPE = 7
                THEN 'SENIOR'
                WHEN PERSONTYPE = 8
                THEN 'GUEST'
                WHEN PERSONTYPE = 9
                THEN 'CHILD'
                WHEN PERSONTYPE = 10
                THEN 'EXTERNAL_STAFF'
                ELSE 'Undefined'
            END AS "Current Person Type",
            CASE p.STATUS
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
            END       AS "Current Person State",
            pea5.name AS "Extra Attribute Name"
        FROM
            persons p
        JOIN
            params
        ON
            params.paramcenter = p.center
        AND params.paramid = p.id
        JOIN
            goodlife.person_ext_attrs pea5
        ON
            pea5.personcenter = p.center
        AND pea5.personid = p.id
        AND pea5.name = 'DCAFullAtHomeWorkouts'
        and pea5.txtvalue <> 'true'
        and p.persontype = 2
        UNION ALL
        SELECT DISTINCT
            p2.center AS home_center,
           p2.external_id as "External Person ID",
            CASE
                WHEN PERSONTYPE = 0
                THEN 'PRIVATE'
                WHEN PERSONTYPE = 1
                THEN 'STUDENT'
                WHEN PERSONTYPE = 2
                THEN 'STAFF'
                WHEN PERSONTYPE = 3
                THEN 'FRIEND'
                WHEN PERSONTYPE = 4
                THEN 'CORPORATE'
                WHEN PERSONTYPE = 5
                THEN 'ONEMANCORPORATE'
                WHEN PERSONTYPE = 6
                THEN 'FAMILY'
                WHEN PERSONTYPE = 7
                THEN 'SENIOR'
                WHEN PERSONTYPE = 8
                THEN 'GUEST'
                WHEN PERSONTYPE = 9
                THEN 'CHILD'
                WHEN PERSONTYPE = 10
                THEN 'EXTERNAL_STAFF'
                ELSE 'Undefined'
            END AS "Current Person Type",
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
            END       AS "Current Person State",
            pea6.name AS "Extra Attribute Name"
        FROM
            persons p2
        JOIN
            params
        ON
            params.paramcenter = p2.center
        AND params.paramid = p2.id
        JOIN
            goodlife.person_ext_attrs pea6
        ON
            pea6.personcenter = p2.center
        AND pea6.personid = p2.id
        AND pea6.name = 'DCAFullInClubWorkouts'
        AND pea6.txtvalue <> 'true'
        and p2.persontype = 2
        UNION ALL
        SELECT DISTINCT
            p.center AS home_center,
           p.external_id as "External Person ID",
            CASE
                WHEN PERSONTYPE = 0
                THEN 'PRIVATE'
                WHEN PERSONTYPE = 1
                THEN 'STUDENT'
                WHEN PERSONTYPE = 2
                THEN 'STAFF'
                WHEN PERSONTYPE = 3
                THEN 'FRIEND'
                WHEN PERSONTYPE = 4
                THEN 'CORPORATE'
                WHEN PERSONTYPE = 5
                THEN 'ONEMANCORPORATE'
                WHEN PERSONTYPE = 6
                THEN 'FAMILY'
                WHEN PERSONTYPE = 7
                THEN 'SENIOR'
                WHEN PERSONTYPE = 8
                THEN 'GUEST'
                WHEN PERSONTYPE = 9
                THEN 'CHILD'
                WHEN PERSONTYPE = 10
                THEN 'EXTERNAL_STAFF'
                ELSE 'Undefined'
            END AS "Current Person Type",
            CASE p.STATUS
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
            END       AS "Current Person State",
            pea7.name AS "Extra Attribute Name"
        FROM
            persons p
        JOIN
            params
        ON
            params.paramcenter = p.center
        AND params.paramid = p.id
        JOIN
            goodlife.person_ext_attrs pea7
        ON
            pea7.personcenter = p.center
        AND pea7.personid = p.id
        AND pea7.name = 'DCAFullOnDemandContent'
        and p.persontype = 2
        and pea7.txtvalue <> 'true'
        UNION ALL
        SELECT DISTINCT
            p.center AS home_center,
            p.external_id as "External Person ID",
            CASE
                WHEN PERSONTYPE = 0
                THEN 'PRIVATE'
                WHEN PERSONTYPE = 1
                THEN 'STUDENT'
                WHEN PERSONTYPE = 2
                THEN 'STAFF'
                WHEN PERSONTYPE = 3
                THEN 'FRIEND'
                WHEN PERSONTYPE = 4
                THEN 'CORPORATE'
                WHEN PERSONTYPE = 5
                THEN 'ONEMANCORPORATE'
                WHEN PERSONTYPE = 6
                THEN 'FAMILY'
                WHEN PERSONTYPE = 7
                THEN 'SENIOR'
                WHEN PERSONTYPE = 8
                THEN 'GUEST'
                WHEN PERSONTYPE = 9
                THEN 'CHILD'
                WHEN PERSONTYPE = 10
                THEN 'EXTERNAL_STAFF'
                ELSE 'Undefined'
            END AS "Current Person Type",
            CASE p.STATUS
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
            END       AS "Current Person State",
            pea8.name AS "Extra Attribute Name"
        FROM
            persons p
        JOIN
            params
        ON
            params.paramcenter = p.center
        AND params.paramid = p.id
        JOIN
            goodlife.person_ext_attrs pea8
        ON
            pea8.personcenter = p.center
        AND pea8.personid = p.id
        AND pea8.name = 'DCAFullTrainingPlans'
        and pea8.txtvalue <> 'true'
        and p.persontype = 2
        UNION ALL
        SELECT DISTINCT
            p3.center AS home_center,
            p3.external_id as "External Person ID",
            CASE
                WHEN PERSONTYPE = 0
                THEN 'PRIVATE'
                WHEN PERSONTYPE = 1
                THEN 'STUDENT'
                WHEN PERSONTYPE = 2
                THEN 'STAFF'
                WHEN PERSONTYPE = 3
                THEN 'FRIEND'
                WHEN PERSONTYPE = 4
                THEN 'CORPORATE'
                WHEN PERSONTYPE = 5
                THEN 'ONEMANCORPORATE'
                WHEN PERSONTYPE = 6
                THEN 'FAMILY'
                WHEN PERSONTYPE = 7
                THEN 'SENIOR'
                WHEN PERSONTYPE = 8
                THEN 'GUEST'
                WHEN PERSONTYPE = 9
                THEN 'CHILD'
                WHEN PERSONTYPE = 10
                THEN 'EXTERNAL_STAFF'
                ELSE 'Undefined'
            END AS "Current Person Type",
            CASE p3.STATUS
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
            END       AS "Current Person State",
            pea9.name AS "Extra Attribute Name"
        FROM
            persons p3
        JOIN
            params
        ON
            params.paramcenter = p3.center
        AND params.paramid = p3.id
        JOIN
            goodlife.person_ext_attrs pea9
        ON
            pea9.personcenter = p3.center
        AND pea9.personid = p3.id
        AND pea9.name = 'DCAPremiumTrainingPlans'
        and pea9.txtvalue <> 'true'
        and p3.persontype = 2
        )        
        t
      
        group by "External Person ID","Current Person Type", "Current Person State","Current Person State","Extra Attribute Name" 
        order by 1
