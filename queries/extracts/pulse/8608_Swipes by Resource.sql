 SELECT
    brg.NAME AS "Name",
    TO_CHAR(longtodate(att.START_TIME),'YYYY-MM-DD') AS "Date",
    CASE
         WHEN att.PERSON_CENTER = att.BOOKING_RESOURCE_CENTER THEN 'Yes'
         ELSE 'No'
    END "Local Visit",
    CASE
         WHEN att.PERSON_CENTER = att.BOOKING_RESOURCE_CENTER THEN TO_CHAR(longtodate(att.START_TIME),'HH24:MM')
         ELSE ''
    END "Time of Checkin",
    CASE
         WHEN att.PERSON_CENTER = att.BOOKING_RESOURCE_CENTER THEN 'No'
         ELSE 'Yes'
    END "Guest Visit",
    CASE
         WHEN att.PERSON_CENTER = att.BOOKING_RESOURCE_CENTER THEN ''
         ELSE TO_CHAR(longtodate(att.START_TIME),'HH24:MM')
    END AS "Time of Guest Checkin",
    CASE
         WHEN att.PERSON_CENTER <> att.BOOKING_RESOURCE_CENTER THEN gc.SHORTNAME
         ELSE ''
    END "Guest Visit Club Name",
    pr.NAME AS "Subscription Name",
    p.CENTER||'p'||p.ID AS "Person ID",
    p.FULLNAME AS "Person Name",
    c.SHORTNAME AS "Home Club",
    br.NAME AS "Resource Name",
    br.EXTERNAL_ID AS "Resource External ID"
 FROM
    attends att
 JOIN
    persons p
 ON
    att.PERSON_CENTER = p.CENTER
    AND att.PERSON_ID = p.ID
 JOIN
    SUBSCRIPTIONS s
 ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
    AND longtodate(att.START_TIME) > s.START_DATE
    AND longtodate(att.START_TIME) < s.END_DATE
 JOIN
    PRODUCTS pr
 ON
    s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = pr.ID
 JOIN
    BOOKING_RESOURCES br
 ON
    att.BOOKING_RESOURCE_CENTER = br.CENTER
    AND att.BOOKING_RESOURCE_ID = br.ID
 JOIN
    CENTERS c
 ON
    att.PERSON_CENTER = c.ID
 JOIN
     BOOKING_RESOURCE_CONFIGS brc
 ON
     brc.BOOKING_RESOURCE_CENTER = att.BOOKING_RESOURCE_CENTER
     AND brc.BOOKING_RESOURCE_ID = att.BOOKING_RESOURCE_ID
 JOIN
     BOOKING_RESOURCE_GROUPS brg
 ON
     brg.ID = brc.GROUP_ID
     AND brg.STATE = 'ACTIVE'
 JOIN
    CENTERS gc
 ON
    att.BOOKING_RESOURCE_CENTER = gc.ID
 WHERE
    att.START_TIME BETWEEN $$From_Date$$ AND $$To_Date$$
    AND c.ID in ($$Centers$$)
