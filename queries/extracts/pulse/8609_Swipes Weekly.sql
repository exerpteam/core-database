 SELECT
    "Name", "Resource Name", "Week of Year", "Home Club", SUM("Local Visit") AS "Local Visit Count",
    "Guest Visit Club Name", SUM("Guest Visit") AS "Guest Visit Count",
    SUM("Total Visits in Period") AS "Total Visits in Period"
 FROM
 (
 SELECT
    brg.NAME AS "Name",
    TO_CHAR(longtodate(att.START_TIME),'YYYY-WW') AS "Week of Year",
    CASE
         WHEN att.PERSON_CENTER = att.BOOKING_RESOURCE_CENTER THEN 1
         ELSE 0
    END "Local Visit",
    CASE
         WHEN att.PERSON_CENTER <> att.BOOKING_RESOURCE_CENTER THEN 1
         ELSE 0
    END "Guest Visit",
    1 AS "Total Visits in Period",
    CASE
         WHEN att.PERSON_CENTER <> att.BOOKING_RESOURCE_CENTER THEN gc.SHORTNAME
         ELSE ''
    END "Guest Visit Club Name",
    c.SHORTNAME AS "Home Club",
    br.NAME AS "Resource Name"
 FROM
    attends att
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
 ) t1
 GROUP BY "Name", "Week of Year", "Home Club", "Guest Visit Club Name","Resource Name"
