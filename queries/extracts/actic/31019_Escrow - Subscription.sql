-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4236
-- Parameters: Center(SCOPE)
SELECT
    center.ID                                          centerId,
	center.external_id,
    center.NAME                                        centerName,
    s.OWNER_CENTER || 'p' || s.OWNER_ID                AS personid,
    s.center || 'ss' || s.id                           AS MembershipId,
    TO_CHAR(longtodate(s.CREATION_TIME), 'YYYY-MM-DD') AS CreationDate,
    TO_CHAR(s.START_DATE, 'YYYY-MM-DD')                AS StartDate,
    TO_CHAR(s.END_DATE, 'YYYY-MM-DD')                  AS EndDate,
    pd.GLOBALID                                        AS GlobalName,
    pd.name                                            AS Name,
    CASE st.st_type  WHEN 0 THEN  'CASH'  WHEN 1 THEN  'DD' END             AS MembershipType,
    s.BINDING_PRICE,
    TO_CHAR(s.BINDING_END_DATE, 'YYYY-MM-DD') bindingenddate,
    s.SUBSCRIPTION_PRICE,
    CASE
        WHEN st.st_type = 0
        THEN TO_CHAR(s.end_date, 'YYYY-MM-DD')
        ELSE TO_CHAR(s.BILLED_UNTIL_DATE, 'YYYY-MM-DD')
    END AS BilledUntilDate ,
    CASE
        WHEN st.ST_TYPE = 1
            AND priv.SPONSORSHIP_NAME IS NOT NULL
        THEN priv.SPONSORSHIP_NAME
        ELSE NULL
    END AS Sponsorship ,
    CASE
        WHEN st.ST_TYPE = 1
            AND priv.SPONSORSHIP_NAME IS NOT NULL
        THEN priv.SPONSORSHIP_AMOUNT
        ELSE NULL
    END AS Sponsorship_amount,
    fh.FreezeFrom,
    fh.FreezeTo,
    fh.FreezeReason
FROM
    SUBSCRIPTIONS s
JOIN
    CENTERS center
ON
    s.center = center.id
JOIN
    PERSONS p
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
LEFT JOIN
    (
        SELECT
            fr.subscription_center,
            fr.subscription_id,
            TO_CHAR(MIN(fr.START_DATE), 'YYYY-MM-DD') AS FreezeFrom,
            TO_CHAR(MAX(fr.END_DATE), 'YYYY-MM-DD')   AS FreezeTo,
            MIN(fr.text)                              AS FreezeReason
        FROM
            SUBSCRIPTION_FREEZE_PERIOD fr
        WHERE
            fr.subscription_center IN ($$scope$$)
            AND fr.END_DATE > current_timestamp
        GROUP BY
            fr.subscription_center,
            fr.subscription_id ) fh
ON
    fh.subscription_center = s.center
    AND fh.subscription_id = s.id
LEFT JOIN
    (
        SELECT
            car.center,
            car.id,
            pg.SPONSORSHIP_NAME,
            pp.REF_GLOBALID,
            pg.SPONSORSHIP_AMOUNT
        FROM
            relatives car
        JOIN
            COMPANYAGREEMENTS ca
        ON
            ca.center = car.RELATIVECENTER
            AND ca.id = car.RELATIVEID
            AND ca.SUBID = car.RELATIVESUBID
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_SERVICE='CompanyAgreement'
            AND pg.GRANTER_CENTER=ca.center
            AND pg.granter_id=ca.id
            AND pg.GRANTER_SUBID = ca.SUBID
            AND pg.SPONSORSHIP_NAME!= 'NONE'
            AND (
                pg.VALID_TO IS NULL
                OR pg.VALID_TO > datetolong(TO_CHAR(current_timestamp, 'YYYY-MM-DD HH24:MM')) )
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        WHERE
            car.RTYPE = 3
            AND car.STATUS < 3
            AND car.center IN ($$scope$$)
        GROUP BY
            car.center,
            car.id,
            pg.SPONSORSHIP_NAME,
            pp.REF_GLOBALID,
            pg.SPONSORSHIP_AMOUNT ) priv
ON
    priv.center=p.center
    AND priv.id = p.id
    AND priv.REF_GLOBALID = pd.GLOBALID
WHERE
    p.center IN ($$scope$$)
    AND s.STATE IN (2,4,8)
    AND p.STATUS IN (1,3)
    AND p.sex != 'C'
    AND p.PERSONTYPE NOT IN (2,8)
ORDER BY
    p.center,
    p.id
