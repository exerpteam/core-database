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

SELECT DISTINCT
     gc.payer_center || 'p' || gc.payer_id AS "MemberID",
    e.IDENTITY                               "Barcode",
    gc.AMOUNT "Gift card amount" 
    
FROM
    GIFT_CARDS gc
join params on params.id = gc.center
JOIN
    products pd
ON
    pd.center = gc.product_center
AND pd.id = gc.product_id
JOIN
    PRIVILEGE_USAGES pu
ON
    pu.person_center = gc.payer_center
AND pu.person_id = gc.payer_id
AND pu.TARGET_SERVICE IN ('InvoiceLine')
JOIN
    CAMPAIGN_CODES cc
ON
    pu.CAMPAIGN_CODE_ID = cc.ID
AND cc.CAMPAIGN_TYPE IN('STARTUP','RECEIVER_GROUP')
JOIN
    "ENTITYIDENTIFIERS" E
ON
    E.ref_center = gc.center
AND E.ref_id= gc.id
where E."IDMETHOD" = 1 --barcode
AND E."REF_TYPE" = 5 -- gift_card
AND cc.CODE IN ('DKwelcomeback0621','welcomeback0621')
 --members sold on code DKwelcomeback0621,welcomeback0621
and pd.globalid= 'FREE_GIFT_CARD_SAVEDESK' --Product (Free Campaign Gift Card, FREE_GIFT_CARD_SAVEDESK)
and gc.center in (:centers)
AND gc.PURCHASE_TIME >= PARAMS.from_sales_date
    AND gc.PURCHASE_TIME < PARAMS.to_sales_date  