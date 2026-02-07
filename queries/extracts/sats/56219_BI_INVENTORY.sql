WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,-1,0,(TRUNC(exerpsysdate())-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            (TRUNC(exerpsysdate()+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000                                 AS TODATE
        FROM
            dual
    )
SELECT
    it.ID                                       AS "INVENTORY_TRANS_ID",
    it.INVENTORY                                AS "INVENTORY_ID",
    i.NAME                                      AS "INVENTORY_NAME",
    it.TYPE                                     AS "TYPE",
    it.COMENT                                   AS "COMMENT",
    it.PRODUCT_CENTER || 'p' || it.PRODUCT_ID   AS "PRODUCT_ID",
    exerpro.longtodate(it.BOOK_TIME)            AS "TRANS_DATETIME",
    it.QUANTITY                                 AS "TRANS_QUANTITY",
    it.UNIT_VALUE                               AS "TRANS_UNIT_VALUE",
    it.BALANCE_QUANTITY                         AS "BALANCE_QUANTITY",
    it.BALANCE_VALUE                            AS "BALANCE_VALUE",
    i.CENTER                                    AS "CENTER_ID",
    it.ENTRY_TIME                               AS "ETS"
FROM
    params, 
    INVENTORY i
JOIN
    INVENTORY_TRANS it
ON
    it.INVENTORY = i.ID 
WHERE
    it.ENTRY_TIME BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
	and i.CENTER in ($$scope$$)


