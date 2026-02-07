SELECT
    it.ID                                        AS "ID",
    it.INVENTORY                                 AS "INVENTORY_ID",
    i.NAME                                       AS "INVENTORY_NAME",
    it.TYPE                                      AS "TYPE",
    it.COMENT                                    AS "COMMENT",
    it.PRODUCT_CENTER || 'prod' || it.PRODUCT_ID AS "PRODUCT_ID",
    it.BOOK_TIME                                 AS "BOOK_DATETIME",
    it.QUANTITY                                  AS "QUANTITY",
    it.UNIT_VALUE                                AS "UNIT_VALUE",
    it.BALANCE_QUANTITY                          AS "BALANCE_QUANTITY",
    it.BALANCE_VALUE                             AS "BALANCE_VALUE",
    i.CENTER                                     AS "CENTER_ID",
    it.ENTRY_TIME                                AS "ETS"
FROM
    INVENTORY_TRANS it
JOIN
    INVENTORY i
ON
    it.INVENTORY = i.ID
