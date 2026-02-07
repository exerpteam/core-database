SELECT
    br.CENTER|| 'p' ||br.ID as CustomerID,
    longToDate(br.START_TIME) as start_time,
    br.reason
FROM
    SATS.BOOKING_RESTRICTIONS br
where
    br.START_TIME > :date_from
    and br.START_TIME < :date_to
    and br.center in (:scope)
group by
    br.CENTER,
    br.ID,
    START_TIME,
	br.reason