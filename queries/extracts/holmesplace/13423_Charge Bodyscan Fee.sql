WITH
    PARAMS AS
    (
        SELECT
            $$deduction_date$$ deduction_date
        FROM
            dual
    )
SELECT
    /*+ NO_BIND_AWARE */
    *
FROM
    (
        SELECT
            dat.*,
            dat.center || 'p' || dat.id AS MemberId,
            (
                SELECT DISTINCT
                    --                sum( - ) days
                    floor(SUM(MONTHS_BETWEEN(least(spp1.TO_DATE + 1, PARAMS.deduction_date), greatest(spp1.FROM_DATE, dat.LatestCOASale)))) freeze_months
                    --,
                    --sum(spp1.TO_DATE + 1 - greatest(spp1.FROM_DATE, dat.LatestCOASale)) days
                FROM
                    HP.PERSONS p1
                JOIN
                    HP.SUBSCRIPTIONS sub1
                ON
                    sub1.OWNER_CENTER = p1.center
                    AND sub1.OWNER_ID = p1.id
                    AND sub1.REFMAIN_CENTER IS NULL
                JOIN
                    hp.SUBSCRIPTIONTYPES st1
                ON
                    st1.CENTER = sub1.SUBSCRIPTIONTYPE_CENTER
                    AND st1.id = sub1.SUBSCRIPTIONTYPE_ID
                    AND st1.ST_TYPE = 1
                    AND st1.IS_ADDON_SUBSCRIPTION = 0
                JOIN
                    HP.SUBSCRIPTIONPERIODPARTS spp1
                ON
                    spp1.CENTER = sub1.center
                    AND spp1.id = sub1.id
                    AND spp1.SPP_STATE = 1
                    AND spp1.SPP_TYPE IN (2,7)
                WHERE
                    spp1.TO_DATE >= dat.LatestCOASale
                    AND p1.CURRENT_PERSON_CENTER = dat.CENTER
                    AND p1.CURRENT_PERSON_ID = dat.id ) freeze_months
        FROM
            (
                SELECT DISTINCT
                    p.center,
                    p.id,
                    p.center                     AS CenterId,
                    p.fullname                   AS fullname,
                    pea_email.txtvalue           AS email ,
                    pea_oldid.txtvalue           AS MEMNO,
                    pea_coaching_amount.txtvalue AS CO_AMOUNT,
                    pea_coaching_date.txtvalue   AS CO_DATE,
                    pea_charge_co_fee.txtvalue   AS CHARGE_CO_FEE ,
                    MIN(
                        CASE
                            WHEN (ces.LASTUPDATED IS NULL
                                    OR sub.creation_time >= (NVL(datetolong(TO_CHAR(ces.LASTUPDATED, 'YYYY-MM-DD HH24:MI')), 1) + 24*60*60000))
                            THEN add_months(sub.START_DATE, 3)
                            ELSE to_date('2000-01-01', 'YYYY-MM-DD')
                        END)                                               earliest_newsub_deduction_date ,
                    exerpro.longtodate(MAX(latest_coa_sale.TRANS_TIME)) AS LatestCOASale
                FROM
                    HP.PERSONS p
                CROSS JOIN
                    PARAMS
                JOIN
                    HP.SUBSCRIPTIONS sub
                ON
                    sub.OWNER_CENTER = p.center
                    AND sub.OWNER_ID = p.id
                    AND (
                        sub.END_DATE IS NULL
                        OR (
                            sub.end_date >= PARAMS.deduction_date))
                    AND sub.REFMAIN_CENTER IS NULL
                    AND sub.state IN (2,4,8)
                    AND sub.START_DATE <= PARAMS.deduction_date
                JOIN
                    hp.SUBSCRIPTIONTYPES st
                ON
                    st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
                    AND st.id = sub.SUBSCRIPTIONTYPE_ID
                    AND st.ST_TYPE = 1
                    AND st.IS_ADDON_SUBSCRIPTION = 0
                JOIN
                    hp.SUBSCRIPTION_PRICE sp
                ON
                    sp.SUBSCRIPTION_CENTER = sub.center
                    AND sp.SUBSCRIPTION_ID = sub.id
                    AND sp.FROM_DATE <= PARAMS.deduction_date
                    AND sp.CANCELLED = 0
                    AND (
                        sp.TO_DATE IS NULL
                        OR sp.TO_DATE >= PARAMS.deduction_date )
                LEFT JOIN
                    PERSON_EXT_ATTRS pea_email
                ON
                    pea_email.PERSONCENTER = p.center
                    AND pea_email.PERSONID = p.id
                    AND pea_email.NAME = '_eClub_Email'
                LEFT JOIN
                    HP.PERSON_EXT_ATTRS pea_oldid
                ON
                    pea_oldid.PERSONCENTER = p.center
                    AND pea_oldid.PERSONID = p.id
                    AND pea_oldid.name = '_eClub_OldSystemPersonId'
                LEFT JOIN
                    HP.PERSON_EXT_ATTRS pea_coaching_amount
                ON
                    pea_coaching_amount.PERSONCENTER = p.center
                    AND pea_coaching_amount.PERSONID = p.id
                    AND pea_coaching_amount.name = 'PERIOD_FEE_CO_AMOUNT'
                LEFT JOIN
                    HP.PERSON_EXT_ATTRS pea_coaching_date
                ON
                    pea_coaching_date.PERSONCENTER = p.center
                    AND pea_coaching_date.PERSONID = p.id
                    AND pea_coaching_date.name = 'PERIOD_FEE_CO_DATE'
                LEFT JOIN
                    HP.CONVERTER_ENTITY_STATE ces
                ON
                    ces.NEWENTITYCENTER = p.center
                    AND ces.NEWENTITYID = p.id
                    AND ces.WRITERNAME = 'ClubLeadSubscriptionWriter'
                LEFT JOIN
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
                    HP.SUBSCRIPTION_FREEZE_PERIOD csfp
                ON
                    csfp.SUBSCRIPTION_CENTER = sub.CENTER
                    AND csfp.SUBSCRIPTION_ID = sub.ID
                    AND csfp.STATE = 'ACTIVE'
                    AND csfp.START_DATE <= $$deduction_date$$
                    AND csfp.END_DATE >= $$deduction_date$$
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
                            rel.center IS NOT NULL
                            AND latest_coa_sale.CURRENT_PERSON_CENTER = p.center
                            AND latest_coa_sale.CURRENT_PERSON_ID = p.id)
                        OR (
                            rel.center IS NOT NULL
                            AND latest_coa_sale.CURRENT_PERSON_CENTER = rel.center
                            AND latest_coa_sale.CURRENT_PERSON_ID = rel.id) )
                WHERE
                    p.center IN ( $$Scope$$ )
                    AND p.center NOT IN (2,14) -- Leaving HAM and BMS out since they have an specific extract
                    AND p.PERSONTYPE NOT IN (2)
                    AND sp.PRICE > 0
                    AND csfp.id IS NULL -- exclude members on freeze on deduction date
                GROUP BY
                    p.center,
                    p.id,
                    p.center,
                    p.fullname,
                    pea_oldid.txtvalue,
                    pea_coaching_amount.txtvalue,
                    pea_coaching_date.txtvalue,
                    pea_charge_co_fee.txtvalue,
                    pea_email.txtvalue ) dat
        CROSS JOIN
            PARAMS ) dat2
CROSS JOIN
    PARAMS
WHERE
    charge_co_fee = 'Yes'
    AND earliest_newsub_deduction_date <= PARAMS.deduction_date
    AND (
        CO_DATE IS NULL
        OR CO_DATE <= TO_CHAR(PARAMS.deduction_date, 'YYYY-MM-DD'))
    AND ( -- this condition allows excluding migrated memebrs from coaching fee
        MEMNO IS NULL -- not migrated
        --  OR CO_DATE IS NOT NULL -- or nothing in CO DATE
        OR earliest_newsub_deduction_date > to_date('2013-12-01', 'YYYY-MM-DD')) -- or started after 2013 migration.
    AND (
        LatestCOASale IS NULL
        OR add_months(dat2.LatestCOASale, 6 + NVL(freeze_months, 0)) <= PARAMS.deduction_date)