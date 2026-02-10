-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    *
FROM
    (
        SELECT DISTINCT
            p.center ||'p'|| p.id                                                                                                                                                 AS PersonID,
            s.center ||'ss'|| s.id                                                                                                                                                AS SubscriptionID,
            DECODE(p.STATUS,0,'LEAD',1,'ACTIVE',2,'INACTIVE',3,'TEMPORARYINACTIVE',4,'TRANSFERRED',5,'DUPLICATE',6,'PROSPECT',7,'DELETED',8,'ANONYMIZED',9,'CONTACT','Undefined') AS STATUS,
            ca.center ||'p'|| ca.id ||'rpt'|| ca.subid                                                                                                                            AS agreementid,
            prod.GLOBALID                                                                                                                                                         AS GLOBALID,
            s.subscription_price                                                                                                                                                  AS Price,
            m.globalid                                                                                                                                                            AS ADDONGLOBALID,
            NVL(sa.individual_price_per_unit, NVL(pp.price_modification_amount, addon_pr.price))                                                                                  AS ADDONPRICE,
            rank() over (partition BY sa.id ORDER BY pp.id DESC NULLS LAST)                                                                                                       AS rnk
        FROM
            COMPANYAGREEMENTS ca
            /* company */
        JOIN
            PERSONS c
        ON
            ca.CENTER = c.CENTER
            AND ca.ID = c.ID
            /*company agreement relation*/
        JOIN
            RELATIVES rel
        ON
            rel.RELATIVECENTER = ca.CENTER
            AND rel.RELATIVEID = ca.ID
            AND rel.RELATIVESUBID = ca.SUBID
            AND rel.RTYPE = 3
            AND rel.status NOT IN (3)
            /* persons under agreement*/
        JOIN
            PERSONS p
        ON
            rel.CENTER = p.CENTER
            AND rel.ID = p.ID
            AND rel.RTYPE = 3
            /* subscriptions active and frozen of person */
        JOIN
            subscriptions s
        ON
            s.OWNER_CENTER = rel.CENTER
            AND s.OWNER_ID = rel.ID
            AND s.STATE IN (2,4,8)
            /* Link a subscription with its subscription type */
        JOIN
            subscriptiontypes st
        ON
            s.subscriptiontype_center = st.center
            AND s.subscriptiontype_id = st.id
            /* Link subscription type with it's global-name */
        JOIN
            products prod
        ON
            st.center = prod.center
            AND st.id = prod.id
          LEFT JOIN
            subscription_addon sa
        ON
            sa.subscription_center = s.center
            AND sa.subscription_id = s.id
            AND NVL(sa.end_date, SYSDATE) > SYSDATE -1
            AND sa.cancelled = 0

        LEFT JOIN
            MASTERPRODUCTREGISTER m
        ON
            sa.ADDON_PRODUCT_ID=m.ID
         and m.globalid not in ('EXTENDED_BCA__ADGANG_', 'ADGANG___KOST_SESSION', 'FITNESS_FLEX_CENTER_2', 'HOLD_FLEX__CENTER_2_', 'HOLD_FLEX__CENTER_3_', 'PT_SESSION_1', 'TILLÆGSMEDLEMSKAB__SQUASH') 
   
        LEFT JOIN
            PRODUCTS addon_pr
        ON
            addon_pr.GLOBALID = m.GLOBALID
            AND addon_pr.center = sa.CENTER_ID
        LEFT JOIN
            MASTER_PROD_AND_PROD_GRP_LINK mpl
        ON
            mpl.MASTER_PRODUCT_ID = m.id
        LEFT JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_SERVICE='CompanyAgreement'
            AND pg.GRANTER_CENTER=ca.center
            AND pg.granter_id=ca.id
            AND pg.GRANTER_SUBID = ca.SUBID
            AND (
                pg.VALID_TO IS NULL
                OR pg.VALID_TO > datetolong(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MM')) )
        LEFT JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
            AND pp.REF_ID = mpl.product_group_id
            AND pp.valid_to IS NULL
        WHERE
            ca.center in (:center) )
WHERE
    rnk = 1
