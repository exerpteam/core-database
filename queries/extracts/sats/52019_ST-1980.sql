SELECT
    i1.*
  ,'-' DIV1
  , i2.*
  ,'-' DIV2
  ,i3.*
  , CASE
        when i2.addon_id is null then 'NO_INVOICE_HISTORY'
        WHEN i2.AMOUNT_EXPLAINED = 'NO EXPLANATION'
            AND i3.calculated_monthly_price = i2.TOTAL_AMOUNT
        THEN 'EXPLAINED BY DISCOUNT'
        WHEN i2.AMOUNT_EXPLAINED = 'NO EXPLANATION'
            AND NOT(i3.calculated_monthly_price = i2.TOTAL_AMOUNT)
        THEN 'NO EXPLANATION'
        ELSE i2.AMOUNT_EXPLAINED
    END AS final_explanation
FROM
    (
        SELECT
            sa.id                              ADDON_ID
          ,s.OWNER_CENTER || 'p' || s.OWNER_ID pid
          , s.CENTER || 'ss' || s.id           ssid
          ,DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE
          ,c.ID CENTER_ID
          ,c.SHORTNAME
            --    ,sa.USE_INDIVIDUAL_PRICE SA_USE_INDIVIDUAL_PRICE
            --    ,sa.INDIVIDUAL_PRICE_PER_UNIT SA_INDIVIDUAL_PRICE_PER_UNIT
            --    ,DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS SUB_STATE
            --    ,s.START_DATE
            --    ,s.END_DATE
            --    ,s.BINDING_END_DATE
            --    ,sa.START_DATE SA_START_DATE
            --    ,sa.END_DATE   SA_END_DATE
        FROM
            SUBSCRIPTION_ADDON sa
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sa.SUBSCRIPTION_CENTER
            AND s.ID = sa.SUBSCRIPTION_ID
         join CENTERS c on c.ID = s.CENTER   
         join PERSONS p on p.CENTER = s.OWNER_CENTER and p.id = s.OWNER_ID   
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.ID = s.SUBSCRIPTIONTYPE_ID
            AND st.ST_TYPE = 1
        WHERE
            sa.END_DATE IS NULL
			and s.center in ($$scope$$)
            AND sa.CANCELLED = 0
and sa.USE_INDIVIDUAL_PRICE = 0
	)i1
