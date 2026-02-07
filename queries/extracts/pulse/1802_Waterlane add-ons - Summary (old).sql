SELECT
    product,
    COUNT(price) members,
    price productprice,
    SUBSCRIPTION_PRICE,
    SUM(price) total,
    SUM(pulseaddons) pulseaddons,
    SUM(otheraddons) otheraddons
FROM
    (
        SELECT
            s.OWNER_CENTER || 'p' || s.OWNER_ID personid,
            per.FIRSTNAME || ' ' || per.LASTNAME name,
            p.NAME product,
            p.PRICE,
            s.SUBSCRIPTION_PRICE,
            SUM(addons.Pulse_Addons) pulseAddons,
            SUM(addons.Other_Addons) otherAddons
        FROM
            PULSE.SUBSCRIPTIONS s
        JOIN PULSE.PRODUCTS p
        ON
            p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND p.ID = s.SUBSCRIPTIONTYPE_ID
        JOIN PULSE.PRODUCT_GROUP pg
        ON
            p.PRIMARY_PRODUCT_GROUP_ID = pg.ID
        JOIN PULSE.PERSONS per
        ON
            per.CENTER = s.OWNER_CENTER
            AND per.id = s.OWNER_ID
        JOIN
            (
                SELECT
                    s.OWNER_CENTER,
                    s.OWNER_ID,
                    p.NAME,
                    s.START_DATE,
                    s.END_DATE,
                    CASE
                        WHEN P.id IN (1628,1837,1861)
                        THEN 1
                        ELSE 0
                    END Pulse_Addons,
                    CASE
                        WHEN P.id NOT IN (1628,1837,1861)
                        THEN 1
                        ELSE 0
                    END Other_Addons
                FROM
                    PULSE.SUBSCRIPTIONS s
                JOIN PULSE.PRODUCTS p
                ON
                    p.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND p.ID = s.SUBSCRIPTIONTYPE_ID
                JOIN PULSE.PRODUCT_GROUP pg
                ON
                    p.PRIMARY_PRODUCT_GROUP_ID = pg.ID
                JOIN PULSE.PERSONS per
                ON
                    per.CENTER = s.OWNER_CENTER
                    AND per.id = s.OWNER_ID
                WHERE
                    s.center = :scope
                    AND s.STATE IN (2,4)
                    AND pg.ID IN (1208)
            )
            addons
        ON
            addons.owner_center = per.center
            AND addons.owner_id = per.id
        WHERE
            s.center = :scope
            AND s.STATE IN (2,4)
            AND pg.ID NOT IN (1208)
        GROUP BY
            s.OWNER_CENTER,
            s.OWNER_ID,
            per.FIRSTNAME || ' ' || per.LASTNAME,
            p.NAME,
            p.price,
            s.SUBSCRIPTION_PRICE
    )
GROUP BY
    product,
    price,
    SUBSCRIPTION_PRICE
order by 1