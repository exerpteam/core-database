 WITH
     v_main AS
     (
         SELECT
                         center.ID                                                       AS CenterID,
             center.NAME                        AS centerName,
             s.OWNER_CENTER || 'p' || s.OWNER_ID AS PERSONID,
             pr.globalid,
             sp.price ,
             sp.from_date ,
             sp.to_date,
             s.center,
             s.id,
             pr.name
         FROM
             SUBSCRIPTIONS s
         JOIN
             CENTERS center
         ON
             center.id = s.owner_center
         JOIN
             products pr
         ON
             pr.center = s.subscriptiontype_center
             AND pr.id = s.subscriptiontype_id
         JOIN
             SUBSCRIPTION_PRICE sp
         ON
             sp.SUBSCRIPTION_CENTER = s.CENTER
             AND sp.SUBSCRIPTION_ID = s.id
             AND sp.CANCELLED = 0
         WHERE
             s.STATE IN (2,4)
             AND s.owner_center = 9
             AND (
                 sp.to_date IS NULL
                 OR sp.to_date > CURRENT_TIMESTAMP)
             AND EXISTS
             (
                 SELECT
                     1
                 FROM
                     SUBSCRIPTION_PRICE sp1
                 WHERE
                     sp1.subscription_center = sp.subscription_center
                     AND sp1.subscription_id = sp.subscription_id
                     AND sp1.cancelled = 0
                     AND sp1.from_date > CURRENT_TIMESTAMP )
         ORDER BY
             sp.from_date
     )
     ,
     v_pivot AS
     (
         SELECT
             v_main.* ,
             LEAD(price,1) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)     AS price1 ,
             LEAD(from_date,1) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date) AS from_date1 ,
             LEAD(to_date,1) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)   AS to_date1 ,
             --
             LEAD(price,2) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)     AS price2 ,
             LEAD(from_date,2) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date) AS from_date2 ,
             LEAD(to_date,2) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)   AS to_date2 ,
             --
             LEAD(price,3) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)     AS price3 ,
             LEAD(from_date,3) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date) AS from_date3 ,
             LEAD(to_date,3) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)   AS to_date3 ,
             --
             LEAD(price,4) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)     AS price4 ,
             LEAD(from_date,4) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date) AS from_date4 ,
             LEAD(to_date,4) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)   AS to_date4 ,
             --
             LEAD(price,5) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)     AS price5 ,
             LEAD(from_date,5) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date) AS from_date5 ,
             LEAD(to_date,5) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)   AS to_date5 ,
             --
             LEAD(price,6) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)     AS price6 ,
             LEAD(from_date,6) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date) AS from_date6 ,
             LEAD(to_date,6) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)   AS to_date6 ,
             --
             LEAD(price,7) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)     AS price7 ,
             LEAD(from_date,7) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date) AS from_date7 ,
             LEAD(to_date,7) OVER (PARTITION BY PERSONID, center, id ORDER BY from_date)   AS to_date7 ,
             --
             ROW_NUMBER() OVER (PARTITION BY PERSONID, center, id ORDER BY from_date) AS ADDONSEQ
         FROM
             v_main
     )
 SELECT
     centerID   AS CLUBID,
         centerName AS CENTERNAME,
     PERSONID   AS MEMBERID,
     name       AS "Subscription name",
     globalid   AS "Subscription Global Id",
     price      AS "Current subscription price",
     from_date  AS "Valid from",
     to_date    AS "Valid to",
     price1     AS "New subscription price 1",
     from_date1 AS "Valid from",
     to_date1   AS "Valid to",
     price2     AS "New subscription price 2",
     from_date2 AS "Valid from",
     to_date2   AS "Valid to",
     price3     AS "New subscription price 3",
     from_date3 AS "Valid from",
     to_date3   AS "Valid to",
     price4     AS "New subscription price 4",
     from_date4 AS "Valid from",
     to_date4   AS "Valid to",
     price5     AS "New subscription price 5",
     from_date5 AS "Valid from",
     to_date5   AS "Valid to",
     price6     AS "New subscription price 6",
     from_date6 AS "Valid from",
     to_date6   AS "Valid to",
     price7     AS "New subscription price 7",
     from_date7 AS "Valid from",
     to_date7   AS "Valid to"
 FROM
     v_pivot
 WHERE
     ADDONSEQ=1
