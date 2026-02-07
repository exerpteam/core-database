WITH
    dups AS
    (
        SELECT
            pemail.txtvalue AS txtvalue,
            COUNT(*)
        FROM
            PERSONS p
        JOIN
            PERSON_EXT_ATTRS pemail
        ON
            pemail.PERSONCENTER = p.center
            AND pemail.PERSONID = p.id
            AND pemail.NAME = '_eClub_Email'
            AND pemail.txtvalue IS NOT NULL
        GROUP BY
            pemail.txtvalue
        HAVING
            COUNT(*) > 1
    )
    ,
    temp1 AS
    (
        SELECT
            dups.txtvalue                         AS email,
            pea2.personcenter||'p'||pea2.personid    per,
            p2.fullname,
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
            END AS FamilyTypeReleation,
            s2.start_date,
            s2.end_date,
            s2.subscription_price,
            CASE s2.STATE
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
            END AS SUBSCRIPTION_STATE,
            pr.name,
            row_number() OVER (Partition BY dups.txtvalue) AS rn
        FROM
            PERSON_EXT_ATTRS pea2
        JOIN
            persons p2
        ON
            p2.center = pea2.personcenter
            AND p2.id = pea2.personid
        JOIN
            dups
        ON
            pea2.txtvalue = dups.txtvalue
            AND NAME = '_eClub_Email'
        LEFT JOIN
            (
                SELECT
                    s.subscriptiontype_center,
                    s.subscriptiontype_id,
                    s.owner_center,
                    s.owner_id,
                    s.start_date,
                    s.end_date,
                    s.state,
                    s.subscription_price,
                    row_number() OVER (Partition BY s.owner_center, s.owner_id ORDER BY s.start_date DESC) rn
                FROM
                    subscriptions s
                WHERE
                    s.state IN (2,4) ) s2
        ON
            p2.center = s2.owner_center
            AND p2.id = s2.owner_id
            AND s2.rn = 1
        LEFT JOIN
            products pr
        ON
            s2.subscriptiontype_center = pr.center
            AND s2.subscriptiontype_id = pr.id
        LEFT JOIN
            relatives famrel
        ON
            famrel.center = p2.center
            AND famrel.id = p2.id
            AND famrel.rtype IN ( 19,
                                 20,
                                 21,
                                 22,
                                 23)
            AND famrel.status < 2
    )
