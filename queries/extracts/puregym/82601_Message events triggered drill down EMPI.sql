WITH
    params AS materialized
    (
        SELECT
            /*+ materialize */
            $$FromDate$$                                                                                 AS StartDate,
            $$ToDate$$                                                                                 AS EndDate,
            datetolongTZ(TO_CHAR(cast($$FromDate$$ as date), 'YYYY-MM-dd HH24:MI'), 'Europe/London')                   AS StartDateLong,
            (datetolongTZ(TO_CHAR(cast($$ToDate$$ as date), 'YYYY-MM-dd HH24:MI'), 'Europe/London')+ 86400 * 1000)-1 AS EndDateLong
        
    )
 SELECT
     m.CENTER || 'p' || m.ID AS "Person Id",
     CASE m.MESSAGE_TYPE_ID WHEN 116 THEN  'SUBSCRIPTION_PRICE_CHANGE_CUSTOM' END AS "Event Type",
     m.SUBJECT                                                                                                                                                                                                        AS "Event Subject",
     CASE  m.DELIVERYMETHOD WHEN 0 THEN 'staff' WHEN 1 THEN 'email' WHEN 2 THEN 'sms' WHEN 3 THEN 'personalInterface' WHEN 4 THEN 'blockPersonalInterface' WHEN 5 THEN 'letter' WHEN 6 THEN 'mobileAPI' WHEN 7 THEN 'appNotification'  END                                                                                                                                                                                                        AS "Message Channel",
     TO_CHAR(TO_TIMESTAMP(m.SENTTIME / 1000), 'DD/MM/YYYY HH24:MI:SS') AS "Sent Time",
     CASE
         WHEN m.DELIVERYCODE IN (0)
         THEN 'Undelivered'
         WHEN m.DELIVERYCODE IN (1,2,4,5,6,8)
         THEN 'Sent'
         WHEN m.DELIVERYCODE IN (7)
         THEN 'Cancelled'
         WHEN m.DELIVERYCODE IN (3,9,10)
         THEN 'Failed'
         WHEN m.DELIVERYCODE IN (14)
         THEN 'Scheduled'
     END AS "Message State"
 FROM
     MESSAGES m
 CROSS JOIN
     params
 WHERE
     m.CENTER IN ($$Scope$$)
     AND m.SENTTIME BETWEEN params.StartDateLong AND params.EndDateLong
         AND m.deliverycode IN (0,1,2,3,4,5,6,7,8,9,10,14)
         AND m.MESSAGE_TYPE_ID IN (116)