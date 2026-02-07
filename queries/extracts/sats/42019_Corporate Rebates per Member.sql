SELECT DISTINCT
    p.center ||'p'|| p.id                                                                                                                                   AS "Member ID",
    p.FULLNAME                                                                                                                                              AS "Member Name",
    DECODE (p.PERSONTYPE, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown') AS "Person Type",
    ca.NAME                                                                                                                                                 AS "Agreement Name",
    pp.REF_GLOBALID                                                                                                                                         AS "Product rebated",
    pp.PRICE_MODIFICATION_NAME,
    CASE
        WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
        THEN To_number(pp.PRICE_MODIFICATION_AMOUNT*100.0)|| '%'
        ELSE to_char(pp.PRICE_MODIFICATION_AMOUNT)
    END       AS "Rebate",
    pst.PRICE AS "Product Price",
    sp.PRICE  AS "Individual Price"
FROM
    persons p
JOIN
    relatives car
ON
    car.CENTER = p.center
    AND car.id = p.id
    AND car.RTYPE = 3
JOIN
    COMPANYAGREEMENTS ca
ON
    ca.center = car.RELATIVECENTER
    AND ca.id = car.RELATIVEID
    AND ca.SUBID = car.RELATIVESUBID
    AND ca.BLOCKED = 0
    AND car.STATUS = 1
JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.GRANTER_SERVICE='CompanyAgreement'
    AND pg.GRANTER_CENTER=ca.center
    AND pg.granter_id=ca.id
    AND pg.GRANTER_SUBID = ca.SUBID
    AND (
        pg.VALID_TO IS NULL
        OR pg.VALID_TO > exerpro.datetolong(TO_CHAR(exerpsysdate(), 'YYYY-MM-DD HH24:MM')))
JOIN
    PRODUCT_PRIVILEGES pp
ON
    pp.PRIVILEGE_SET = pg.PRIVILEGE_SET and pp.PRICE_MODIFICATION_NAME != 'NONE'
JOIN
    subscriptions s
ON
    s.OWNER_CENTER = p.center
    AND s.OWNER_ID = p.id
    AND s.STATE = 2
JOIN
    SUBSCRIPTIONTYPES ST
ON
    S.SUBSCRIPTIONTYPE_CENTER=ST.CENTER
    AND S.SUBSCRIPTIONTYPE_ID=ST.ID
JOIN
    PRODUCTS PST
ON
    ST.CENTER=PST.CENTER
    AND ST.ID=PST.ID
JOIN
    SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = s.center
    AND sp.SUBSCRIPTION_ID = s.id
    AND sp.TO_DATE IS NULL
    AND sp.CANCELLED = 0
WHERE
    pst.GLOBALID = pp.REF_GLOBALID
    AND p.center ||'p'|| p.id in (:MemberID)