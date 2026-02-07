SELECT DISTINCT
    *
FROM
    (
        SELECT
            pg.NAME                                                                                                                                                                             product_group
          , prod.name                                                                                                                                                                           subscription
          , '<xsl:when test="//data/subscription/subscriptionName = ''' || prod.name || '''">' || DECODE(pg.NAME,'Buddy Subscriptions','BUDDY','Extra Subscription','PREMIUM') || '</xsl:when>' for_template
        FROM
            PRODUCTS prod
        JOIN
            PRODUCT_AND_PRODUCT_GROUP_LINK link
        ON
            link.PRODUCT_CENTER = prod.CENTER
            AND link.PRODUCT_ID = prod.id
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.id = link.PRODUCT_GROUP_ID
        WHERE
            pg.NAME IN ('Buddy Subscriptions'
                      ,'Extra Subscription') )
ORDER BY
    product_group DESC
  ,subscription 