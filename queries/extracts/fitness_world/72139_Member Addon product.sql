-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    P.CENTER || 'p' || P.ID       AS medlemsnummer,
    S.ID                          AS subscription_id,
    PR.GLOBALID                   AS product_globalid

    CASE P.PERSONTYPE
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONE MAN CORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        WHEN 10 THEN 'EXTERNAL STAFF'
        ELSE 'UNKNOWN'
    END                           AS person_type,

    CASE S.STATE
        WHEN 0 THEN 'PENDING'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'CANCELLED'
        WHEN 4 THEN 'EXPIRED'
        ELSE 'UNKNOWN'
    END                           AS subscription_state,

    PR.NAME                       AS addon_name

FROM
    PERSONS P

JOIN SUBSCRIPTIONS S
    ON P.CENTER = S.OWNER_CENTER
    AND P.ID = S.OWNER_ID

JOIN PRODUCTS PR
    ON PR.CENTER = S.SUBSCRIPTIONTYPE_CENTER
    AND PR.ID = S.SUBSCRIPTIONTYPE_ID

WHERE
    P.STATUS IN (1,3)
    AND PR.NAME ILIKE '%Benify%'
;
