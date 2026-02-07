  SELECT 
	TO_CHAR(t1.prev_day, 'Day')                        AS weekday,
	TO_CHAR(t1.prev_day2, 'Day')                        AS weekday,
		TO_CHAR(t1.prev_day3, 'Day')                        AS weekday,
			TO_CHAR(t1.prev_day4, 'Day')                        AS weekday,
		TO_CHAR(t1.prev_day5, 'Day')                        AS weekday,
	TO_CHAR(t1.prev_day6, 'Day')                        AS weekday,
	TO_CHAR(t1.prev_day7, 'Day')                        AS weekday
	FROM (SELECT distinct
        TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '1 day' AS prev_day,
		 TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '2 day' AS prev_day2,
		TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '3 day' AS prev_day3,
		TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '4 day' AS prev_day4,
		TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '5 day' AS prev_day5,
		TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '6 day' AS prev_day6,
		TO_DATE(getcentertime(c.id), 'YYYY-MM-DD') - interval '7 day' AS prev_day7
        FROM
            centers c
        WHERE
            c.country = 'IT'
        AND c.id != 100) t1


