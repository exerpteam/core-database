-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-10206
SELECT
    per.center || 'p' || per.id AS PersonId,
    CASE
        WHEN op_rel.center IS NOT NULL
        THEN op_rel.center || 'p' || op_rel.id
        ELSE NULL
    END AS OtherPayerId,
    sub.start_date,
    sub.end_date,
    sub.subscription_price,
    prod.name AS "Product Name",
    latest_admin_fee.LatestAdminFee
FROM
    persons per
JOIN
    subscriptions sub
ON
    sub.owner_center = per.center
    AND sub.owner_id = per.id
JOIN
    subscriptiontypes st
ON
    st.center = sub.subscriptiontype_center
    AND st.id = sub.subscriptiontype_id
    AND st.st_type = 1
    AND st.IS_ADDON_SUBSCRIPTION = 0
JOIN
    products prod
ON
    prod.center = sub.subscriptiontype_center
    AND prod.id = sub.subscriptiontype_id
LEFT JOIN
    RELATIVES op_rel
ON
    op_rel.relativecenter=per.center
    AND op_rel.relativeid=per.id
    AND op_rel.RTYPE = 12
    AND op_rel.STATUS < 3
LEFT JOIN
    PERSONS payer
ON
    payer.center = op_rel.center
    AND payer.id = op_rel.id
LEFT JOIN
    (
        SELECT
            ptrans.CURRENT_PERSON_CENTER,
            ptrans.CURRENT_PERSON_ID,
            longtodate(MAX(i.TRANS_TIME)) AS LatestAdminFee
        FROM
            invoice_lines_mt il
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
            ptrans.CURRENT_PERSON_ID ) latest_admin_fee
ON
    latest_admin_fee.CURRENT_PERSON_CENTER = per.center
    AND latest_admin_fee.CURRENT_PERSON_ID = per.id
WHERE
    per.center IN ($$Scope$$)
    /* Exclude Staff */
    AND per.persontype != 2
    /* Active subscription. Fee will not added during freeze*/
    AND sub.state = 2
	/* Fee added only first of the month only */
--	AND extract(DAY FROM current_timestamp) = 1
    /* Intital fee after 3 months from subscription start */
    AND add_months(sub.start_date, 3) <= current_timestamp
    /* recurring admin fee after every 3 motnhs */
    AND (
        LatestAdminFee IS NULL
        OR add_months(LatestAdminFee, 3) <= current_timestamp)
    AND sub.subscription_price > 0
    AND COALESCE(sub.end_date, TRUNC(current_timestamp)+30) = TRUNC(current_timestamp)+30
    /* exclude members with company as other payer */
    AND (
        payer.SEX != 'C'
        OR op_rel.id IS NULL)
    /* Exclude fully sponsored subscriptions */
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            RELATIVES compaggrel
        JOIN
            COMPANYAGREEMENTS ca
        ON
            ca.CENTER = compaggrel.RELATIVECENTER
            AND ca.ID = compaggrel.RELATIVEID
            AND ca.SUBID = compaggrel.RELATIVESUBID
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_CENTER = ca.CENTER
            AND pg.GRANTER_ID = ca.ID
            AND pg.GRANTER_SUBID = ca.SUBID
            AND pg.SPONSORSHIP_NAME = 'FULL'
            AND pg.VALID_FROM < dateToLong(TO_CHAR(current_timestamp+1, 'YYYY-MM-dd HH24:MI'))
            AND (
                pg.VALID_TO >=dateToLong(TO_CHAR(current_timestamp+1, 'YYYY-MM-dd HH24:MI'))
                OR pg.VALID_TO IS NULL)
            AND pg.GRANTER_SERVICE = 'CompanyAgreement'
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
            AND pp.VALID_FROM < dateToLong(TO_CHAR(current_timestamp+1, 'YYYY-MM-dd HH24:MI'))
            AND (
                pp.VALID_TO >= dateToLong(TO_CHAR(current_timestamp+1, 'YYYY-MM-dd HH24:MI'))
                OR pp.VALID_TO IS NULL)
        WHERE
            compaggrel.center = per.center
            AND compaggrel.id = per.id
            AND compaggrel.rtype = 3
            AND compaggrel.status < 3
            AND pp.REF_GLOBALID = prod.GLOBALID)
