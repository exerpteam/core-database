SELECT distinct 
    i1.pid "Customer number",
    i1.card_id "MEMBERCARD",
    i1.firstname,
    i1.lastname,
    i1.gate "ACCESS"
FROM
    (
        SELECT
            ei.ID,
            s.OWNER_CENTER || 'p' || s.OWNER_ID pid,
            prod.EXTERNAL_ID                    gate,
            ei.IDENTITY                         card_id,
            p.FIRSTNAME,
            p.LASTNAME
        FROM
            SUBSCRIPTION_ADDON sa
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sa.SUBSCRIPTION_CENTER
            AND s.ID = sa.SUBSCRIPTION_ID
        JOIN
            PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
            AND p.ID = s.OWNER_ID
        JOIN
            MASTERPRODUCTREGISTER mpr
        ON
            mpr.id = sa.ADDON_PRODUCT_ID
        JOIN
            PRODUCTS prod
        ON
            prod.GLOBALID = mpr.GLOBALID
            AND prod.CENTER = sa.SUBSCRIPTION_CENTER
        JOIN
            ENTITYIDENTIFIERS ei
        ON
            ei.REF_TYPE = 1
            AND ei.REF_CENTER = s.OWNER_CENTER
            AND ei.REF_ID = s.OWNER_ID
            AND ei.ENTITYSTATUS = 1
            AND ((ei.IDMETHOD = 6 and prod.EXTERNAL_ID = '10002') or (ei.IDMETHOD = 4 and prod.EXTERNAL_ID = '10001'))
        WHERE
            sa.START_DATE <= exerpsysdate()
            AND (
                sa.END_DATE IS NULL
                OR sa.END_DATE > exerpsysdate() )
            AND sa.CANCELLED = 0
            /*AND prod.EXTERNAL_ID = '10002'*/
            AND s.STATE IN (2)
        UNION
        
        SELECT
            ei.ID,
            s.OWNER_CENTER || 'p' || s.OWNER_ID PersonKey,
            prod.EXTERNAL_ID                    gate,
            ei.IDENTITY                         card_id,
            p.FIRSTNAME,
            p.LASTNAME
        FROM
            SUBSCRIPTIONS s
        JOIN
            PERSONS p
        ON
            p.CENTER = s.OWNER_CENTER
            AND p.ID = s.OWNER_ID
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
            /*AND prod.EXTERNAL_ID in ('10002')*/
        JOIN
            ENTITYIDENTIFIERS ei
        ON
            ei.REF_TYPE = 1
            AND ei.REF_CENTER = s.OWNER_CENTER
            AND ei.REF_ID = s.OWNER_ID
            AND ei.ENTITYSTATUS = 1
            /*AND ei.IDMETHOD = 4*/
            AND ((ei.IDMETHOD = 6 and prod.EXTERNAL_ID = '10002') or (ei.IDMETHOD = 4 and prod.EXTERNAL_ID = '10001'))
        WHERE
            s.STATE IN (2) ) i1
