SELECT
     bo.center AS ClubId,
     c.name    AS ClubName,
     SUM(
         CASE
             WHEN USER_INTERFACE_TYPE = 2
             THEN 1
             ELSE 0
         END) "Website",
SUM(
	CASE
		WHEN pa.creation_by_id = 24601 THEN 1
		ELSE 0
	END) "Mwc Technogym",
SUM(
	CASE
        WHEN pa.creation_by_id = 87601 THEN 1
        ELSE 0
    END) AS "exaware api",
     SUM(
         CASE
             WHEN USER_INTERFACE_TYPE = 6
             THEN 1
             ELSE 0
         END) "Mobile API",
     SUM(1) AS "Total"
 FROM
     PARTICIPATIONS pa
 JOIN
     BOOKINGS bo
 ON
     bo.CENTER = pa.BOOKING_CENTER
     AND bo.ID = pa.BOOKING_ID
 JOIN
     centers c
 ON
     c.id = bo.center
 WHERE
     bo.CENTER IN ($$Scope$$)
     AND bo.STARTTIME >= $$StartDate$$
     AND bo.STARTTIME <= ($$EndDate$$ + 86400000)
     AND bo.STATE='ACTIVE'
     AND pa.user_interface_type IN (2,6)
 GROUP BY
     bo.center ,
     c.name