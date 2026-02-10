-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS MATERIALIZED
(
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST('2025-03-01' AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST('2025-03-31' AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c  
)
SELECT
        p.center||'p'||p.id AS PersonID
        ,p.external_id
        ,p.fullname
        ,pea.txtvalue AS "LegacyID"
        ,CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE
        ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS
        ,c.id AS "Club ID"
        ,c.name AS "Club"
        ,pr.name AS "Subscription Name"
        ,s.start_date
        ,s.end_date
        ,NULL AS "Suspend On Date"
        ,CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE
        ,CASE s.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS SUBSCRIPTION_SUB_STATE
        ,'Leaver' AS type
        ,CASE
                WHEN s.creator_center||'emp'||s.creator_id = '100emp1' THEN 'Yes'
                ELSE 'No'
        END AS "Migrated"
FROM
        evolutionwellness.persons p
JOIN 
        params par 
        ON p.center = par.CENTER_ID
LEFT JOIN 
        evolutionwellness.person_ext_attrs pea
        ON p.center = pea.personcenter 
        AND p.id = pea.personid 
        AND pea.name = '_eClub_OldSystemPersonId' 
        AND pea.txtvalue IS NOT NULL
JOIN 
        evolutionwellness.subscriptions s 
        ON p.center = s.owner_center 
        AND p.id = s.owner_id
JOIN 
        evolutionwellness.subscriptiontypes st 
        ON s.subscriptiontype_center = st.center 
        AND s.subscriptiontype_id = st.id
JOIN 
        evolutionwellness.products pr 
        ON st.center = pr.center 
        AND st.id = pr.id
JOIN
        evolutionwellness.centers c 
        ON c.id = p.center   
LEFT JOIN
        evolutionwellness.product_and_product_group_link pgl
        ON pgl.product_center = pr.center
        AND pgl.product_id = pr.id
        AND pgl.product_group_id IN (205,1601,3401,455,682,4012)   
LEFT JOIN
        evolutionwellness.PERSON_EXT_ATTRS trd
        ON trd.PERSONCENTER= p.CENTER
        AND trd.PERSONID= p.ID
        AND trd.NAME = '_eClub_TransferredToId'                  
WHERE
        s.center IN (:Scope)
        AND
        s.end_date BETWEEN '2025-03-01' AND '2025-03-31'
        AND
        p.external_id IS NOT NULL
        AND 
        pgl.product_group_id IS NULL
        AND 
        trd.txtvalue IS NULL
        AND
        s.SUB_STATE != 7
        AND
        p.STATUS = 2
UNION ALL
SELECT 
        p.center||'p'||p.id AS PersonID
        ,p.external_id
        ,p.fullname
        ,pea.txtvalue AS "LegacyID"
        ,CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE
        ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS
        ,c.id AS "Club ID"
        ,c.name AS "Club"
        ,pr.name AS "Subscription Name"
        ,s.start_date
        ,s.end_date
        ,cc.startdate AS "Suspend On Date"
        ,CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS SUBSCRIPTION_STATE
        ,CASE s.SUB_STATE WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS SUBSCRIPTION_SUB_STATE
        ,'Suspend on' AS type
        ,CASE
                WHEN s.creator_center||'emp'||s.creator_id = '100emp1' THEN 'Yes'
                ELSE 'No'
        END AS "Migrated"
FROM
        evolutionwellness.persons p
JOIN
        evolutionwellness.cashcollectioncases cc
        ON cc.personcenter = p.center
        AND cc.personid = p.id
        AND cc.closed IS FALSE
        AND cc.missingpayment IS FALSE
LEFT JOIN 
        evolutionwellness.person_ext_attrs pea
        ON p.center = pea.personcenter 
        AND p.id = pea.personid 
        AND pea.name = '_eClub_OldSystemPersonId' 
        AND pea.txtvalue IS NOT NULL
JOIN 
        evolutionwellness.subscriptions s 
        ON p.center = s.owner_center 
        AND p.id = s.owner_id
JOIN 
        evolutionwellness.subscriptiontypes st 
        ON s.subscriptiontype_center = st.center 
        AND s.subscriptiontype_id = st.id
JOIN 
        evolutionwellness.products pr 
        ON st.center = pr.center 
        AND st.id = pr.id 
JOIN
        evolutionwellness.centers c 
        ON c.id = p.center   
LEFT JOIN
        evolutionwellness.product_and_product_group_link pgl
        ON pgl.product_center = pr.center
        AND pgl.product_id = pr.id
        AND pgl.product_group_id IN (205,1601,3401,455,682,4012)  
WHERE 
        p.center IN (:Scope)
        AND
        cc.startdate BETWEEN '2025-03-01' AND '2025-03-31'
        AND 
        p.PERSONTYPE != 2             
                        