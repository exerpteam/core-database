 with dup as (
 SELECT
     email.TXTVALUE,
         p.BIRTHDATE,
         p.center,
         p.id,
         p.firstname,
         p.lastname,
         p.status,
         COUNT(*) OVER (PARTITION BY email.TXTVALUE, p.BIRTHDATE ) AS cnt
 FROM
     Persons p
 JOIN
     PERSON_EXT_ATTRS email
 ON
     email.PERSONCENTER = p.center
     AND email.PERSONID = p.id
     AND email.name = '_eClub_Email'
         AND email.TXTVALUE is not null
 WHERE
     p.center in (:Scope)
     AND p.status NOT IN (7,8)
     AND p.BIRTHDATE is not null
 )
 SELECT
    hashtext(dup.TXTVALUE||dup.BIRTHDATE) AS "Group Key",
    dup.center||'p'||dup.id AS "Membership number",
    dup.FIRSTNAME AS "First name",
    dup.LASTNAME AS "Last name",
    dup.TXTVALUE AS "Email address",
    dup.BIRTHDATE AS "DOB",
    CASE  dup.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS "Person Status",
    cre.TXTVALUE AS "Person creation date",
    c.SHORTNAME AS "Home club",
    pr.NAME AS "Current subscription name",
    CASE st.ST_TYPE  WHEN 0 THEN  'CASH'  WHEN 1 THEN  'EFT'  WHEN 3 THEN  'Prospect' END AS "Current subscription type",
    CASE  s.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS "Current subscription state",
    TO_CHAR(s.START_DATE,'YYYY-MM-DD') AS "Subscription start date",
    TO_CHAR(s.END_DATE,'YYYY-MM-DD') AS "Subscription end date"
 from
    dup
 JOIN
    CENTERS c
 ON
    dup.center = c.id
 LEFT JOIN
    PERSON_EXT_ATTRS cre
 ON
    cre.PERSONCENTER = dup.center
    AND cre.PERSONID = dup.id
    AND cre.name = 'CREATION_DATE'
 LEFT JOIN
    SUBSCRIPTIONS s
 ON
    s.OWNER_CENTER = dup.CENTER
    AND s.OWNER_ID = dup.ID
    AND s.STATE in (2,4,7,8)
 LEFT JOIN
    SUBSCRIPTIONTYPES st
 ON
    s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = st.ID
 LEFT JOIN
    PRODUCTS pr
 ON
    st.CENTER = pr.CENTER
    AND st.ID = pr.ID
 WHERE
    dup.cnt > 1
