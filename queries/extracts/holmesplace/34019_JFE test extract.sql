SELECT
    CENTER,
    ID ,
    PERSONKEY AS "PERSONKEY",
    ATTVALUE  AS "ATTVALUE"
FROM
    (
        SELECT
            dat3.center                AS CENTER,
            dat3.id                    AS ID,
            dat3.center||'p'|| dat3.id AS PERSONKEY,
            CASE
                WHEN CHARGE_CO_FEE != 'Yes'
                OR  CHARGE_CO_FEE IS NULL
                THEN NULL
                ELSE TO_CHAR(date_trunc('month',greatest(DEDUCTION_DATE,COALESCE(csfp.END_DATE,
                    DEDUCTION_DATE))- INTERVAL '1 day') + INTERVAL '1 month','yyyy-MM-dd')
            END AS ATTVALUE,
            CHARGE_CO_FEE
        FROM
            (
                SELECT
                    center,
                    id,
                    SUB_CENTER,
                    SUB_ID,
                    SUB_END_DATE,
                    CHARGE_CO_FEE,
                    earliest_newsub_deduction_date,
                    LatestCOASale,
                    greatest(earliest_newsub_deduction_date,COALESCE(LatestCOASale + interval
                    '6 month' ,DATE_TRUNC('month', CURRENT_DATE - interval '1 day') + interval
                    '1 month'), DATE_TRUNC('month', CURRENT_DATE - interval '1 day') + interval
                    '1 month') AS DEDUCTION_DATE
                FROM
                    (
                        SELECT DISTINCT
                            p.center,
                            p.id,
                            sub.center                              AS SUB_CENTER,
                            sub.id                                  AS SUB_ID,
                            sub.END_DATE                            AS SUB_END_DATE,
                            pea_charge_co_fee.txtvalue              AS CHARGE_CO_FEE,
                            MIN( hp.add_months(sub.START_DATE, 2) )    earliest_newsub_deduction_date
                            ,
                            hp.longtodate(MAX(latest_coa_sale.TRANS_TIME)) AS LatestCOASale
                        FROM
                            HP.PERSONS p
                        JOIN
                            HP.SUBSCRIPTIONS sub
                        ON
                            sub.OWNER_CENTER = p.center
                        AND sub.OWNER_ID = p.id
                        AND sub.REFMAIN_CENTER IS NULL
                        AND sub.state IN (2,4,8)
                        JOIN
                            hp.SUBSCRIPTIONTYPES st
                        ON
                            st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
                        AND st.id = sub.SUBSCRIPTIONTYPE_ID
                        AND st.ST_TYPE = 1
                        AND st.IS_ADDON_SUBSCRIPTION = false
                        JOIN
                            HP.PERSON_EXT_ATTRS pea_charge_co_fee
                        ON
                            pea_charge_co_fee.PERSONCENTER = p.center
                        AND pea_charge_co_fee.PERSONID = p.id
                        AND pea_charge_co_fee.name = 'CHARGEBODYSCANFEE'
                        LEFT JOIN
                            HP.RELATIVES rel
                        ON
                            rel.RELATIVECENTER = p.center
                        AND rel.RELATIVEID = p.id
                        AND rel.RTYPE = 12
                        AND rel.STATUS < 3
                        LEFT JOIN
                            (
                                SELECT
                                    ptrans.CURRENT_PERSON_CENTER,
                                    ptrans.CURRENT_PERSON_ID,
                                    MAX(i.TRANS_TIME) AS TRANS_TIME
                                FROM
                                    HP.INVOICELINES il
                                JOIN
                                    HP.INVOICES i
                                ON
                                    i.center = il.center
                                AND i.id = il.id
                                JOIN
                                    HP.PRODUCTS pd
                                ON
                                    pd.CENTER = il.productCENTER
                                AND pd.ID = il.productid
                                JOIN
                                    HP.PERSONS ptrans
                                ON
                                    il.PERSON_CENTER = ptrans.center
                                AND il.person_id = ptrans.id
                                WHERE
                                    pd.GLOBALID = 'COA'
                                GROUP BY
                                    ptrans.CURRENT_PERSON_CENTER,
                                    ptrans.CURRENT_PERSON_ID ) latest_coa_sale
                        ON
                            ( (
                                    rel.center IS NULL
                                AND latest_coa_sale.CURRENT_PERSON_CENTER = p.center
                                AND latest_coa_sale.CURRENT_PERSON_ID = p.id)
                            OR  (
                                    rel.center IS NOT NULL
                                AND latest_coa_sale.CURRENT_PERSON_CENTER = rel.center
                                AND latest_coa_sale.CURRENT_PERSON_ID = rel.id) )
                        WHERE
                            p.center = :center
                        AND p.PERSONTYPE NOT IN (2)
                            --AND pea_charge_co_fee.txtvalue = 'Yes'
                            --AND p.id = 31008
                        GROUP BY
                            p.center,
                            p.id,
                            sub.center,
                            sub.id,
                            sub.END_DATE,
                            pea_charge_co_fee.txtvalue ) dat2)dat3
        LEFT JOIN
            HP.SUBSCRIPTION_FREEZE_PERIOD csfp
        ON
            csfp.SUBSCRIPTION_CENTER = SUB_CENTER
        AND csfp.SUBSCRIPTION_ID = SUB_ID
        AND csfp.STATE = 'ACTIVE'
        AND csfp.START_DATE <= DEDUCTION_DATE
        AND csfp.END_DATE >= DEDUCTION_DATE
        JOIN
            hp.SUBSCRIPTION_PRICE sp
        ON
            sp.SUBSCRIPTION_CENTER = SUB_CENTER
        AND sp.SUBSCRIPTION_ID = SUB_ID
        AND sp.FROM_DATE <= greatest(DEDUCTION_DATE,COALESCE(csfp.END_DATE,DEDUCTION_DATE))
        AND sp.CANCELLED = false
        AND (
                sp.TO_DATE IS NULL
            OR  sp.TO_DATE >= greatest(DEDUCTION_DATE,COALESCE(csfp.END_DATE,DEDUCTION_DATE)) )
        WHERE
            sp.PRICE > 0
        AND (
                greatest(DEDUCTION_DATE,COALESCE(csfp.END_DATE,DEDUCTION_DATE)) < SUB_END_DATE
            OR  SUB_END_DATE IS NULL ) ) x
LEFT JOIN
    HP.PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = x.CENTER
AND pea.PERSONID = x.id
AND pea.NAME = 'BODYSCANFEEDATE'
WHERE
    (
        CHARGE_CO_FEE = 'Yes'
    AND (
            pea.PERSONCENTER IS NULL
        OR  pea.TXTVALUE != x.ATTVALUE ) )
OR  (
        CHARGE_CO_FEE = 'No'
    AND pea.TXTVALUE IS NOT NULL )