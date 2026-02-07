WITH
    plist AS materialized
    (
        SELECT
            center,
            id
        FROM
            persons p
        WHERE
            p.status IN (0,
                         1,
                         2,
                         3,
                         6,
                         9)
        AND p.sex != 'C'
        AND p.center IN (700, 800, 725, 726, 727, 728, 729, 730, 732, 733, 735, 737, 743, 744, 748, 756, 759, 760, 762, 766, 778, 779, 782, 783, 7084, 731, 734, 736, 773, 7035, 7078)
    )
    ,
    center_map AS materialized
    (
        SELECT
            c.id AS OldCenterID,
            c.id AS NewCenterID
        FROM
            centers c
        WHERE
            c.id IN (700, 800, 725, 726, 727, 728, 729, 730, 732, 733, 735, 737, 743, 744, 748, 756, 759, 760, 762, 766, 778, 779, 782, 783, 7084, 731, 734, 736, 773, 7035, 7078)
    )
SELECT
    center_map.NewCenterID                              AS center_id,
    pd.GLOBALID                                         AS OldMembershipTypeId,
    pd.NAME                                             AS OldMembershipTypeName,
    COUNT(DISTINCT s.OWNER_CENTER || 'p' || s.OWNER_ID) AS PersonIds,
    COUNT(DISTINCT s.CENTER || 'ss' || s.ID)            AS total_subs,
    COUNT(DISTINCT
    CASE
        WHEN s.STATE IN (2,4,8)
        THEN s.CENTER || 'ss' || s.ID
        ELSE NULL
    END ) AS Active_subs,
    COUNT(DISTINCT
    CASE
        WHEN s.STATE NOT IN (2,4,8)
        THEN s.CENTER || 'ss' || s.ID
        ELSE NULL
    END ) AS Inactive_subs,
    COUNT(
        CASE
            WHEN
                CASE
                    WHEN (s.BINDING_END_DATE IS NOT NULL
                        AND s.BINDING_END_DATE >= CURRENT_DATE) -- replace by today
                    THEN s.BINDING_PRICE
                    ELSE s.SUBSCRIPTION_PRICE
                END = 0
            THEN s.CENTER || 'ss' || s.ID
            ELSE NULL
        END) AS free_subscriptions
FROM
    SUBSCRIPTIONS s
JOIN
    plist p
ON
    s.OWNER_CENTER=p.center
AND s.OWNER_ID=p.id
JOIN
    SUBSCRIPTIONTYPES st
ON
    s.SUBSCRIPTIONTYPE_CENTER=st.center
AND s.SUBSCRIPTIONTYPE_ID=st.id
JOIN
    PRODUCTS pd
ON
    st.center=pd.center
AND st.id=pd.id
JOIN
    center_map
ON
    center_map.OldCenterId = s.center
WHERE
    s.state IN(2,3,4,7,8)
AND s.sub_state NOT IN (6,7,8)
AND s.CREATION_TIME > 1373587200000 -- Friday, July 12, 2013
GROUP BY
    center_map.NewCenterID ,
    pd.GLOBALID ,
    pd.NAME
ORDER BY
    1,2