SELECT
    cen.NAME AS CENTER,
    table1.*
FROM
    (
        SELECT
            COALESCE(p.CENTER, invl.person_center) AS PERSONCENTER,
            p.FULLNAME,
            COALESCE(p.CENTER,invl.person_center) || 'p' || COALESCE(p.ID,invl.person_id) AS Pref,
            p.ADDRESS1,
            p.ADDRESS2,
            p.ADDRESS3,
            p.ZIPCODE,
            longToDate(pu.USE_TIME) AS used_time,
            longToDate(cc.CREATION_TIME) codes_created,
            COALESCE(longToDate(prg.STARTTIME),longtodate(sc.STARTTIME)) campaign_start_time,
            COALESCE(prod.NAME,prod2.NAME) AS NAME,
            invl.TOTAL_AMOUNT,
            COALESCE(prg.NAME,sc.NAME) AS "Campaign",
            prg.NAME as "PRG",
            sc.NAME as "SC",
            s.start_date AS start_date -- Aggiunta del campo start_date
        FROM
            CAMPAIGN_CODES cc
        JOIN PRIVILEGE_USAGES pu
            ON pu.CAMPAIGN_CODE_ID = cc.ID
            AND pu.TARGET_SERVICE IN('SubscriptionPrice', 'InvoiceLine')
            AND pu.PRIVILEGE_TYPE = 'PRODUCT'
        LEFT JOIN INVOICELINES invl
            ON invl.CENTER = pu.TARGET_CENTER
            AND invl.ID = pu.TARGET_ID
            AND invl.SUBID = pu.TARGET_SUBID
        LEFT JOIN INVOICES inv
            ON inv.CENTER = invl.CENTER
            AND inv.ID = invl.ID
        LEFT JOIN CREDIT_NOTE_LINES cnl
            ON cnl.INVOICELINE_CENTER = invl.CENTER
            AND cnl.INVOICELINE_ID = invl.ID
            AND cnl.INVOICELINE_SUBID = invl.SUBID
        LEFT JOIN PRODUCTS prod
            ON prod.CENTER = invl.PRODUCTCENTER
            AND prod.ID = invl.PRODUCTID
        LEFT JOIN PRODUCT_GROUP pg
            ON pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
        LEFT JOIN PRIVILEGE_RECEIVER_GROUPS prg
            ON cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
            AND prg.ID = cc.CAMPAIGN_ID
        LEFT JOIN STARTUP_CAMPAIGN sc
            ON cc.CAMPAIGN_TYPE = 'STARTUP'
            AND sc.ID = cc.CAMPAIGN_ID
        LEFT JOIN SUBSCRIPTION_PRICE sp
            ON sp.ID = pu.TARGET_ID
            AND pu.TARGET_SERVICE = 'SubscriptionPrice'
        LEFT JOIN SUBSCRIPTIONS s
            ON s.CENTER = sp.SUBSCRIPTION_CENTER
            AND s.ID = sp.SUBSCRIPTION_ID
        LEFT JOIN PERSONS p
            ON (p.CENTER = s.OWNER_CENTER
            AND p.ID = s.OWNER_ID)
            OR (p.CENTER = invl.person_center
            AND p.ID = invl.person_id)
        LEFT JOIN SUBSCRIPTIONTYPES st
            ON s.SUBSCRIPTIONTYPE_CENTER=st.CENTER
            AND s.SUBSCRIPTIONTYPE_ID=st.ID
        LEFT JOIN PRODUCTS prod2
            ON st.CENTER=prod2.CENTER and st.ID=prod2.ID
        WHERE
            (
            pu.USE_TIME BETWEEN $$longDateFrom$$ AND $$longDateTo$$ + (1000*60*60*24)
            AND cc.CODE = $$code$$
            )
    ) table1
LEFT JOIN CENTERS cen
    ON cen.ID = table1.PERSONCENTER
WHERE PERSONCENTER IN ($$scope$$)
UNION
SELECT
    freeCampaign.CENTER,
    freeCampaign.PERSONCENTER,
    freeCampaign.FULLNAME,
    freeCampaign.Pref,
    freeCampaign.address1,
    freeCampaign.address2,
    freeCampaign.address3,
    freeCampaign.zipcode,
    freeCampaign.FromDate AS used_time,
    freeCampaign.codes_created,
    freeCampaign.campaign_start_time,
    freeCampaign.NAME,
    freeCampaign.TOTAL_AMOUNT,
    freeCampaign.Campaign,
    freeCampaign.PRG,
    freeCampaign.SC,
    NULL AS start_date -- Aggiunta del campo start_date
FROM
    (
        SELECT
            c.name AS CENTER,
            s.owner_center AS PERSONCENTER,
            p.FULLNAME ,
            s.OWNER_CENTER||'p'|| s.OWNER_ID AS Pref,
            p.address1,
            p.address2,
            p.address3,
            p.zipcode,
            longToDate(cc.CREATION_TIME) codes_created,
            longtodatec(sc.STARTTIME, sc.scope_id) campaign_start_time,
            pr.NAME AS NAME,
            0 AS TOTAL_AMOUNT,
            sc.NAME AS Campaign,
            NULL AS PRG,
            sc.NAME AS SC,
            CASE
                WHEN s.STUP_FREE_PERIOD_TYPE = 'AFTER_BINDING'
                THEN s.BINDING_END_DATE+1
                WHEN s.STUP_FREE_PERIOD_TYPE = 'BEFORE_BINDING'
                    AND s.STUP_FREE_PERIOD_UNIT = 1
                THEN s.BINDING_END_DATE +1 - s.STUP_FREE_PERIOD_VALUE
                WHEN s.STUP_FREE_PERIOD_TYPE = 'BEFORE_BINDING'
                    AND s.STUP_FREE_PERIOD_UNIT = 2
                THEN add_months(s.BINDING_END_DATE+1,-1*s.STUP_FREE_PERIOD_VALUE )
            END AS FromDate,
            CASE
                WHEN s.STUP_FREE_PERIOD_TYPE = 'AFTER_BINDING'
                    AND s.STUP_FREE_PERIOD_UNIT = 1
                THEN s.BINDING_END_DATE + s.STUP_FREE_PERIOD_VALUE
                WHEN s.STUP_FREE_PERIOD_TYPE = 'AFTER_BINDING'
                    AND s.STUP_FREE_PERIOD_UNIT = 2
                THEN add_months(s.BINDING_END_DATE,s.STUP_FREE_PERIOD_VALUE )
                WHEN s.STUP_FREE_PERIOD_TYPE = 'BEFORE_BINDING'
                THEN s.BINDING_END_DATE
            END AS ToDate
        FROM
            SUBSCRIPTIONS s
        JOIN
            STARTUP_CAMPAIGN sc
        ON
            sc.id = s.STARTUP_FREE_PERIOD_ID
        JOIN
            CAMPAIGN_CODES cc
        ON
            cc.campaign_id = sc.id
        JOIN
            PRODUCTS pr
        ON
            pr.center = s.SUBSCRIPTIONTYPE_CENTER
            AND pr.id = s.SUBSCRIPTIONTYPE_ID
        JOIN
            centers c
        ON
            c.id = s.owner_center
        JOIN
            PERSONS p
        ON
            p.center = s.OWNER_CENTER
            AND p.id = s.OWNER_ID
        WHERE
            s.owner_center IN ($$scope$$)
            AND cc.CODE = $$code$$
    ) freeCampaign
WHERE
    freeCampaign.FromDate <= longToDate($$longDateFrom$$)
    AND freeCampaign.ToDate >= longToDate($$longDateTo$$)