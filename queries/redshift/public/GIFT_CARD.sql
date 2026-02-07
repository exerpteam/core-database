SELECT
    gc.center || 'gc' || gc.id                          AS "ID",
    gc.product_center|| 'prod' || gc.product_id         AS "PRODUCT_ID",
    CASE gc.state 
       WHEN  0 THEN 'ISSUED' 
       WHEN  1 THEN 'CANCELLED'
       WHEN  2 THEN 'EXPIRED' 
       WHEN  3 THEN 'USED' 
       WHEN  4 THEN 'PARTIAL_USED' 
       ELSE 'UNKNOWN'
    END AS "STATE",
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END                                              AS "PERSON_ID",
    gc.EXPIRATIONDATE AS "EXPIRATION_DATE",
    gc.purchase_time  AS "PURCHASE_DATETIME",
    gc.invoiceline_center||'inv'||gc.invoiceline_id||'ln'||gc.invoiceline_subid  AS   "SALE_LOG_ID",
    gc.amount                                                      AS "INITIAL_AMOUNT",
    gc.amount_remaining                                            AS "AMOUNT_REMAINING",
    gc.center                                                      AS "CENTER_ID",
    gc.last_modified                                               AS "ETS"
FROM
    gift_cards gc
JOIN
    products prod
ON
    prod.center= gc.product_center
AND prod.id=gc.product_id
AND prod.ptype in (8, 9) -- gift card & free gift card
JOIN
    persons p
ON
    p.center = gc.payer_center
AND p.id = gc.payer_id

