select 
case when recalculated_monthly != -1 and recalculated_monthly = LIST_PRICE_PROD then 'RECALCULATED MONTHLY = LIST PRICE'
when recalculated_monthly != -1 and recalculated_monthly = CALCULATED_MONTHLY_PRICE then 'RECALCULATED MONTHLY = CALCULATED_MONTHLY_PRICE'
when recalculated_monthly != -1 then 'CAN''T EXPLAIN'
else 'SPANS MORE THEN ONE MONTH' end final_price_check,u2.*
 from 
(
SELECT
    u1.ADDON_ID
  ,u1.PID
  ,u1.SSID
  ,u1.PERSONTYPE
  ,u1.LIST_PRICE_MASTER
  ,u1.LIST_PRICE_PROD
  ,case when months_between < 1 then round((u1.PAID_AMOUNT /   (TO_DATE + 1 - FROM_DATE) ) * to_char(last_day(FROM_DATE),'DD'))
  else -1 end  recalculated_monthly 
  ,u1.FROM_DATE
  ,u1.TO_DATE
  ,u1.MONTHS_BETWEEN
  ,u1.PAID_AMOUNT
  ,u1.NO_DISCOUNT_AMOUNT
  ,u1.SPONSORED_AMOUNT
  ,u1.SPONS_NO_DISCOUNT_AMOUNT
  ,u1.TOTAL_AMOUNT
  ,u1.AMOUNT_EXPLAINED
  ,u1.ADDON_NAME
  ,u1.SUBSCRIPTION_NAME
  ,u1.CALCULATED_MONTHLY_PRICE
  ,u1.PRICE_MODIFICATION_NAME
  ,u1.PRICE_MODIFICATION_AMOUNT
  ,u1.REF_TYPE
  ,u1.DISCOUNTED_PRODUCT_GROUP
  ,u1.GRANTER_SERVICE
  ,u1.GRANTER_DETAILS
  ,u1.FINAL_EXPLANATION

FROM
    (
        SELECT
            *
        FROM
            ST_1980_FI fi
        JOIN
            SUBSCRIPTION_ADDON sa
        ON
            sa.ID = ADDON_ID
            AND sa.CANCELLED = 0
            AND sa.END_DATE IS NULL
            AND sa.USE_INDIVIDUAL_PRICE = 0
        UNION
        SELECT
            *
        FROM
            ST_1980_NO
        JOIN
            SUBSCRIPTION_ADDON sa
        ON
            sa.ID = ADDON_ID
            AND sa.CANCELLED = 0
            AND sa.END_DATE IS NULL
            AND sa.USE_INDIVIDUAL_PRICE = 0
        UNION
        SELECT
            *
        FROM
            ST_1980_SE
        JOIN
            SUBSCRIPTION_ADDON sa
        ON
            sa.ID = ADDON_ID
            AND sa.CANCELLED = 0
            AND sa.END_DATE IS NULL
            AND sa.USE_INDIVIDUAL_PRICE = 0 ) u1
WHERE
    u1.GLOBALID NOT IN ('SATS_CLUB_DOUBLE_AUTOGIRO'
                      ,'SATS_CLUB_LIMITED_AUTOGIR'
                      ,'BADELAND_ADD_ON'
                      ,'NMI_ADD_ON'
                      ,'SATS_YOU_EXISTING_MEMBER'
                      ,'HIYOGA_EFT_ADD_ON_NB'
                      ,'HIYOGA_EFT_ADD_ON_1'
                      ,'BADELAND_NO_BINDING_ADD_O')
    AND u1.FINAL_EXPLANATION NOT IN ( 'EXPLAINED BY DISCOUNT')
)u2