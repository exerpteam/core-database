SELECT
    gc.CENTER         AS "Gift_Card_Center",
    gc.EXPIRATIONDATE AS "Gift_Card_Expiration",
    gc.AMOUNT_REMAINING AS "Remaining_Amount"
FROM
    SATS.GIFT_CARDS gc
JOIN
    persons p
ON
    p.center = gc.PAYER_CENTER
    AND p.id = gc.PAYER_ID
WHERE
    p.CURRENT_PERSON_CENTER = :person_center
    AND p.CURRENT_PERSON_ID = :person_id
    AND gc.AMOUNT_REMAINING > 0