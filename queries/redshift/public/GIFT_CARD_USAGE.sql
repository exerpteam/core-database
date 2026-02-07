SELECT
    ID                                       AS "ID",
    AMOUNT                                   AS "AMOUNT",
    TYPE                                     AS "TYPE",
    GIFT_CARD_CENTER||'gc'||GIFT_CARD_ID     AS "GIFT_CARD_ID",
    TIME                                     AS "USAGE_DATETIME",
    GIFT_CARD_CENTER                         AS "CENTER_ID",
    TIME                                     AS "ETS"
FROM
    GIFT_CARD_USAGES 
