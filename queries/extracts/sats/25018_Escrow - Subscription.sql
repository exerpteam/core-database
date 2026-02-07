with params AS MATERIALIZED
(
	SELECT
		datetolongC(getCenterTime(c.id),c.id) AS todays_longdate,
		to_date(getCenterTime(c.id),'YYYY-MM-DD') AS todays_date,
		c.id
	FROM CENTERS c
)
SELECT
        center.ID centerId,
        center.NAME centerName,
        s.OWNER_CENTER || 'p' || s.OWNER_ID AS personid,
        s.center || 'ss' || s.id AS MembershipId,
        TO_CHAR(longtodate(s.CREATION_TIME), 'YYYY-MM-DD') AS CreationDate,
        TO_CHAR(s.START_DATE, 'YYYY-MM-DD') AS StartDate,
        TO_CHAR(s.END_DATE, 'YYYY-MM-DD') AS EndDate,
        pd.GLOBALID AS GlobalName,
        pd.name AS Name,
        (CASE st.st_type WHEN 0 THEN 'CASH' WHEN  1 THEN  'DD' END) AS MembershipType,
        (CASE WHEN s.binding_end_date IS NULL THEN NULL
                ELSE s.binding_price
        END) AS binding_price,
        TO_CHAR(s.binding_end_date, 'YYYY-MM-DD') bindingenddate,
        s.SUBSCRIPTION_PRICE,
        CASE
                WHEN st.st_type = 0
                THEN TO_CHAR(s.end_date, 'YYYY-MM-DD')
                ELSE TO_CHAR(s.BILLED_UNTIL_DATE, 'YYYY-MM-DD')
        END AS BilledUntilDate ,
        CASE
                WHEN st.ST_TYPE = 1 AND priv.SPONSORSHIP_NAME IS NOT NULL
                THEN priv.SPONSORSHIP_NAME
                ELSE NULL
        END AS Sponsorship ,
        CASE
                WHEN st.ST_TYPE = 1 AND priv.SPONSORSHIP_NAME IS NOT NULL
                THEN priv.SPONSORSHIP_AMOUNT
                ELSE NULL
        END AS Sponsorship_amount,
        fr.start_date AS freezefrom,
        fr.end_date AS FreezeTo,
        fr.text AS FreezeReason
FROM sats.subscriptions s
JOIN params ON s.center = params.id
JOIN sats.centers center
        ON s.center = center.id
JOIN sats.persons p
        ON s.OWNER_CENTER=p.center
        AND s.OWNER_ID=p.id
JOIN sats.subscriptiontypes st
        ON s.subscriptiontype_center=st.center
        AND s.subscriptiontype_id=st.id
JOIN sats.products pd
        ON st.center=pd.center
        AND st.id=pd.id
LEFT JOIN sats.subscription_freeze_period fr
        ON fr.subscription_center = s.center
        AND fr.subscription_id = s.id
        AND fr.cancel_time IS NULL
        AND fr.end_date > params.todays_date    
LEFT JOIN
(
        SELECT
            car.center,
            car.id,
            pg.SPONSORSHIP_NAME,
            pp.REF_GLOBALID,
            pg.SPONSORSHIP_AMOUNT
        FROM relatives car
        JOIN PARAMS ON car.center = params.id
        JOIN COMPANYAGREEMENTS ca
                ON ca.center = car.RELATIVECENTER
                AND ca.id = car.RELATIVEID
                AND ca.SUBID = car.RELATIVESUBID
        JOIN PRIVILEGE_GRANTS pg
                ON pg.GRANTER_SERVICE='CompanyAgreement'
                AND pg.GRANTER_CENTER=ca.center
                AND pg.granter_id=ca.id
                AND pg.GRANTER_SUBID = ca.SUBID
                AND pg.SPONSORSHIP_NAME!= 'NONE'
                AND
                (
                        pg.VALID_TO IS NULL OR pg.VALID_TO > params.todays_longdate
                )
        JOIN PRODUCT_PRIVILEGES pp
                ON pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        WHERE
                car.RTYPE = 3
                AND car.STATUS < 3
                AND car.center = :scope
        GROUP BY
                car.center,
                car.id,
                pg.SPONSORSHIP_NAME,
                pp.REF_GLOBALID,
                pg.SPONSORSHIP_AMOUNT
) priv
        ON priv.center=p.center
        AND priv.id = p.id
        AND priv.REF_GLOBALID = pd.GLOBALID
WHERE
            p.center = :scope
            AND s.STATE IN (2,4,8)
            AND p.STATUS NOT IN (4,5,7,8)
            AND p.sex != 'C'
            AND p.PERSONTYPE NOT IN (2,8)
ORDER BY
        p.center,
        p.id 