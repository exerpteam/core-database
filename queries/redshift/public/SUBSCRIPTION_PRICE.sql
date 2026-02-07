SELECT -- applied mutually exclusive with pending
    ID                                                     AS "ID",
    subscription_center||'ss'||subscription_id             AS "SUBSCRIPTION_ID",
    type                                                   AS "TYPE",
    entry_time                                             AS "ENTRY_DATETIME",
    from_date                                              AS "FROM_DATE",
    to_date                                                AS "TO_DATE",
    price                                                  AS "PRICE",
    CAST(CAST (cancelled AS INT) AS SMALLINT)              AS "CANCELLED",
    CANCELLED_ENTRY_TIME                                   AS "CANCEL_DATETIME",
    SUBSCRIPTION_CENTER                                    AS "CENTER_ID",
    LAST_MODIFIED                                          AS "ETS"		
FROM
    subscription_price 
