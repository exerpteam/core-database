WITH PARAMS AS 
(
    SELECT
	/*+ materialize */
		c.id,  
	   datetolongC(TO_CHAR($$sales_from_date$$, 'YYYY-MM-DD HH24:MI'), c.ID) AS from_sales_date,
       datetolongC(TO_CHAR($$sales_to_date$$, 'YYYY-MM-DD HH24:MI'), c.ID) + 24*60*60*1000  AS to_sales_date
    FROM
       CENTERS c 
)
SELECT
   t1."MemberID",
   t1."Gift card ID",
   t1."Reference",
   t1."Type",
   t1."Product",
   t1."Sales date",
   t1."State",
   t1."Amount",
   t1."Amount left",
   SUM(nvl(t1."Used_amount",0))  AS "Used amount",
   SUM(nvl(t1."Used_API",0))  AS "Used amount by API",
   t1."Expire date"
FROM
(
SELECT
    gc.PAYER_CENTER||'p'||gc.PAYER_ID                                   AS "MemberID",
    gc.CENTER||'gc'||gc.ID                                              AS "Gift card ID",
    e.IDENTITY                                                          AS "Reference",
    DECODE(e.IDMETHOD, 1, 'BARCODE', 2, 'MAGNETIC_CARD', 3, 'SSN', 4, 'RFID_CARD', 5, 'PIN', 6, 'ANTI DROWN', 7, 'QRCODE') AS  "Type",
    pr.NAME                                                             AS "Product",
    TO_CHAR(LongToDateC(gc.PURCHASE_TIME, gc.CENTER),'YYYY-MM-DD')      AS "Sales date",
    DECODE(gc.STATE, 0, 'ISSUED', 1, 'CANCELLED', 2, 'EXPIRED', 3, 'USED', 4, 'PARTIAL USED') AS "State",
    gc.AMOUNT                                                           AS "Amount",
    gc.AMOUNT_REMAINING                                                 AS "Amount left",
    TO_CHAR(gc.EXPIRATIONDATE,'YYYY-MM-DD')                             AS "Expire date",
    CASE WHEN gcu.EMPLOYEE_CENTER = 100 AND gcu.EMPLOYEE_ID = 41098 THEN 
        0 
    ELSE 
        gcu.AMOUNT
    END                                                                 AS "Used_amount",
    CASE WHEN gcu.EMPLOYEE_CENTER = 100 AND gcu.EMPLOYEE_ID = 41098 THEN 
        gcu.AMOUNT
    ELSE
        0
    END                                                                 AS "Used_API"
FROM
    PARAMS
JOIN
    GIFT_CARDS gc
ON
    PARAMS.ID = gc.CENTER
JOIN 
    ENTITYIDENTIFIERS e
ON
    E.ref_center = gc.center
    AND E.ref_id= gc.id
    AND E."REF_TYPE" = 5 -- gift cards
LEFT JOIN
    PRODUCTS pr
ON
    pr.CENTER = gc.PRODUCT_CENTER
    AND pr.ID = gc.PRODUCT_ID
LEFT JOIN
    GIFT_CARD_USAGES gcu
ON
    gcu.GIFT_CARD_CENTER = gc.CENTER
    AND gcu.GIFT_CARD_ID = gc.ID
WHERE
    gc.center in (:centers)
    AND gc.PURCHASE_TIME >= PARAMS.from_sales_date
    AND gc.PURCHASE_TIME < PARAMS.to_sales_date  
) t1    
GROUP BY
    t1."MemberID", t1."Gift card ID", t1."Reference", t1."Type",t1."Product",t1."Sales date",t1."State",t1."Amount",t1."Amount left",t1."Expire date"
