-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
            CAST(dateToLongC(TO_CHAR(CAST(:from_date AS DATE),'YYYY-MM-DD') || ' 00:00', c.id) AS BIGINT) AS FROM_DATE,
            CAST(dateToLongC(TO_CHAR(CAST(:to_date AS DATE),'YYYY-MM-DD') || ' 23:59', c.id) AS BIGINT)  AS TO_DATE,
            c.id,
            c.name
        FROM
            centers c
        WHERE
            c.id IN (:scope)
    )
    ,
    DELIVERIES AS
    (
        SELECT
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY,
            SUM(it.QUANTITY) AS TOT_QUANTITY
        FROM
            INVENTORY_TRANS it
        JOIN
            params
        ON
            params.id = it.PRODUCT_CENTER
        WHERE
            it.TYPE = 'DELIVERY'
        AND it.ENTRY_TIME BETWEEN params.FROM_DATE AND params.TO_DATE
        GROUP BY
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY
    )
    ,
    SALES AS
    (
        SELECT
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY,
            SUM(it.QUANTITY) AS TOT_QUANTITY
        FROM
            INVENTORY_TRANS it
        JOIN
            params
        ON
            params.id = it.PRODUCT_CENTER
        WHERE
            it.TYPE = 'SALE'
        AND it.ENTRY_TIME BETWEEN params.FROM_DATE AND params.TO_DATE
        GROUP BY
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY
    )
    ,
    RETURNS AS
    (
        SELECT
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY,
            SUM(it.QUANTITY) AS TOT_QUANTITY
        FROM
            INVENTORY_TRANS it
        JOIN
            params
        ON
            params.id = it.PRODUCT_CENTER
        WHERE
            it.TYPE = 'RETURN'
        AND it.ENTRY_TIME BETWEEN params.FROM_DATE AND params.TO_DATE
        GROUP BY
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY
    )
    ,
    ADJUSTMENT AS
    (
        SELECT
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY,
            SUM(it.QUANTITY) AS TOT_QUANTITY
        FROM
            INVENTORY_TRANS it
        JOIN
            params
        ON
            params.id = it.PRODUCT_CENTER
        WHERE
            it.TYPE = 'ADJUSTMENT'
        AND it.ENTRY_TIME BETWEEN params.FROM_DATE AND params.TO_DATE
        GROUP BY
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY
    )
    ,
    FAULTY AS
    (
        SELECT
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY,
            SUM(it.QUANTITY) AS TOT_QUANTITY
        FROM
            INVENTORY_TRANS it
        JOIN
            params
        ON
            params.id = it.PRODUCT_CENTER
        WHERE
            it.TYPE = 'FAULTY'
        AND it.ENTRY_TIME BETWEEN params.FROM_DATE AND params.TO_DATE
        GROUP BY
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY
    )
    ,
    TRANSFER AS
    (
        SELECT
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY,
            SUM(it.QUANTITY) AS TOT_QUANTITY
        FROM
            INVENTORY_TRANS it
        JOIN
            params
        ON
            params.id = it.PRODUCT_CENTER
        WHERE
            it.TYPE = 'TRANSFER'
        AND it.ENTRY_TIME BETWEEN params.FROM_DATE AND params.TO_DATE
        GROUP BY
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY
    )
    ,
    INTERNAL_USE AS
    (
        SELECT
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY,
            SUM(it.QUANTITY) AS TOT_QUANTITY
        FROM
            INVENTORY_TRANS it
        JOIN
            params
        ON
            params.id = it.PRODUCT_CENTER
        WHERE
            it.TYPE = 'INTERNAL_USE'
        AND it.ENTRY_TIME BETWEEN params.FROM_DATE AND params.TO_DATE
        GROUP BY
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY
    )
    ,
    WRITE_OFF AS
    (
        SELECT
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY,
            SUM(it.QUANTITY) AS TOT_QUANTITY
        FROM
            INVENTORY_TRANS it
        JOIN
            params
        ON
            params.id = it.PRODUCT_CENTER
        WHERE
            it.TYPE = 'WRITE_OFF'
        AND it.ENTRY_TIME BETWEEN params.FROM_DATE AND params.TO_DATE
        GROUP BY
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY
    )
    ,
    RECOUNT AS
    (
        SELECT
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY,
            SUM(it.QUANTITY) AS TOT_QUANTITY
        FROM
            INVENTORY_TRANS it
        JOIN
            params
        ON
            params.id = it.PRODUCT_CENTER
        WHERE
            it.TYPE = 'RECOUNT'
        AND it.ENTRY_TIME BETWEEN params.FROM_DATE AND params.TO_DATE
        GROUP BY
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY
    )
    ,
    TOTAL_SUM AS
    (
        SELECT
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY,
            SUM(it.QUANTITY) AS TOT_QUANTITY
        FROM
            INVENTORY_TRANS it
        JOIN
            params
        ON
            params.id = it.PRODUCT_CENTER
        WHERE
            it.ENTRY_TIME BETWEEN params.FROM_DATE AND params.TO_DATE
        GROUP BY
            it.PRODUCT_CENTER,
            it.PRODUCT_ID,
            it.INVENTORY
    )
SELECT
    t1.*,
    SUM("Opening balance"+COALESCE("Additions", 0)+COALESCE("Sales", 0)+COALESCE("Returns", 0)+COALESCE("Adjustment", 0
    )+COALESCE("Faulty", 0)+COALESCE("Transfer", 0)+COALESCE("Internal use", 0)+COALESCE("Write off", 0)+COALESCE("Recount",
    0)) AS "Sum",
    null AS "Counted"
