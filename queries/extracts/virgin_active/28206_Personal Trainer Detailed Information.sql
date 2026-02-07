 SELECT
    c.NAME as "Club",
    c.id as "Club ID",
    p.FULLNAME as "Personal Trainer Name",
    p.CENTER||'p'||p.id as "Personal Trainer ID",
    pr.NAME as "Subscription",
    TO_CHAR(prq.REQ_DATE,'yyyy-MM') As "Rejection Month",
    prq.REQ_AMOUNT as "Amount of the rejection"
 FROM
   PERSONS p
 JOIN
   ACCOUNT_RECEIVABLES ar
 ON
   ar.CUSTOMERCENTER = p.CENTER AND ar.CUSTOMERID = p.ID AND ar.AR_TYPE = 4
 JOIN
   PAYMENT_REQUESTS prq
 ON
   prq.CENTER = ar.CENTER AND prq.ID = ar.ID AND prq.STATE > 4 AND prq.REQUEST_TYPE = 1
 JOIN
   CENTERS c
 ON
   c.id = p.center
 JOIN
   SUBSCRIPTIONS s
 ON
   s.OWNER_CENTER = p.CENTER AND s.OWNER_ID = p.ID
 JOIN
   PRODUCTS pr
 ON
   s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER AND s.SUBSCRIPTIONTYPE_ID = pr.ID AND s.STATE = 2
 WHERE
   p.PERSONTYPE = 2
   and c.id in (:scope)
   and prq.REQ_DATE BETWEEN :StartDate AND :EndDate
   and exists (SELECT 1 FROM PRODUCT_AND_PRODUCT_GROUP_LINK l where l.PRODUCT_CENTER = pr.CENTER and l.PRODUCT_ID = pr.id and l.PRODUCT_GROUP_ID = 12601)
   -- 'Fatture PT'
