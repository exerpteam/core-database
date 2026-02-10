-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    elig_subs AS
    (
        SELECT
            old_subscription_center AS center ,
            old_subscription_id     AS id,
            owner_center ,
            owner_id,
            last_end_date
        FROM
            (
                SELECT
                    sc.*,
                    lsc.effect_date AS last_end_date,
                    s.owner_center,
                    s.owner_id,
                    row_number() over (partition BY s.center,s.id ORDER BY lsc.change_time DESC) AS
                    rnk
                FROM
                    subscriptions s
                JOIN
                    subscription_change sc
                ON
                    sc.old_subscription_center = s.center
                AND sc.old_subscription_id = s.id
                JOIN
                    subscriptiontypes st
                ON
                    st.center=s.subscriptiontype_center
                AND st.id = s.subscriptiontype_id
                LEFT JOIN
                    subscription_change lsc
                ON
                    lsc.old_subscription_center = s.center
                AND lsc.old_subscription_id = s.id
                AND lsc.change_time < sc.change_time
                AND ( lsc.cancel_time IS NULL
                    OR  lsc.cancel_time > 1680307200000) -- april 1st
                WHERE
                    sc.change_time BETWEEN 1680307200000 AND 1682899200000 --april 1st until may 1st
                AND sc.type = 'END_DATE'
                AND sc.effect_date = '2023-04-30'
                AND sc.cancel_time IS NULL
                AND s.center = 207
                AND sc.employee_center = 200
                AND sc.employee_id = 7403) t1
        WHERE
            rnk = 1
    )
SELECT
    center.ID                                          centerId,
    center.NAME                                        centerName,
    s.OWNER_CENTER || 'p' || s.OWNER_ID                AS personid,
    s.center || 'ss' || s.id                           AS MembershipId,
    TO_CHAR(longtodate(s.CREATION_TIME), 'YYYY-MM-DD') AS CreationDate,
    TO_CHAR(s.START_DATE, 'YYYY-MM-DD')                AS StartDate,
    TO_CHAR(es.last_end_date, 'YYYY-MM-DD')            AS EndDate,
    pd.GLOBALID                                        AS GlobalName,
    pd.name                                            AS Name,
    CASE st.st_type
        WHEN 0
        THEN 'CASH'
        WHEN 1
        THEN 'DD'
    END AS MembershipType,
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
    END                         AS Sponsorship_amount,
    spons.center||'p'||spons.id AS sponsor_id,
    spons.fullname              AS sponsor_name
FROM
    elig_subs es
JOIN
    SUBSCRIPTIONS s
ON
    es.center = s.center
AND es.id = s.id
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
            car.center,
            car.id,
            car.relativecenter AS spons_center,
            car.relativeid     AS spons_id,
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
        AND ( pg.VALID_TO IS NULL
            OR  pg.VALID_TO > datetolong(TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MM')) )
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        WHERE
            car.RTYPE = 3
        AND car.STATUS < 3
        GROUP BY
            car.center,
            car.id,
            pg.SPONSORSHIP_NAME,
            pp.REF_GLOBALID,
            pg.SPONSORSHIP_AMOUNT,
            car.relativecenter,
            car.relativeid ) priv
ON
    priv.center=p.center
AND priv.id = p.id
AND priv.REF_GLOBALID = pd.GLOBALID
LEFT JOIN
    persons spons
ON
    spons.center = priv.spons_center
AND spons.id = priv.spons_id
WHERE
     p.sex != 'C'
ORDER BY
    p.center,
    p.id