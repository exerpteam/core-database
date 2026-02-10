-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-5770
  SELECT
      p.CENTER || 'p' || p.ID AS "Member ID",
      p.FIRSTNAME || ' ' || p.LASTNAME "Full Name",
      c.NAME                                  AS "Center Name",
      TO_CHAR(pag.EXPIRATION_DATE,'Mon YYYY') AS "Credit Card Expiration Date"
          , prod.NAME "SUBSCRIPTION"
      , atts.TXTVALUE "EMAIL"
  FROM
      PERSONS p
  JOIN
      PERSON_EXT_ATTRS atts
  ON
      p.CENTER = atts.PERSONCENTER
      AND p.ID = atts.PERSONID
          AND atts.NAME = '_eClub_Email'
  JOIN
      ACCOUNT_RECEIVABLES ar
  ON
      ar.CUSTOMERCENTER = p.CENTER
  AND ar.CUSTOMERID = p.ID
  JOIN
      PAYMENT_ACCOUNTS pac
  ON
      pac.center = ar.center
  AND pac.ID = ar.ID
  AND ar.AR_TYPE = 4
  JOIN
      PAYMENT_AGREEMENTS pag
  ON
      pac.ACTIVE_AGR_CENTER = pag.center
  AND pac.ACTIVE_AGR_ID = pag.ID
  AND pac.ACTIVE_AGR_SUBID = pag.SUBID
  JOIN
      CENTERS c
  ON
      p.CENTER = c.ID
  JOIN
      SUBSCRIPTIONS s
  ON
      s.owner_center = p.center AND s.owner_id = p.id  AND s.state = 2
  JOIN
      SUBSCRIPTIONTYPES st
  ON
      st.CENTER =  s.SUBSCRIPTIONTYPE_CENTER AND st.ID = s.SUBSCRIPTIONTYPE_ID AND st.ST_TYPE = 1
  JOIN
          PRODUCTS prod
  ON
          prod.CENTER = st.CENTER
      AND prod.ID = st.ID
  WHERE
      -- pag.CLEARINGHOUSE = 803
   pag.ACTIVE = 1
  AND p.status IN (1,3,8)
  AND p.CENTER IN (:scope)
  AND pag.EXPIRATION_DATE BETWEEN (:StartDate) AND (
          :EndDate)
