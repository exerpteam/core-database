-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-9687
 SELECT
         p.FIRSTNAME AS "First Name",
         p.LASTNAME AS "Last Name",
         c.NAME AS "Centre",
         p.STATUS AS "Status",
         p.PERSONTYPE AS "Person Type",
         p.CENTER || 'p' || p.ID AS "Member ID",
         p.ADDRESS1 AS "Address1",
         p.ADDRESS2 AS "Address2",
         p.CITY AS "City",
         p.ZIPCODE AS "Zipcode",
         email.TXTVALUE AS "Email",
         pr.NAME AS "Subscription",
         sp.PRICE AS "Subscription Price",
         sp.TYPE AS "PriceUpdate Type"
 FROM
         PERSONS p
 JOIN
         SUBSCRIPTIONS s
         ON
                 p.CENTER = s.OWNER_CENTER
                 AND p.ID = s.OWNER_ID
 JOIN
         SUBSCRIPTION_PRICE sp
         ON
                 sp.SUBSCRIPTION_CENTER = s.CENTER
                 AND sp.SUBSCRIPTION_ID = s.ID
 JOIN
         CENTERS c
         ON
                 c.ID = p.CENTER
 JOIN
         SUBSCRIPTIONTYPES st
         ON
                 st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                 AND st.ID = s.SUBSCRIPTIONTYPE_ID
 JOIN
         PRODUCTS pr
         ON
                 pr.CENTER = st.CENTER
                 AND pr.ID = st.ID
 LEFT JOIN
         PERSON_EXT_ATTRS email
         ON
                 email.PERSONCENTER = p.CENTER
                 AND email.PERSONID = p.ID
                 AND email.NAME = '_eClub_Email'
 WHERE
         p.STATUS NOT IN (4,5,7,8)
         AND p.CENTER IN (:Scope)
         AND sp.TYPE = 'SCHEDULED'
         AND sp.APPROVED = true
         AND sp.CANCELLED = false
         AND sp.FROM_DATE = :FromDate
