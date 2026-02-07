
        SELECT
            dat.*,
            dat.center || 'p' || dat.id AS PERSONKEY,
            (
                SELECT DISTINCT
                    floor(SUM(MONTHS_BETWEEN(least(spp1.TO_DATE + 1, SYSDATE), greatest(spp1.FROM_DATE, dat.LastSale)))) freeze_months
                FROM
                    PERSONS p1
                JOIN
                    SUBSCRIPTIONS sub1
                ON
                    sub1.OWNER_CENTER = p1.center
                    AND sub1.OWNER_ID = p1.id
                    AND sub1.REFMAIN_CENTER IS NULL
                JOIN
                    SUBSCRIPTIONTYPES st1
                ON
                    st1.CENTER = sub1.SUBSCRIPTIONTYPE_CENTER
                    AND st1.id = sub1.SUBSCRIPTIONTYPE_ID
                    AND st1.ST_TYPE = 1
                    AND st1.IS_ADDON_SUBSCRIPTION = 0
                JOIN
                    SUBSCRIPTIONPERIODPARTS spp1
                ON
                    spp1.CENTER = sub1.center
                    AND spp1.id = sub1.id
                    AND spp1.SPP_STATE = 1
                   AND spp1.SPP_TYPE IN (2,7)
                WHERE
                    ((
                            spp1.TO_DATE >= dat.LastSale
                            AND dat.LastSale IS NOT NULL)
                        OR dat.LastSale IS NULL) AND
                    p1.CURRENT_PERSON_CENTER = dat.CENTER
                    AND p1.CURRENT_PERSON_ID = dat.id ) freeze_months
        FROM
            (
                SELECT DISTINCT
                    p.center,
                    p.id,
                    MIN( greatest(add_months(sub.START_DATE, 12),sub.BINDING_END_DATE))    earliest_newsub_deduction_date ,
                    exerpro.longtodate(MAX(latest_sale.TRANS_TIME))                     AS LastSale
                FROM
                    PERSONS p
				JOIN 
                    CENTERS c
                ON 
                        p.CENTER = c.ID
                        AND c.COUNTRY = 'DE'
                JOIN
                    SUBSCRIPTIONS sub
                ON
                    sub.OWNER_CENTER = p.center
                    AND sub.OWNER_ID = p.id
                    AND (
                        sub.END_DATE IS NULL
                        OR (
                            sub.end_date >= TRUNC(add_months(SYSDATE,1),'MONTH')))
                    AND sub.REFMAIN_CENTER IS NULL
                    AND sub.state IN (2,4,8)
                    AND sub.START_DATE <= SYSDATE
					-- EXCLUDE MIGRATED SUBSCRIPTIONS
                    AND (
                                (sub.SUB_COMMENT IS NULL OR sub.SUB_COMMENT NOT LIKE 'membershipOldID=%')
                        )
                JOIN
                    SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
                    AND st.id = sub.SUBSCRIPTIONTYPE_ID
                    AND st.ST_TYPE = 1
                    AND st.IS_ADDON_SUBSCRIPTION = 0
                JOIN
                    products pr
                ON
                    pr.center = st.center
                    AND pr.id = st.id
                LEFT JOIN
                    RELATIVES rel --relation to other payer
                ON
                    rel.RELATIVECENTER = p.center
                    AND rel.RELATIVEID = p.id
                    AND rel.RTYPE = 12
                    AND rel.STATUS < 3
                LEFT JOIN
                    PERSONS payer
                ON
                    payer.center = rel.center
                    AND payer.id = rel.id
                LEFT JOIN
                    RELATIVES carel -- relation to company agreement
                ON
                    carel.center = p.center
                    AND carel.id = p.id
                    AND carel.RTYPE = 3
                    AND carel.STATUS < 3
                LEFT JOIN
                    SUBSCRIPTION_FREEZE_PERIOD csfp
                ON
                    csfp.SUBSCRIPTION_CENTER = sub.CENTER
                    AND csfp.SUBSCRIPTION_ID = sub.ID
                    AND csfp.STATE = 'ACTIVE'
                    AND csfp.START_DATE <= SYSDATE
                    AND csfp.END_DATE >= SYSDATE
                LEFT JOIN
                    (
                        SELECT
                            ptrans.CURRENT_PERSON_CENTER,
                            ptrans.CURRENT_PERSON_ID,
                            MAX(i.TRANS_TIME) AS TRANS_TIME
                        FROM
                            INVOICELINES il
                        JOIN
                            INVOICES i
                        ON
                            i.center = il.center
                            AND i.id = il.id
                        JOIN
                            PRODUCTS pd
                        ON
                            pd.CENTER = il.productCENTER
                            AND pd.ID = il.productid
                        JOIN
                            PERSONS ptrans
                        ON
                            il.PERSON_CENTER = ptrans.center
                            AND il.person_id = ptrans.id
                        WHERE
                            pd.GLOBALID = 'ADMIN_FEE'
                        GROUP BY
                            ptrans.CURRENT_PERSON_CENTER,
                            ptrans.CURRENT_PERSON_ID ) latest_sale
                ON
                    (latest_sale.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
                        AND latest_sale.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID)
                WHERE
                    p.center = 783
                    --AND extract(DAY FROM SYSDATE) = 7
                    AND csfp.id IS NULL -- exclude members on freeze on deduction date
                    AND sub.START_DATE >= to_date('2015-01-01','yyyy-MM-dd')
                    --AND pr.GLOBALID IN ('EFT_12_M',
                    --                  'EFT_24_M',
                    --                  'EFT_12_M_FITNESS_BATH',
                    --                  'EFT_9_M',
                    --                  'EFT_4_M_NEW',
                    --                  'EFT_12M_SWIMMING_',
                    --                  'EFT_12_M_SWIMMING',
                    --                  'EFT_12_M_SWIMMING_2',
                    --                  'EFT_12_M_REGIONAL',
                    --                  'WEB_EFT_12_M_LOCAL',
                    --                  'WEB_EFT_4_M',
                    --                  'WEB_24_EFT_M',
                    --                  'WEB_EFT_12_M',
                    --                  'WEB_EFT_4_MONTHS')
                    AND (
                        payer.SEX != 'C'
                        OR rel.id IS NULL) -- exclude members with company as other payer
                    AND NOT EXISTS
                    (
                        SELECT
                            1
                        FROM
                            PRIVILEGE_GRANTS pg
                        WHERE
                            pg.GRANTER_SERVICE = 'CompanyAgreement'
                            AND pg.GRANTER_CENTER = carel.RELATIVECENTER
                            AND pg.GRANTER_ID = carel.RELATIVEID
                            AND pg.GRANTER_SUBID = carel.RELATIVESUBID
                            AND pg.VALID_TO IS NULL
                            AND pg.SPONSORSHIP_NAME != 'NONE') -- exclude members with sponsored company agreements
                GROUP BY
                    p.center,
                    p.id ) dat