FROM
    (
        SELECT DISTINCT
            params.id   AS "Center ID",
            params.name AS "Center name",
            pr.NAME     AS "Product",
            string_agg(ei.IDENTITY, ', ' ORDER BY ei.IDENTITY)             AS "Barcode",
            it.UNIT_VALUE                                                  AS "Cost price",
            it.BALANCE_QUANTITY                                            AS "Opening balance",
            del.TOT_QUANTITY                                               AS "Additions",
            sal.TOT_QUANTITY                                               AS "Sales",
            re.TOT_QUANTITY                                                AS "Returns",
            adj.TOT_QUANTITY                                               AS "Adjustment",
            fa.TOT_QUANTITY                                                AS "Faulty",
            tr.TOT_QUANTITY                                                AS "Transfer",
            iu.TOT_QUANTITY                                                AS "Internal use",
            wo.TOT_QUANTITY                                                AS "Write off",
            rec.TOT_QUANTITY                                               AS "Recount"
        FROM
            INVENTORY_TRANS it
        JOIN
            INVENTORY i
        ON
            it.INVENTORY = i.ID
        AND i.STATE NOT IN ('DELETED')
        JOIN
            params
        ON
            params.id = i.CENTER
        JOIN
            PRODUCTS pr
        ON
            it.PRODUCT_CENTER = pr.CENTER
        AND it.PRODUCT_ID = pr.ID
        AND pr.BLOCKED = 0
        AND pr.PTYPE = 1
        AND pr.NAME NOT LIKE 'PT%'
        LEFT JOIN
            ENTITYIDENTIFIERS ei
        ON
            ei.REF_GLOBALID = pr.GLOBALID
        AND ei.IDMETHOD = 1
        AND ei.REF_TYPE = 4
        AND ei.ENTITYSTATUS = 1
        AND ei.QUANTITY = 1
        LEFT JOIN
            DELIVERIES del
        ON
            del.PRODUCT_CENTER = it.PRODUCT_CENTER
        AND del.PRODUCT_ID = it.PRODUCT_ID
        AND del.INVENTORY = it.INVENTORY
        LEFT JOIN
            SALES sal
        ON
            sal.PRODUCT_CENTER = it.PRODUCT_CENTER
        AND sal.PRODUCT_ID = it.PRODUCT_ID
        AND sal.INVENTORY = it.INVENTORY
        LEFT JOIN
            RETURNS re
        ON
            re.PRODUCT_CENTER = it.PRODUCT_CENTER
        AND re.PRODUCT_ID = it.PRODUCT_ID
        AND re.INVENTORY = it.INVENTORY
        LEFT JOIN
            ADJUSTMENT adj
        ON
            adj.PRODUCT_CENTER = it.PRODUCT_CENTER
        AND adj.PRODUCT_ID = it.PRODUCT_ID
        AND adj.INVENTORY = it.INVENTORY
        LEFT JOIN
            FAULTY fa
        ON
            fa.PRODUCT_CENTER = it.PRODUCT_CENTER
        AND fa.PRODUCT_ID = it.PRODUCT_ID
        AND fa.INVENTORY = it.INVENTORY
        LEFT JOIN
            TRANSFER tr
        ON
            tr.PRODUCT_CENTER = it.PRODUCT_CENTER
        AND tr.PRODUCT_ID = it.PRODUCT_ID
        AND tr.INVENTORY = it.INVENTORY
        LEFT JOIN
            INTERNAL_USE iu
        ON
            iu.PRODUCT_CENTER = it.PRODUCT_CENTER
        AND iu.PRODUCT_ID = it.PRODUCT_ID
        AND iu.INVENTORY = it.INVENTORY
        LEFT JOIN
            WRITE_OFF wo
        ON
            wo.PRODUCT_CENTER = it.PRODUCT_CENTER
        AND wo.PRODUCT_ID = it.PRODUCT_ID
        AND wo.INVENTORY = it.INVENTORY
        LEFT JOIN
            RECOUNT rec
        ON
            rec.PRODUCT_CENTER = it.PRODUCT_CENTER
        AND rec.PRODUCT_ID = it.PRODUCT_ID
        AND rec.INVENTORY = it.INVENTORY
        LEFT JOIN
            TOTAL_SUM ts
        ON
            ts.PRODUCT_CENTER = it.PRODUCT_CENTER
        AND ts.PRODUCT_ID = it.PRODUCT_ID
        AND ts.INVENTORY = it.INVENTORY
        WHERE
            it.ENTRY_TIME =
            (
                SELECT
                    MAX(it2.ENTRY_TIME)
                FROM
                    INVENTORY_TRANS it2
                WHERE
                    it.PRODUCT_CENTER = it2.PRODUCT_CENTER
                AND it.PRODUCT_ID = it2.PRODUCT_ID
                AND it2.ENTRY_TIME <= params.from_date )
        GROUP BY
            params.id,
            params.name,
            pr.NAME,
            it.UNIT_VALUE,
            it.BALANCE_QUANTITY,
            del.TOT_QUANTITY,
            sal.TOT_QUANTITY,
            re.TOT_QUANTITY,
            adj.TOT_QUANTITY,
            fa.TOT_QUANTITY,
            tr.TOT_QUANTITY,
            iu.TOT_QUANTITY,
            wo.TOT_QUANTITY,
            rec.TOT_QUANTITY ) t1
GROUP BY
    "Center ID",
    "Center name",
    "Product",
    "Barcode",
    "Cost price", 
    "Opening balance",
    "Additions",
    "Sales",
    "Returns",
    "Adjustment",
    "Faulty",
    "Transfer",
    "Internal use",
    "Write off",
    "Recount"
    ORDER BY
    "Center ID",
    "Product"
