WITH
    product_spons_pg AS
    (
        SELECT
            ca.center,
            ca.id,
            ca.subid,
            pr.globalid,
            pg.SPONSORSHIP_NAME,
            pg.SPONSORSHIP_AMOUNT
        FROM
            products pr
        JOIN
            product_and_product_group_link ppgl
        ON
            ppgl.product_center = pr.center
        AND ppgl.product_id = pr.id
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            (
                pp.ref_type = 'PRODUCT_GROUP'
            AND pp.ref_id = ppgl.product_group_id)
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        AND pg.SPONSORSHIP_NAME!= 'NONE'
        AND (
                pg.VALID_TO IS NULL
            OR  pg.VALID_TO > datetolong(TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MM')) )
        AND pg.GRANTER_SERVICE='CompanyAgreement'
        JOIN
            COMPANYAGREEMENTS ca
        ON
            pg.GRANTER_CENTER=ca.center
        AND pg.granter_id=ca.id
        AND pg.granter_subid = ca.subid
        GROUP BY
            ca.center,
            ca.id,
            ca.subid,
            pr.globalid,
            pg.SPONSORSHIP_NAME,
            pg.SPONSORSHIP_AMOUNT
    )
    ,
    product_spons_global AS
    (
        SELECT
            ca.center,
            ca.id,
            ca.subid,
            pr.globalid,
            pg.SPONSORSHIP_NAME,
            pg.SPONSORSHIP_AMOUNT
        FROM
            products pr
        JOIN
            product_and_product_group_link ppgl
        ON
            ppgl.product_center = pr.center
        AND ppgl.product_id = pr.id
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            (
                pp.ref_type = 'GLOBAL_PRODUCT'
            AND pp.REF_GLOBALID = pr.globalid)
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        AND pg.SPONSORSHIP_NAME!= 'NONE'
        AND (
                pg.VALID_TO IS NULL
            OR  pg.VALID_TO > datetolong(TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MM')) )
        AND pg.GRANTER_SERVICE='CompanyAgreement'
        JOIN
            COMPANYAGREEMENTS ca
        ON
            pg.GRANTER_CENTER=ca.center
        AND pg.granter_id=ca.id
        AND pg.granter_subid = ca.subid
        GROUP BY
            ca.center,
            ca.id,
            ca.subid,
            pr.globalid,
            pg.SPONSORSHIP_NAME,
            pg.SPONSORSHIP_AMOUNT
    )
    ,
    product_spons_local AS
    (
        SELECT
            ca.center,
            ca.id,
            ca.subid,
            pr.globalid,
            pg.SPONSORSHIP_NAME,
            pg.SPONSORSHIP_AMOUNT
        FROM
            products pr
        JOIN
            product_and_product_group_link ppgl
        ON
            ppgl.product_center = pr.center
        AND ppgl.product_id = pr.id
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            (
                pp.ref_type = 'LOCAL_PRODUCT'
            AND pp.REF_CENTER = pr.center
            AND pp.REF_ID = pr.id)
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        AND pg.SPONSORSHIP_NAME!= 'NONE'
        AND (
                pg.VALID_TO IS NULL
            OR  pg.VALID_TO > datetolong(TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MM')) )
        AND pg.GRANTER_SERVICE='CompanyAgreement'
        JOIN
            COMPANYAGREEMENTS ca
        ON
            pg.GRANTER_CENTER=ca.center
        AND pg.granter_id=ca.id
        AND pg.granter_subid = ca.subid
        GROUP BY
            ca.center,
            ca.id,
            ca.subid,
            pr.globalid,
            pg.SPONSORSHIP_NAME,
            pg.SPONSORSHIP_AMOUNT
    )
SELECT
    center.ID                                          centerId,
    center.NAME                                        centerName,
	p.status										   AS staus,
    s.OWNER_CENTER || 'p' || s.OWNER_ID                AS personid,
    s.center || 'ss' || s.id                           AS MembershipId,
    TO_CHAR(longtodate(s.CREATION_TIME), 'YYYY-MM-DD') AS CreationDate,

    TO_CHAR(s.START_DATE, 'YYYY-MM-DD')                AS StartDate,
    TO_CHAR(s.END_DATE, 'YYYY-MM-DD')                  AS EndDate,
	

    pd.GLOBALID                                        AS GlobalName,
	pd.name                                            AS Name,
	pd.name || pd.GLOBALID 		AS "Name&global",
	pgroup.NAME										AS "ProductGroup",
	st.bindingperiodcount AS "Binding",
	st.periodcount AS "Frequency",
	CASE st.periodunit
	WHEN 0 THEN 'WEEK'
	WHEN 1 THEN 'DAY'
	WHEN 2 THEN 'MONTH'
	END AS "Period Unit",
	st.renew_window AS "RenewWindow",
	st.info_text AS "Text",
	st.autorenew_binding_count AS "AutorenewBy",
	st.autorenew_binding_notice_count AS "AutorenewNotice",
	pd.coment AS "Comment",
	pd.requiredrole AS "Role",
CASE pd.blocked
   WHEN 1 THEN 'YES'
   WHEN 0 THEN 'NO'
END AS "Blocked",
CASE st.st_type
        WHEN 0
        THEN 'CASH'
        WHEN 1
        THEN 'DD'
    END AS MembershipType,
	st.rec_clipcard_product_clips AS "RCCClips",
	st.adminfeeproduct_id  AS "AdminFeeProduct",
	
    s.BINDING_PRICE,
    
    s.SUBSCRIPTION_PRICE,
	pd.price AS "ProductPrice",
CASE
        WHEN st.ST_TYPE = 1
        AND coalesce(psl.SPONSORSHIP_NAME,psg.SPONSORSHIP_NAME,psp.SPONSORSHIP_NAME) IS NOT NULL
        THEN coalesce(psl.SPONSORSHIP_NAME,psg.SPONSORSHIP_NAME,psp.SPONSORSHIP_NAME)
        ELSE NULL
    END AS Sponsorship ,
    CASE
        WHEN st.ST_TYPE = 1
        AND coalesce(psl.SPONSORSHIP_NAME,psg.SPONSORSHIP_NAME,psp.SPONSORSHIP_NAME) IS NOT NULL
        THEN coalesce(psl.SPONSORSHIP_AMOUNT,psg.SPONSORSHIP_AMOUNT,psp.SPONSORSHIP_AMOUNT)
        ELSE NULL
    END AS Sponsorship_amount,
pd.product_account_config_id "accountConfigId",
	pac.name AS "accountConfigName",

TO_CHAR(s.BINDING_END_DATE, 'YYYY-MM-DD') bindingenddate,
    
CASE
        WHEN st.st_type = 0
        THEN TO_CHAR(s.end_date, 'YYYY-MM-DD')
        ELSE TO_CHAR(s.BILLED_UNTIL_DATE, 'YYYY-MM-DD')
    END AS BilledUntilDate ,

    
    FirstActiveFreeze.FreezeFrom,
    FirstActiveFreeze.FreezeTo,
    FirstActiveFreeze.FreezeReason
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
	PRODUCT_GROUP pgroup 
	ON pd.PRIMARY_PRODUCT_GROUP_ID = pgroup.id 

LEFT JOIN 
	product_account_configurations pac 
ON 
     pd.product_account_config_id = pac.id 

LEFT JOIN
    (
        SELECT
            subscription_center,
            subscription_id,
            TO_CHAR(START_DATE, 'YYYY-MM-DD') AS FreezeFrom,
            TO_CHAR(END_DATE, 'YYYY-MM-DD')   AS FreezeTo,
            text                              AS FreezeReason,
            ROW_NUMBER() OVER (PARTITION BY subscription_center,subscription_id ORDER BY END_DATE
            ASC) AS rnk
        FROM
            SUBSCRIPTION_FREEZE_PERIOD
        WHERE
            END_DATE > CURRENT_TIMESTAMP
        AND state = 'ACTIVE' ) FirstActiveFreeze
ON
    FirstActiveFreeze.subscription_center = s.center
AND FirstActiveFreeze.subscription_id = s.id
AND FirstActiveFreeze.rnk = 1
LEFT JOIN
    relatives ca_rel
ON
    ca_rel.center = p.center
AND ca_rel.id = p.id
AND ca_rel.rtype = 3
AND ca_rel.STATUS < 3
LEFT JOIN
    product_spons_local psl
ON
    psl.center=ca_rel.relativecenter
AND psl.id = ca_rel.relativeid
AND psl.subid = ca_rel.relativesubid
AND psl.globalid = pd.GLOBALID
LEFT JOIN
    product_spons_global psg
ON
    psg.center=ca_rel.relativecenter
AND psg.id = ca_rel.relativeid
AND psg.subid = ca_rel.relativesubid
AND psg.globalid = pd.GLOBALID
LEFT JOIN
    product_spons_pg psp
ON
    psp.center=ca_rel.relativecenter
AND psp.id = ca_rel.relativeid
AND psp.subid = ca_rel.relativesubid
AND psp.globalid = pd.GLOBALID
WHERE
    p.center IN ($$scope$$)
AND s.STATE IN (2,4,8) ---active frozen created
AND p.STATUS IN (0,1,3)  ---lead active temp inactive
AND p.PERSONTYPE NOT IN (2)  ----not staff not 8 guest
ORDER BY
    p.center,
    p.id