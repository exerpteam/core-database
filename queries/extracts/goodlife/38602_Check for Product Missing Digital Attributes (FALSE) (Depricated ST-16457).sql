-- The extract is extracted from Exerp on 2026-02-08
-- Check for Product Missing Digital Attributes (FALSE)
select t."External Person ID",
t."Current Person Type",
t."Current Person State",
t."Extra Attribute Name" as "Extra Attribute Name"

FROM
    (
        WITH
            params AS
            (
                SELECT
                    s.owner_center            AS paramcenter,
                    s.owner_id                AS paramid,
                    sync.basicathomeworkouts  AS basicathomeworkouts,
                    sync.basicinclubworkouts  AS basicinclubworkouts,
                    sync.basicondemandcontent AS basicondemandcontent,
                    sync.basictrainingplans   AS basictrainingplans,
                    sync.fullathomeworkouts   AS fullathomeworkouts,
                    sync.fullinclubworkouts   AS fullinclubworkouts,
                    sync.fullondemandcontent  AS fullondemandcontent,
                    sync.fulltrainingplans    AS fulltrainingplans,
                    sync.premiumtrainingplans AS premiumtrainingplans
                FROM
                    public.sync_member_attr_new sync
                JOIN
                    products pr
                ON
                    pr.globalid = sync.globalproductid
                JOIN
                    goodlife.subscriptiontypes st
                ON
                    st.center = pr.center
                AND st.id = pr.id
                JOIN
                    goodlife.subscriptions s
                ON
                    s.subscriptiontype_center = st.center
                AND s.subscriptiontype_id = st.id
                AND s.state IN (2)
                join persons per on per.center = s.owner_center and
                 per.id = s.owner_id
				where per.persontype <> 2
				union all
				 SELECT
                    s.owner_center            AS paramcenter,
                    s.owner_id                AS paramid,
                    false  AS basicathomeworkouts,
                    false  AS basicinclubworkouts,
                    false  AS basicondemandcontent,
                    false  AS basictrainingplans,
                    false  AS fullathomeworkouts,
                    false  AS fullinclubworkouts,
                    false  AS fullondemandcontent,
                    false  AS fulltrainingplans,
                    false  AS premiumtrainingplans
                FROM
                    public.sync_member_attr_new sync
                JOIN
                    products pr
                ON
                    pr.globalid = sync.globalproductid
                JOIN
                    goodlife.subscriptiontypes st
                ON
                    st.center = pr.center
                AND st.id = pr.id
                JOIN
                    goodlife.subscriptions s
                ON
                    s.subscriptiontype_center = st.center
                AND s.subscriptiontype_id = st.id
                AND s.state IN (4)
                join persons per on per.center = s.owner_center and
                per.id = s.owner_id
	        where per.persontype <> 2
            )
        SELECT
            p.center AS home_center,
            CASE
                WHEN p.external_id IS NULL
                THEN p.center||'p'||p.id
                ELSE p.external_id
            END "External Person ID",
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
        AND pea.txtvalue != CAST(params.basicathomeworkouts AS text)
        AND pea.txtvalue = 'false'
        UNION ALL
        SELECT
            p.center AS home_center,
            CASE
                WHEN p.external_id IS NULL
                THEN p.center||'p'||p.id
                ELSE p.external_id
            END "External Person ID",
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
        AND pea2.txtvalue <> CAST(params.basicinclubworkouts AS text)
        AND pea2.txtvalue = 'false'
        UNION ALL
        SELECT
            p.center AS home_center,
            CASE
                WHEN p.external_id IS NULL
                THEN p.center||'p'||p.id
                ELSE p.external_id
            END "External Person ID",
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
        AND pea3.txtvalue != CAST(params.basicondemandcontent AS text)
        AND pea3.txtvalue = 'false'
        UNION ALL
        SELECT
            p.center AS home_center,
            CASE
                WHEN p.external_id IS NULL
                THEN p.center||'p'||p.id
                ELSE p.external_id
            END "External Person ID",
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
        AND pea4.txtvalue != CAST(params.basictrainingplans AS text)
        AND pea4.txtvalue = 'false'
        UNION ALL
        SELECT
            p.center AS home_center,
            CASE
                WHEN p.external_id IS NULL
                THEN p.center||'p'||p.id
                ELSE p.external_id
            END "External Person ID",
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
        AND pea5.txtvalue != CAST(params.fullathomeworkouts AS text)
        AND pea5.txtvalue = 'false'
        UNION ALL
        SELECT
            p.center AS home_center,
            CASE
                WHEN p.external_id IS NULL
                THEN p.center||'p'||p.id
                ELSE p.external_id
            END "External Person ID",
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
            pea6.name AS "Extra Attribute Name"
        FROM
            persons p
        JOIN
            params
        ON
            params.paramcenter = p.center
        AND params.paramid = p.id
        JOIN
            goodlife.person_ext_attrs pea6
        ON
            pea6.personcenter = p.center
        AND pea6.personid = p.id
        AND pea6.name = 'DCAFullInClubWorkouts'
        AND pea6.txtvalue != CAST(params.fullinclubworkouts AS text)
        AND pea6.txtvalue = 'false'
        UNION ALL
        SELECT
            p.center AS home_center,
            CASE
                WHEN p.external_id IS NULL
                THEN p.center||'p'||p.id
                ELSE p.external_id
            END "External Person ID",
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
        AND pea7.txtvalue != CAST(params.fullondemandcontent AS text)
        AND pea7.txtvalue = 'false'
        UNION ALL
        SELECT
            p.center AS home_center,
            CASE
                WHEN p.external_id IS NULL
                THEN p.center||'p'||p.id
                ELSE p.external_id
            END "External Person ID",
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
        AND pea8.txtvalue != CAST(params.fulltrainingplans AS text)
        AND pea8.txtvalue = 'false'
        UNION ALL
        SELECT
            p.center AS home_center,
            CASE
                WHEN p.external_id IS NULL
                THEN p.center||'p'||p.id
                ELSE p.external_id
            END "External Person ID",
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
            pea9.name AS "Extra Attribute Name"
        FROM
            persons p
        JOIN
            params
        ON
            params.paramcenter = p.center
        AND params.paramid = p.id
        JOIN
            goodlife.person_ext_attrs pea9
        ON
            pea9.personcenter = p.center
        AND pea9.personid = p.id
        AND pea9.name = 'DCAPremiumTrainingPlans'
        AND pea9.txtvalue != CAST(params.premiumtrainingplans AS text)
        AND pea9.txtvalue = 'false'
        )t        
    WHERE t.home_center IN (:Scope)
order by 1 desc