LEFT JOIN
    (
        SELECT
            sa.id                              ADDON_ID
          ,s.OWNER_CENTER || 'p' || s.OWNER_ID pid
          , s.CENTER || 'ss' || s.id           ssid
          ,mpr.CACHED_PRODUCTPRICE             LIST_PRICE_MASTER
          ,pao.PRICE                           LIST_PRICE_PROD
          ,spp.FROM_DATE
          ,spp.TO_DATE
          ,months_between(spp.TO_DATE + 1 ,spp.FROM_DATE) months_between
          ,sa.USE_INDIVIDUAL_PRICE                        SA_USE_INDIVIDUAL_PRICE
          ,sa.INDIVIDUAL_PRICE_PER_UNIT                   SA_INDIVIDUAL_PRICE_PER_UNIT
          ,invl.TOTAL_AMOUNT                              PAID_AMOUNT
          ,invl.PRODUCT_NORMAL_PRICE                      NO_DISCOUNT_AMOUNT
          ,sinvl.TOTAL_AMOUNT                             SPONSORED_AMOUNT
          ,invl.PRODUCT_NORMAL_PRICE                      SPONS_NO_DISCOUNT_AMOUNT
          ,invl.TOTAL_AMOUNT
          ,CASE
                WHEN sa.USE_INDIVIDUAL_PRICE = 1
                THEN 'INDIVIDUAL PRICE'
                WHEN invl.PRODUCT_NORMAL_PRICE = invl.TOTAL_AMOUNT
                THEN 'AMOUNT AS EXPECTED'
                WHEN sa.USE_INDIVIDUAL_PRICE = 0
                    AND invl.PRODUCT_NORMAL_PRICE = (invl.TOTAL_AMOUNT + (NVL(sinvl.TOTAL_AMOUNT,0)))
                THEN 'SPONSORSHIP'
                ELSE 'NO EXPLANATION'
            END AS amount_explained
          ,mpr.GLOBALID
          ,pao.NAME                                                                                  ADDON_NAME
          ,ps.NAME                                                                                   SUBSCRIPTION_NAME
          ,DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS SUB_STATE
          ,s.START_DATE
          ,s.END_DATE
          ,s.BINDING_END_DATE
          ,sa.START_DATE SA_START_DATE
          ,sa.END_DATE   SA_END_DATE
        FROM
            SUBSCRIPTION_ADDON sa
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = sa.SUBSCRIPTION_CENTER
            AND s.ID = sa.SUBSCRIPTION_ID
        JOIN
            SUBSCRIPTIONPERIODPARTS spp
        ON
            spp.CENTER = s.CENTER
            AND spp.id = s.id
            AND spp.SPP_TYPE IN (1,8)
            AND spp.SPP_STATE = 1
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.ID = s.SUBSCRIPTIONTYPE_ID
            AND st.ST_TYPE = 1
        JOIN
            MASTERPRODUCTREGISTER mpr
        ON
            mpr.ID = sa.ADDON_PRODUCT_ID
        JOIN
            PRODUCTS pao
        ON
            pao.CENTER = s.CENTER
            AND pao.GLOBALID = mpr.GLOBALID
        JOIN
            SPP_INVOICELINES_LINK l
        ON
            l.PERIOD_CENTER = spp.CENTER
            AND l.PERIOD_ID = spp.ID
            AND l.PERIOD_SUBID = spp.SUBID
        JOIN
            INVOICES inv
        ON
            inv.CENTER = l.INVOICELINE_CENTER
            AND inv.id = l.INVOICELINE_ID
        JOIN
            INVOICELINES invl
        ON
            invl.CENTER = l.INVOICELINE_CENTER
            AND invl.ID = l.INVOICELINE_ID
            AND invl.SUBID = l.INVOICELINE_SUBID
            AND invl.PRODUCTCENTER = pao.CENTER
            AND invl.PRODUCTID = pao.ID
        LEFT JOIN
            INVOICELINES sinvl
        ON
            sinvl.CENTER = inv.SPONSOR_INVOICE_CENTER
            AND sinvl.id = inv.SPONSOR_INVOICE_ID
            AND sinvl.SUBID = invl.SPONSOR_INVOICE_SUBID
        JOIN
            PRODUCTS ps
        ON
            ps.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND ps.ID = s.SUBSCRIPTIONTYPE_ID
        WHERE
            sa.END_DATE IS NULL
            AND sa.CANCELLED = 0
            --AND invl.TOTAL_AMOUNT != invl.PRODUCT_NORMAL_PRICE
            AND spp.SUBID IN
            (
                SELECT
                    MAX(spp2.SUBID) SUBID
                FROM
                    SUBSCRIPTIONPERIODPARTS spp2
                WHERE
                    spp2.SPP_TYPE IN (1,8)
                    AND spp2.SPP_STATE = 1
                    AND spp2.CENTER = spp.CENTER
                    AND spp2.ID = spp.ID ) )i2
ON
    i1.addon_id = i2.addon_id
