-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-1991
 SELECT
     c.ID    CENTER_ID
   ,c.NAME   CENTER_NAME
   ,up.NAME  ACCESS_POINT
   ,act.NAME ACTION_NAME
   , br.NAME RESOURCE_NAME
   ,g.NAME   GATE_NAME
 FROM
     CENTERS c
 LEFT JOIN
     GATES g
 ON
     g.CENTER = c.id
 LEFT JOIN
     USAGE_POINT_RESOURCES act
 ON
     act.GATE_CENTER = g.CENTER
     AND act.GATE_ID = g.id
 LEFT JOIN
     USAGE_POINTS up
 ON
     up.CENTER = act.USAGE_POINT_CENTER
     AND up.id = act.USAGE_POINT_ID
 LEFT JOIN
     DEVICES d
 ON
     d.id = g.DEVICE_ID
 LEFT JOIN
     USAGE_POINT_SOURCES ups
 ON
     ups.USAGE_POINT_CENTER = up.CENTER
     AND ups.USAGE_POINT_ID = up.ID
     AND ups.READER_DEVICE_ID = g.DEVICE_ID
 LEFT JOIN
     USAGE_POINT_ACTION_RES_LINK uparl
 ON
     uparl.action_center = ups.ACTION_CENTER
     AND uparl.action_id = ups.ACTION_ID
 LEFT JOIN
     BOOKING_RESOURCES br
 ON
     br.CENTER = uparl.RESOURCE_CENTER
     AND br.ID = uparl.RESOURCE_ID
 WHERE
     NOT (
         upper(trim(act.NAME)) = upper(trim(g.NAME))
         AND upper(trim(act.NAME)) = upper(trim(br.NAME)))
 and c.id in ($$scope$$)
