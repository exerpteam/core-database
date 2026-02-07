-- This is the version from 2026-02-05
-- Created to find all Nordylland members
SELECT
            *
        FROM
            SUBSCRIPTIONS s
        JOIN SUBSCRIPTION_FREEZE_PERIOD sfp
        ON
            sfp.SUBSCRIPTION_CENTER = s.CENTER
            AND sfp.SUBSCRIPTION_ID = s.ID
        WHERE
            sfp.STATE = 'ACTIVE'
           -- AND s.OWNER_CENTER = p.CENTER
            --AND s.OWNER_ID = p.ID
            AND sfp.START_DATE BETWEEN :periodStart AND :periodEnd
                               OR
                sfp.END_DATE BETWEEN :periodStart AND :periodEnd
                