-- This is the version from 2026-02-05
--  
WITH
    IT AS
    (
        SELECT
            PR.CENTER                   AS PR_CENTER,
            PR.ID                       AS PR_ID,
            PR.NAME                     AS PR_NAME,
            PR.GLOBALID                 AS PR_GLOBALID,
            PR.PRIMARY_PRODUCT_GROUP_ID AS PR_PRIMARY_PRODUCT_GROUP_ID,
            PR.EXTERNAL_ID              AS PR_EXTERNAL_ID,
            pr.price                    AS PR_PRICE,
            IT.TYPE                     AS IT_TYPE,
            IT.BOOK_TIME                AS IT_BOOK_TIME,
            IT.ENTRY_TIME               AS IT_ENTRY_TIME,
            IT.QUANTITY                 AS IT_QUANTITY,
            CASE
                WHEN IT.TYPE = 'RECOUNT'
                AND it.unit_value = 0
                THEN lag(IT.UNIT_VALUE) over (partition BY pg.name,pr.name,pr.external_id ORDER BY
                    entry_time ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                ELSE IT.UNIT_VALUE
            END                AS IT_UNIT_VALUE,
            IT.HAD_REPORT_ROLE AS IT_HAD_REPORT_ROLE,
            IT.ID              AS IT_ID,
            IT.REMAINING       AS IT_REMAINING,
            IT.SOURCE_ID       AS IT_SOURCE_ID,
            IT.ENTRY_TIME < $$from_date$$
        AND IT.BOOK_TIME < $$from_date$$
        AND IT.BOOK_TIME < $$from_date$$ AS is_primo,
            it.entry_time >$$from_date$$
        AND it.entry_time <$$to_date$$ + 1000*60*60*24 AS in_period,
            balance_quantity,
            pg.name     AS pg_name,
            c.shortname AS c_shortname,
            c.id        AS c_id,
            last_value(balance_quantity) over (partition BY pg.name,pr.name,pr.external_id ORDER BY
            entry_time ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS
            last_balance_quantity,
            CASE
                WHEN IT.TYPE = 'RECOUNT'
                AND it.unit_value = 0
                THEN lag(IT.UNIT_VALUE) over (partition BY pg.name,pr.name,pr.external_id ORDER BY
                    entry_time ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                ELSE last_value(IT.UNIT_VALUE) over (partition BY pg.name,pr.name,pr.external_id,
                    IT.TYPE != 'RECOUNT' ORDER BY entry_time ASC ROWS BETWEEN UNBOUNDED PRECEDING
                AND UNBOUNDED FOLLOWING)
            END AS last_unit_value,
            first_value(IT.UNIT_VALUE) over (partition BY pg.name,pr.name,pr.external_id ORDER BY
            entry_time ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS
            first_unit_value,
            pr.blocked
        FROM
            PRODUCTS AS PR
        JOIN
            inventory_trans IT
        ON
            (IT.PRODUCT_CENTER = PR.CENTER
            AND IT.PRODUCT_ID = PR.ID)
        AND IT.entry_time BETWEEN $$from_date$$ AND $$to_date$$ + 1000*60*60*24
        JOIN
            centers c
        ON
            c.id = pr.center
        JOIN
            product_group pg
        ON
            pg.id = PR.PRIMARY_PRODUCT_GROUP_ID
        WHERE
            pr.center IN ($$scope$$)
        AND (NOT pr.blocked
            OR  it.id IS NOT NULL)
        AND pr.primary_product_group_id NOT IN (1201,
                                                14601,
                                                18402,
                                                19003,
                                                19004,
                                                5601,
                                                6401,
                                                6601,
                                                18203,
                                                3,
                                                5,
                                                6,
                                                7,
                                                8,
                                                10,
                                                11,
                                                16,
                                                4201,
                                                7401,
                                                18401,
                                                21001,
                                                1,
                                                18801,
                                                18802,
                                                2601,
                                                18602,
                                                19203,
                                                22403,
                                                27001,
                                                22402,
                                                22801,
                                                23201,
                                                25402,
                                                41201)
        ORDER BY
            entry_time DESC
    )
SELECT
    'Denmark'      AS "Scope",
    'FitnessWorld' AS "Scope 2",
    c_shortname    AS "Scope 6",
    c_id           AS "Scope 7",
    pg_name        AS "ProductGroup",
    --  PR_GLOBALID    AS "GlobalName",
    PR_NAME                                 AS "Product",
    PR_EXTERNAL_ID                          AS "ExternalId",
    COALESCE(ROUND(AVG(IT_UNIT_VALUE),2),0) AS "Cost Price",
    MAX( last_balance_quantity) - SUM(
        CASE
            WHEN it_type != 'TRANSFER'
            THEN IT_QUANTITY
            ELSE 0
        END) AS "PrimoUnits",
    (MAX( last_balance_quantity) - SUM(
        CASE
            WHEN it_type != 'TRANSFER'
            THEN IT_QUANTITY
            ELSE 0
        END))*MAX(first_unit_value) AS "PrimoCost",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'DELIVERY'
            THEN IT_QUANTITY
            ELSE 0
        END) AS "InDeliveryUnits",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'DELIVERY'
            THEN IT_QUANTITY*IT_UNIT_VALUE
            ELSE 0
        END) AS "InDeliveryCost",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'RETURN'
            THEN IT_QUANTITY
            ELSE 0
        END) AS "InCreditUnits",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'RETURN'
            THEN IT_QUANTITY*IT_UNIT_VALUE
            ELSE 0
        END) AS "InCreditCost",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'SALE'
            THEN IT_QUANTITY
            ELSE 0
        END) AS "OutSalesUnits",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'SALE'
            THEN IT_QUANTITY*IT_UNIT_VALUE
            ELSE 0
        END) AS "OutSalesCost",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'FAULTY'
            THEN IT_QUANTITY
            ELSE 0
        END) AS "OutFaultyUnits",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'FAULTY'
            THEN IT_QUANTITY*IT_UNIT_VALUE
            ELSE 0
        END) AS "OutFaultyCost",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'INTERNAL_USE'
            THEN IT_QUANTITY
            ELSE 0
        END) AS "OutInternalUnits",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'INTERNAL_USE'
            THEN IT_QUANTITY*IT_UNIT_VALUE
            ELSE 0
        END) AS "OutInternalCost",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'TRANSFER'
            AND IT_QUANTITY > 0
            THEN IT_QUANTITY
            ELSE 0
        END) AS "TransferUnitsFrom",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'TRANSFER'
            AND IT_QUANTITY > 0
            THEN IT_QUANTITY*IT_UNIT_VALUE
            ELSE 0
        END) AS "TransferCostFrom",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'TRANSFER'
            AND IT_QUANTITY < 0
            THEN IT_QUANTITY
            ELSE 0
        END) AS "TransferUnitsTo",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'TRANSFER'
            AND IT_QUANTITY < 0
            THEN IT_QUANTITY*IT_UNIT_VALUE
            ELSE 0
        END) AS "TransferCostTo",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'ADJUSTMENT'
            THEN IT_QUANTITY
            ELSE 0
        END) AS "AdjustmentUnits",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'ADJUSTMENT'
            THEN IT_QUANTITY*IT_UNIT_VALUE
            ELSE 0
        END) AS "AdjustmentCost",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'WRITE_OFF'
            THEN IT_QUANTITY*IT_UNIT_VALUE
            ELSE 0
        END) AS "WriteOffCost",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'RECOUNT'
            THEN IT_QUANTITY
            ELSE 0
        END) AS "Recount",
    SUM(
        CASE
            WHEN in_period
            AND IT_TYPE = 'RECOUNT'
            THEN IT_QUANTITY*IT_UNIT_VALUE
            ELSE 0
        END) AS "RecountCost",
    MAX(
        CASE
            WHEN in_period
            AND IT_TYPE = 'RECOUNT'
            THEN longtodatec(IT_BOOK_TIME,PR_CENTER)
            ELSE NULL
        END)                                    AS "LastProductCount",
    MAX( last_balance_quantity)                 AS "UltimoUnits",
    MAX( last_unit_value*last_balance_quantity) AS "UltimoCost",
    bool_or(blocked)                            AS "IsProductBlocked",
    MAX(it_entry_time) IS NOT NULL OR last_balance_quantity > 0 AS "hasTransactions"

FROM
    IT
GROUP BY
    pg_name ,
    c_shortname,
    PR_NAME ,
    PR_EXTERNAL_ID,
    c_id,
	it.last_balance_quantity
