-- The extract is extracted from Exerp on 2026-02-08
--  
ELECT
	sub.OWNER_CENTER sub.OWNER_ID  AS PersonId,
	sub.center|| 'ss' || sub.id AS subid,
	DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'RecurringClips') as MEMBERSHIP_TYPE,
	sub.START_DATE,
	sub.END_DATE,
	longtodate(term.CHANGE_TIME) terminationDate,
	sub.binding_END_DATE, 
	sub.SUBSCRIPTION_PRICE,
	prod.NAME AS Product_Name,
  DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS subscription_STATE,
    DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','CHANGE')  AS SUBSCRIPTION_SUB_STATE,
	    CASE
        WHEN priv.SPONSORSHIP_NAME IS NOT NULL
        THEN priv.SPONSORSHIP_NAME
        ELSE NULL
    END AS Sponsorship
	-------------------------------------------------------------
FROM
    SUBSCRIPTIONS sub
JOIN
    CENTERS center
ON
    sub.center = center.id
JOIN
    PERSONS p
ON
    sub.owner_center = p.center
    AND sub.owner_id = p.id
JOIN
    SUBSCRIPTIONTYPES st
ON
    sub.SUBSCRIPTIONTYPE_CENTER = st.center
    AND sub.SUBSCRIPTIONTYPE_ID = st.id
	
LEFT JOIN
    (
        SELECT
			sc.OLD_SUBSCRIPTION_CENTER, 
			sc.OLD_SUBSCRIPTION_ID,
            sc.CHANGE_TIME
           
        FROM
            SUBSCRIPTION_CHANGE sc
        WHERE
           sc.type = 'END_DATE'
        AND sc.CANCEL_TIME IS NULL
       
    )
    term
ON
    term.OLD_SUBSCRIPTION_CENTER = sub.center
AND term.OLD_SUBSCRIPTION_ID = sub.id	

JOIN
    PRODUCTS prod
ON
    st.center = prod.center
    AND st.id = prod.id

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
                OR pg.VALID_TO > datetolong(TO_CHAR(exerpsysdate(), 'YYYY-MM-DD HH24:MM')) )
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
    AND priv.REF_GLOBALID = prod.GLOBALID
WHERE
    p.center IN ($$scope$$)
AND sub.SUB_STATE != 8
		

	
		AND sub.START_DATE <= date '2019-10-31' -- Date
	AND
		(sub.END_DATE IS NULL
		OR sub.END_DATE >= date '2019-10-31') -- Date
		
		