LEFT JOIN
    (
        SELECT
            sa.id      ADDON_ID
            --  ,      s.OWNER_CENTER || 'p' || s.OWNER_ID pid
            --  ,      s.CENTER || 'ss' || s.ID            ssid
            --  ,      prod.NAME                           ADDON_NAME
          , prod.PRICE              LIST_PRICE_PROD
          , mpr.CACHED_PRODUCTPRICE LIST_PRICE_MASTER
          , invl.PRODUCT_NORMAL_PRICE
          , invl.TOTAL_AMOUNT INVOICED_AMOUNT
          , spp.FROM_DATE
          , spp.TO_DATE
          , months_between(spp.TO_DATE + 1 ,spp.FROM_DATE) month_between
          ,CASE
                WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
                THEN prod.PRICE * (1 - pp.PRICE_MODIFICATION_AMOUNT)
                WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
                THEN pp.PRICE_MODIFICATION_AMOUNT
                WHEN pp.PRICE_MODIFICATION_NAME = 'FREE'
                THEN 0
                ELSE prod.PRICE
            END calculated_monthly_price
          , pp.PRICE_MODIFICATION_NAME
          ,pp.PRICE_MODIFICATION_AMOUNT
          ,pp.REF_TYPE
          , pg.NAME DISCOUNTED_PRODUCT_GROUP
          , pg.GRANTER_SERVICE
          , CASE
                WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
                THEN prg.NAME
                WHEN pg.GRANTER_SERVICE = 'CompanyAgreement'
                THEN comp.LASTNAME || ' - ' || ca.name
                WHEN pg.GRANTER_SERVICE = 'StartupCampaign'
                THEN sc.name
                ELSE 'NOT MAPPED'
            END granter_details
        FROM
            INVOICELINES invl
        JOIN
            INVOICES inv
        ON
            inv.CENTER = invl.CENTER
            AND inv.id = invl.ID
        JOIN
            SPP_INVOICELINES_LINK l
        ON
            l.INVOICELINE_CENTER = invl.CENTER
            AND l.INVOICELINE_ID = invl.ID
            AND l.INVOICELINE_SUBID = invl.SUBID
        JOIN
            SUBSCRIPTIONPERIODPARTS spp
        ON
            spp.CENTER = l.PERIOD_CENTER
            AND spp.ID = l.PERIOD_ID
            AND spp.SUBID = l.PERIOD_SUBID
        JOIN
            SUBSCRIPTIONS s
        ON
            s.CENTER = l.PERIOD_CENTER
            AND s.ID = l.PERIOD_ID
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND st.ID = s.SUBSCRIPTIONTYPE_ID
            AND st.ST_TYPE = 1
        JOIN
            PRODUCTS prod
        ON
            prod.CENTER = invl.PRODUCTCENTER
            AND prod.ID = invl.PRODUCTID
            AND prod.PTYPE = 13
        JOIN
            SUBSCRIPTION_ADDON sa
        ON
            sa.SUBSCRIPTION_CENTER = s.CENTER
            AND sa.SUBSCRIPTION_ID = s.ID
            AND sa.CANCELLED = 0
            AND (
                sa.END_DATE IS NULL
                OR sa.END_DATE > s.BILLED_UNTIL_DATE)
        JOIN
            MASTERPRODUCTREGISTER mpr
        ON
            mpr.ID = sa.ADDON_PRODUCT_ID
            AND mpr.GLOBALID = prod.GLOBALID
        JOIN
            PRIVILEGE_USAGES pu
        ON
            pu.TARGET_SERVICE = 'InvoiceLine'
            AND pu.TARGET_CENTER = invl.CENTER
            AND pu.TARGET_ID = invl.id
            AND pu.TARGET_SUBID = invl.SUBID
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.ID = pu.GRANT_ID
            AND (
                pg.VALID_FROM < 1480415820000
                AND (
                    pg.VALID_TO IS NULL
                    OR pg.VALID_TO > dateToLong(TO_CHAR(s.BILLED_UNTIL_DATE, 'YYYYMMdd HH24:MI'))))
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pu.PRIVILEGE_TYPE = 'PRODUCT'
            AND pp.id = pu.PRIVILEGE_ID
        LEFT JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = pp.REF_ID
            AND pp.REF_TYPE = 'PRODUCT_GROUP'
        LEFT JOIN
            PRIVILEGE_RECEIVER_GROUPS prg
        ON
            pg.GRANTER_SERVICE = 'ReceiverGroup'
            AND prg.id = pg.granter_id
        LEFT JOIN
            COMPANYAGREEMENTS ca
        ON
            pg.GRANTER_SERVICE = 'CompanyAgreement'
            AND ca.center = pg.granter_center
            AND ca.id = pg.granter_id
            AND ca.subid = pg.granter_subid
        LEFT JOIN
            PERSONS comp
        ON
            pg.GRANTER_SERVICE = 'CompanyAgreement'
            AND comp.center = pg.granter_center
            AND comp.id = pg.granter_id
        LEFT JOIN
            STARTUP_CAMPAIGN sc
        ON
            pg.GRANTER_SERVICE = 'StartupCampaign'
            AND sc.id = pg.granter_id
        WHERE
            spp.SUBID IN
            (
                SELECT
                    MAX(spp2.SUBID) SUBID
                FROM
                    SUBSCRIPTIONPERIODPARTS spp2
                WHERE
                    spp2.SPP_TYPE IN (1,8)
                    AND spp2.SPP_STATE = 1
                    AND spp2.CENTER = spp.CENTER
                    AND spp2.ID = spp.ID ) )i3
ON
    i3.addon_id = i2.addon_id