SELECT
	br.CENTER,
    count(br.CENTER) as Count_pr_center
FROM
    SATS.BOOKING_RESTRICTIONS br
where
    br.START_TIME > :date_from
    and br.START_TIME < :date_to
    and br.center in (:scope)
group by
    br.CENTER
order by
	br.CENTER