SELECT
    email,
    MAX(
        CASE
            WHEN rn =1
            THEN per
        END) AS duplicate_1,
    MAX(
        CASE
            WHEN rn =1
            THEN fullname
        END) AS duplicate_name_1,
    MAX(
        CASE
            WHEN rn =1
            THEN PERSON_STATUS
        END) AS PERSON_STATUS_1,
    MAX(
        CASE
            WHEN rn =1
            THEN PersonType
        END) AS PERSON_TYPE_1,
    MAX(
        CASE
            WHEN rn =1
            THEN FamilyTypeReleation
        END) AS FAMILY_RELATION_TYPE_1,
    MAX(
        CASE
            WHEN rn =1
            THEN name
        END) AS Latest_Subs_Name_1,
    MAX(
        CASE
            WHEN rn =1
            THEN start_date
        END) AS Subscription_Start_1,
    MAX(
        CASE
            WHEN rn =1
            THEN end_date
        END) AS Subscription_End_1,
    MAX(
        CASE
            WHEN rn =1
            THEN SUBSCRIPTION_STATE
        END) AS Subscription_State_1,
    MAX(
        CASE
            WHEN rn =1
            THEN subscription_price
        END) AS Subscription_price_1,
    MAX(
        CASE
            WHEN rn =2
            THEN per
        END) AS duplicate_2,
    MAX(
        CASE
            WHEN rn =2
            THEN fullname
        END) AS duplicate_name_2,
    MAX(
        CASE
            WHEN rn =2
            THEN PERSON_STATUS
        END) AS PERSON_STATUS_2,
    MAX(
        CASE
            WHEN rn =2
            THEN PersonType
        END) AS PERSON_TYPE_2,
    MAX(
        CASE
            WHEN rn =2
            THEN FamilyTypeReleation
        END) AS FAMILY_RELATION_TYPE_2,		
    MAX(
        CASE
            WHEN rn =2
            THEN name
        END) AS Latest_Subs_Name_2,
    MAX(
        CASE
            WHEN rn =2
            THEN start_date
        END) AS Subscription_Start_2,
    MAX(
        CASE
            WHEN rn =2
            THEN end_date
        END) AS Subscription_End_2,
    MAX(
        CASE
            WHEN rn =2
            THEN SUBSCRIPTION_STATE
        END) AS Subscription_State_2,
    MAX(
        CASE
            WHEN rn =2
            THEN subscription_price
        END) AS Subscription_price_2,
    MAX(
        CASE
            WHEN rn =3
            THEN per
        END) AS duplicate_3,
    MAX(
        CASE
            WHEN rn =3
            THEN fullname
        END) AS duplicate_name_3,
    MAX(
        CASE
            WHEN rn =3
            THEN PERSON_STATUS
        END) AS PERSON_STATUS_3,
    MAX(
        CASE
            WHEN rn =3
            THEN PersonType
        END) AS PERSON_TYPE_3,
    MAX(
        CASE
            WHEN rn =3
            THEN FamilyTypeReleation
        END) AS FAMILY_RELATION_TYPE_3,		
    MAX(
        CASE
            WHEN rn =3
            THEN name
        END) AS Latest_Subs_Name_3,
    MAX(
        CASE
            WHEN rn =3
            THEN start_date
        END) AS Subscription_Start_3,
    MAX(
        CASE
            WHEN rn =3
            THEN end_date
        END) AS Subscription_End_3,
    MAX(
        CASE
            WHEN rn =3
            THEN SUBSCRIPTION_STATE
        END) AS Subscription_State_3,
    MAX(
        CASE
            WHEN rn =3
            THEN subscription_price
        END) AS Subscription_price_3,
    MAX(
        CASE
            WHEN rn =4
            THEN per
        END) AS duplicate_4,
    MAX(
        CASE
            WHEN rn =4
            THEN fullname
        END) AS duplicate_name_4,
    MAX(
        CASE
            WHEN rn =4
            THEN PERSON_STATUS
        END) AS PERSON_STATUS_4,
    MAX(
        CASE
            WHEN rn =4
            THEN PersonType
        END) AS PERSON_TYPE_4,
    MAX(
        CASE
            WHEN rn =4
            THEN FamilyTypeReleation
        END) AS FAMILY_RELATION_TYPE_4,		
    MAX(
        CASE
            WHEN rn =4
            THEN name
        END) AS Latest_Subs_Name_4,
    MAX(
        CASE
            WHEN rn =4
            THEN start_date
        END) AS Subscription_Start_4,
    MAX(
        CASE
            WHEN rn =4
            THEN end_date
        END) AS Subscription_End_4,
    MAX(
        CASE
            WHEN rn =4
            THEN SUBSCRIPTION_STATE
        END) AS Subscription_State_4,
    MAX(
        CASE
            WHEN rn =4
            THEN subscription_price
        END) AS Subscription_price_4,
    MAX(
        CASE
            WHEN rn =5
            THEN per
        END) AS duplicate_5,
    MAX(
        CASE
            WHEN rn =5
            THEN fullname
        END) AS duplicate_name_5,
    MAX(
        CASE
            WHEN rn =5
            THEN PERSON_STATUS
        END) AS PERSON_STATUS_5,
    MAX(
        CASE
            WHEN rn =5
            THEN PersonType
        END) AS PERSON_TYPE_5,
    MAX(
        CASE
            WHEN rn =5
            THEN FamilyTypeReleation
        END) AS FAMILY_RELATION_TYPE_5,		
    MAX(
        CASE
            WHEN rn =5
            THEN name
        END) AS Latest_Subs_Name_5,
    MAX(
        CASE
            WHEN rn =5
            THEN start_date
        END) AS Subscription_Start_5,
    MAX(
        CASE
            WHEN rn =5
            THEN end_date
        END) AS Subscription_End_5,
    MAX(
        CASE
            WHEN rn =5
            THEN SUBSCRIPTION_STATE
        END) AS Subscription_State_5,
    MAX(
        CASE
            WHEN rn =5
            THEN subscription_price
        END) AS Subscription_price_5,
    MAX(
        CASE
            WHEN rn =6
            THEN per
        END) AS duplicate_6,
    MAX(
        CASE
            WHEN rn =6
            THEN fullname
        END) AS duplicate_name_6,
    MAX(
        CASE
            WHEN rn =6
            THEN PERSON_STATUS
        END) AS PERSON_STATUS_6,
    MAX(
        CASE
            WHEN rn =6
            THEN PersonType
        END) AS PERSON_TYPE_6,
    MAX(
        CASE
            WHEN rn =6
            THEN FamilyTypeReleation
        END) AS FAMILY_RELATION_TYPE_6,		
    MAX(
        CASE
            WHEN rn =6
            THEN name
        END) AS Latest_Subs_Name_6,
    MAX(
        CASE
            WHEN rn =6
            THEN start_date
        END) AS Subscription_Start_6,
    MAX(
        CASE
            WHEN rn =6
            THEN end_date
        END) AS Subscription_End_6,
    MAX(
        CASE
            WHEN rn =6
            THEN SUBSCRIPTION_STATE
        END) AS Subscription_State_6,
    MAX(
        CASE
            WHEN rn =6
            THEN subscription_price
        END) AS Subscription_price_6,
    MAX(
        CASE
            WHEN rn =7
            THEN per
        END) AS duplicate_7,
    MAX(
        CASE
            WHEN rn =7
            THEN fullname
        END) AS duplicate_name_7,
    MAX(
        CASE
            WHEN rn =7
            THEN PERSON_STATUS
        END) AS PERSON_STATUS_7,
    MAX(
        CASE
            WHEN rn =7
            THEN PersonType
        END) AS PERSON_TYPE_7,
    MAX(
        CASE
            WHEN rn =7
            THEN FamilyTypeReleation
        END) AS FAMILY_RELATION_TYPE_7,		
    MAX(
        CASE
            WHEN rn =7
            THEN name
        END) AS Latest_Subs_Name_7,
    MAX(
        CASE
            WHEN rn =7
            THEN start_date
        END) AS Subscription_Start_7,
    MAX(
        CASE
            WHEN rn =7
            THEN end_date
        END) AS Subscription_End_7,
    MAX(
        CASE
            WHEN rn =7
            THEN SUBSCRIPTION_STATE
        END) AS Subscription_State_7,
    MAX(
        CASE
            WHEN rn =7
            THEN subscription_price
        END) AS Subscription_price_7,
    MAX(
        CASE
            WHEN rn =8
            THEN per
        END) AS duplicate_8,
    MAX(
        CASE
            WHEN rn =8
            THEN fullname
        END) AS duplicate_name_8,
    MAX(
        CASE
            WHEN rn =8
            THEN PERSON_STATUS
        END) AS PERSON_STATUS_8,
    MAX(
        CASE
            WHEN rn =8
            THEN PersonType
        END) AS PERSON_TYPE_8,
    MAX(
        CASE
            WHEN rn =8
            THEN FamilyTypeReleation
        END) AS FAMILY_RELATION_TYPE_8,		
    MAX(
        CASE
            WHEN rn =8
            THEN name
        END) AS Latest_Subs_Name_8,
    MAX(
        CASE
            WHEN rn =8
            THEN start_date
        END) AS Subscription_Start_8,
    MAX(
        CASE
            WHEN rn =8
            THEN end_date
        END) AS Subscription_End_8,
    MAX(
        CASE
            WHEN rn =8
            THEN SUBSCRIPTION_STATE
        END) AS Subscription_State_8,
    MAX(
        CASE
            WHEN rn =8
            THEN subscription_price
        END) AS Subscription_price_8,
    MAX(
        CASE
            WHEN rn =9
            THEN per
        END) AS duplicate_9,
    MAX(
        CASE
            WHEN rn =9
            THEN fullname
        END) AS duplicate_name_9,
    MAX(
        CASE
            WHEN rn =9
            THEN PERSON_STATUS
        END) AS PERSON_STATUS_9,
    MAX(
        CASE
            WHEN rn =9
            THEN PersonType
        END) AS PERSON_TYPE_9,
    MAX(
        CASE
            WHEN rn =9
            THEN FamilyTypeReleation
        END) AS FAMILY_RELATION_TYPE_9,		
    MAX(
        CASE
            WHEN rn =9
            THEN name
        END) AS Latest_Subs_Name_9,
    MAX(
        CASE
            WHEN rn =9
            THEN start_date
        END) AS Subscription_Start_9,
    MAX(
        CASE
            WHEN rn =9
            THEN end_date
        END) AS Subscription_End_9,
    MAX(
        CASE
            WHEN rn =9
            THEN SUBSCRIPTION_STATE
        END) AS Subscription_State_9,
    MAX(
        CASE
            WHEN rn =9
            THEN subscription_price
        END) AS Subscription_price_9,
    MAX(
        CASE
            WHEN rn =10
            THEN per
        END) AS duplicate_10,
    MAX(
        CASE
            WHEN rn =10
            THEN fullname
        END) AS duplicate_name_10,
    MAX(
        CASE
            WHEN rn =10
            THEN PERSON_STATUS
        END) AS PERSON_STATUS_10,
    MAX(
        CASE
            WHEN rn =10
            THEN PersonType
        END) AS PERSON_TYPE_10,
    MAX(
        CASE
            WHEN rn =10
            THEN FamilyTypeReleation
        END) AS FAMILY_RELATION_TYPE_10,		
    MAX(
        CASE
            WHEN rn =10
            THEN name
        END) AS Latest_Subs_Name_10,
    MAX(
        CASE
            WHEN rn =10
            THEN start_date
        END) AS Subscription_Start_10,
    MAX(
        CASE
            WHEN rn =10
            THEN end_date
        END) AS Subscription_End_10,
    MAX(
        CASE
            WHEN rn =10
            THEN SUBSCRIPTION_STATE
        END) AS Subscription_State_10,
    MAX(
        CASE
            WHEN rn =10
            THEN subscription_price
        END) AS Subscription_price_10
FROM
    temp1
GROUP BY
    email