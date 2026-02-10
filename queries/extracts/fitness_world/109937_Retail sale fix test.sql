-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    price_history AS materialized
    (
        WITH
            pmp_xml AS
            (
                SELECT
                    m.id,
                    CAST(convert_from(m.product, 'UTF-8') AS XML) AS pxml
                FROM
                    masterproductregister m
            )
        SELECT DISTINCT
            m2.id,
            m2.globalid,
            UNNEST(xpath('//prices/price/normalPrice/text()', pmp_xml.pxml)) AS normal_price,
            UNNEST(xpath('//prices/price/minPrice/text()', pmp_xml.pxml))  AS min_price,
            UNNEST(xpath('//prices/price/costPrice/text()', pmp_xml.pxml)) AS cost_price,
            UNNEST(xpath('//prices/price/@start', pmp_xml.pxml))           AS start_date
        FROM
            pmp_xml,
            masterproductregister m2
        WHERE
            m2.id = pmp_xml.id
            AND m2.cached_producttype = 1
    ),
    params AS materialized
    (
        SELECT DISTINCT
            CAST($$From_Date$$ AS BIGINT)                      AS FromDate,
            (CAST($$To_Date$$ AS BIGINT) + 86400 * 1000) - 1   AS ToDate
    ),
    eligible_products AS materialized
    (
        SELECT DISTINCT
            c.ID,
            cea.TXT_VALUE           AS Region,
            productGroup.NAME       AS product_group_name,
            p.CENTER || 'p' || p.ID AS payer_id,
            p.external_ID,
            p.sex,
            FLOOR(months_between(TRUNC(CURRENT_TIMESTAMP), p.BIRTHDATE) / 12) AS age,
            p.BIRTHDATE,
            p.FIRSTNAME || ' ' || p.LASTNAME AS payer_name,
            CASE p.PERSONTYPE
                WHEN 0 THEN 'PRIVATE'
                WHEN 1 THEN 'STUDENT'
                WHEN 2 THEN 'STAFF'
                WHEN 3 THEN 'FRIEND'
                WHEN 4 THEN 'CORPORATE'
                WHEN 5 THEN 'ONEMANCORPORATE'
                WHEN 6 THEN 'FAMILY'
                WHEN 7 THEN 'SENIOR'
                WHEN 8 THEN 'GUEST'
                ELSE 'UNKNOWN'
            END AS "Person Type",
            prod.GLOBALID            AS product,
            prod.name                AS product_name,
            CASE prod.PTYPE
                WHEN 1 THEN 'Retail'
                WHEN 2 THEN 'Service'
                WHEN 4 THEN 'Clipcard'
                WHEN 5 THEN 'Subscription creation'
                WHEN 6 THEN 'Transfer'
                WHEN 7 THEN 'Freeze period'
                WHEN 8 THEN 'Gift card'
                WHEN 9 THEN 'Free gift card'
                WHEN 10 THEN 'Subscription'
                WHEN 12 THEN 'Subscription pro-rata'
            END AS product_type,
            SUM(
                CASE
                    WHEN invl.SPONSOR_INVOICE_SUBID IS NULL
                    THEN 1 * invl.QUANTITY
                    ELSE 0
                END
            ) AS SOLD_UNITS,
            REPLACE('' || prod.PRICE, '.', ',') AS NORMAL_UNIT_PRICE,
            prod.cost_price                     AS Cost_Price,
            ROUND(SUM(invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT / (1 + invl.RATE)))), 2) AS AMOUNT_EXCL_VAT,
            ROUND(SUM(invl.TOTAL_AMOUNT - (invl.TOTAL_AMOUNT / (1 + invl.RATE))), 2) AS VAT_AMOUNT,
            ROUND(SUM(invl.TOTAL_AMOUNT), 2) AS AMOUNT_INCL_VAT,
            inv.EMPLOYEE_CENTER || 'emp' || inv.EMPLOYEE_ID AS staff,
            staffp.fullname                        AS staff_name,
            TO_CHAR(longtodate(inv.TRANS_TIME), 'yyyy-MM-dd') AS "Invoice Date",
            TO_CHAR(longtodate(inv.TRANS_TIME), 'HH24:MI')    AS "Invoice Time",
            cr.NAME                                 AS CashRegister,
            -- ... (rest of your fields remain the same)
        FROM
            INVOICELINES invl
        -- ... (rest of the joins remain unchanged)
        GROUP BY
            c.ID,
            cea.TXT_VALUE,
            p.sex,
            months_between(TRUNC(CURRENT_TIMESTAMP), p.BIRTHDATE) / 12,
            p.BIRTHDATE,
            -- ... (rest of the fields remain the same)
    )
SELECT DISTINCT
    t2.id,
    t2.Region,
    t2.product_group_name,
    t2.payer_id,
    t2.external_ID,
    t2.sex,
    t2.age,
    t2.birthdate,
    t2.payer_name,
    t2."Person Type",
    t2.product,
    t2.product_name,
    t2.product_type,
    t2.sold_units,
    CAST((t2.ph_normal_price ::text) AS DECIMAL) AS normal_price,
    CAST((t2.ph_cost_price ::text) AS DECIMAL)   AS cost_price,
    t2.amount_excl_vat,
    t2.amount_incl_vat,
    t2.staff,
    t2.staff_name,
    t2."Invoice Date",
    t2."Invoice Time",
    t2.CashRegister,
    t2.priv_source_type AS "Privilege Source Type",
    t2.priv_source_id   AS "Privilege Source ID",
    priv_set_name       AS "Privilege Set Name",
    t2.priv_source_name AS "Privilege Source Name"
FROM
    (
        SELECT
            *
        FROM
            (
                SELECT
                    ep.*,
                    RANK() OVER (
                        PARTITION BY ep.payer_id, ep.product, ep."Invoice Date", ep."Invoice Time"
                        ORDER BY CAST(ph.start_date ::text AS DATE) DESC
                    ) AS rnk,
                    ph.normal_price AS ph_normal_price,
                    ph.cost_price   AS ph_cost_price
                FROM
                    eligible_products ep
                JOIN
                    price_history ph
                ON
                    ph.globalid = ep.product
                    AND CAST(ep."Invoice Date" AS DATE) > CAST(ph.start_date ::text AS DATE)
            ) t1
        WHERE
            t1.rnk = 1
    ) t2
ORDER BY
    t2.product,
    t2.id,
    t2.region,
    t2.age;
