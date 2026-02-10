-- The extract is extracted from Exerp on 2026-02-08
-- Copy of ExportCourseDetails to remove usage calculations
/*Export details that are not existing in Exerps CourseAPI.
This should be extracted on the website and additional information added to course.
Parameters are for any booking in the course and all the other bookings will be extracted as well*/
SELECT
	b2.CENTER as BOOKING_CENTER,
	b2.ID as BOOKING_ID,
	b2.BOOKING_PROGRAM_ID as PROGRAM_ID,
	b2.NAME as COURSE_NAME,
	TO_CHAR(LONGTODATE(b2.STARTTIME),'YYYY-MM-DD') as START_DATE,
	TO_CHAR(LONGTODATE(b2.STARTTIME),'HH24:MI') as START_TIME,
	TO_CHAR(LONGTODATE(b2.STOPTIME),'HH24:MI') as END_TIME, -- || ' (' || res.NAME || ')' as END_TIME,
	b2.DESCRIPTION as DESCRIPTION,
	COUNT (DISTINCT par.ID) as BOOKED,
		CASE 
		WHEN b2.NAME LIKE '%CHALLENGE%' THEN 10
	ELSE b2.CLASS_CAPACITY
	END as CAPACITY,
	CAST (CASE 	

		WHEN LOWER(b2.NAME) LIKE 'kom i%' THEN 218.68
		WHEN LOWER(b2.NAME) LIKE 'actic smallgroup training junior%' THEN 187.38
		WHEN LOWER(b2.NAME) LIKE 'actic small group training 1 ggr%' THEN 320		
		WHEN LOWER(b2.NAME) LIKE 'small group 1 %' THEN 320		
 		WHEN LOWER(b2.NAME) LIKE 'actic small%' THEN 249.875
 		WHEN LOWER(b2.NAME) LIKE 'small group%' THEN 249.875
		WHEN c.ID = 9 THEN
			CASE
				WHEN LOWER(b2.NAME) LIKE '%crawl%' THEN 193.25
				ELSE 193.25
			END			
		WHEN c.ID = 32 THEN 
			CASE
				WHEN LOWER(b2.NAME) = 'acticloppet' THEN 0
				WHEN LOWER(b2.NAME) LIKE '%simskola nivå%' THEN 200
				ELSE 250
			END
		WHEN c.ID = 110 THEN 250
		WHEN c.ID = 175 THEN 312.38
		WHEN c.ID = 181 THEN 187.5
		WHEN c.ID = 183 THEN 
			CASE
				WHEN LOWER(b2.NAME) LIKE '%mini%' THEN 220
				ELSE 200
			END
		WHEN c.ID = 197 THEN 320
		WHEN c.ID = 536 THEN 300
		WHEN c.ID = 9220 THEN 312.38
		WHEN c.ID = 9226 THEN 249.875
		WHEN c.ID = 9236 THEN 250
		WHEN c.ID = 9235 THEN 218.13
		WHEN c.ID = 9271 THEN
			CASE 
				WHEN LOWER(b2.NAME) LIKE '%vuxensimskola%' THEN 275
				WHEN LOWER(b2.NAME) LIKE '%simbana%' THEN 0
				WHEN LOWER(b2.NAME) LIKE '%crawl privatlektion%' THEN 950
				WHEN LOWER(b2.NAME) LIKE '%privatlektion 30%' THEN 650
				WHEN LOWER(b2.NAME) LIKE '%crawl nivå%' THEN 243.75
				WHEN LOWER(b2.NAME) LIKE '%crawl träningsgrupp%' THEN 200
				WHEN LOWER(b2.NAME) LIKE '%crawl masters sailfish%' THEN 109.375
				WHEN LOWER(b2.NAME) LIKE '%crawl masters marlin%' THEN 109.375
				WHEN LOWER(b2.NAME) LIKE '%crawl masters orca%' THEN 121.875
				WHEN LOWER(b2.NAME) LIKE '%crawl masters 2%' THEN 121.875
				WHEN LOWER(b2.NAME) LIKE '%crawl masters 1%' THEN 200
				ELSE 243.75
			END

		WHEN c.ID = 154 THEN 249.875
		WHEN c.ID = 9269 THEN
			CASE
				WHEN LOWER(b2.NAME) LIKE '%vuxen%' THEN 199.75
				WHEN LOWER(b2.NAME) LIKE '%relaxbokning 2 timmar%' THEN 3000
				WHEN LOWER(b2.NAME) LIKE '%realxbokning 2 timmar%' THEN 3000
				ELSE 193.75
			END
		WHEN b2.NAME LIKE '%TA TAK%' THEN 
			CASE 
				WHEN c.ID = 522 THEN 250
				ELSE 166.6
			END
		WHEN c.ID = 542 THEN 
			CASE 
				WHEN b2.NAME LIKE '%PT Gruppe%' THEN 625
				ELSE 260
			END
		WHEN c.ID = 544 THEN 
			CASE
				
				WHEN b2.NAME LIKE 'Dance Spesial%' THEN 99
				WHEN b2.NAME LIKE 'Kickstart%' THEN 250
				WHEN b2.NAME LIKE 'Yoga%' THEN 237.5
				WHEN b2.NAME LIKE 'Dans%' THEN 225
				WHEN b2.NAME LIKE 'Zumba%' THEN 225
				WHEN b2.NAME LIKE 'Toes%' THEN 199
				ELSE 1099
			END
		WHEN c.ID = 9262 THEN 
			CASE 
				WHEN b2.NAME LIKE '%exklusiv%' THEN 212
				WHEN b2.NAME LIKE '%Baby%' THEN 206.25
				WHEN b2.NAME LIKE '%Mini%' THEN 206.25
				WHEN b2.NAME LIKE '%Vuxen%' THEN 212.5
				WHEN b2.NAME LIKE '%Crawl%' THEN 206.25
				WHEN b2.NAME = 'Senior ATC Circuit' THEN 0
				WHEN b2.NAME LIKE 'LES MILLS GRIT%' THEN 0
				WHEN b2.NAME LIKE 'BODYBALANCE%' THEN 0
				WHEN b2.NAME = 'ATC Circuit' THEN 0
				ELSE 193.75
			END
		WHEN c.ID = 102 THEN
			CASE
				WHEN b2.NAME LIKE '%ntensiv%' THEN 206.25
				WHEN b2.NAME LIKE 'Baby%' THEN 181.25
				WHEN b2.NAME LIKE 'Mini%' THEN 181.25
				WHEN b2.NAME LIKE 'Familje%' THEN 181.25
				WHEN LOWER(b2.NAME) LIKE '%privatlektion barn%' THEN 499
				WHEN LOWER(b2.NAME) LIKE '%privatlektion%' THEN 599
				WHEN b2.NAME LIKE 'Sim%' THEN 206.25
				WHEN b2.NAME LIKE 'Vuxen%' THEN 243.75
				WHEN b2.NAME LIKE 'Crawl%' THEN 237.5
				WHEN b2.NAME LIKE 'Actic Small%' THEN 249.875
				ELSE 206.25
			END
		WHEN c.ID = 24 THEN 
			CASE 
				WHEN b2.NAME LIKE 'Vuxen%' THEN 275

				WHEN b2.NAME LIKE 'Crawl%' THEN 250
				WHEN LOWER(b2.NAME) LIKE '%small%' THEN 249.875
				ELSE 200
			END
		WHEN c.ID = 172 THEN 
			CASE 
				WHEN b2.NAME LIKE '%vuxen%' THEN 275
				ELSE 187.5
			END
		WHEN c.ID = 9207 THEN 
			CASE 
				WHEN b2.NAME LIKE '%HYROX%' THEN 250
				ELSE 187.5
			END

		WHEN c.ID = 8 THEN 
			CASE 
				WHEN b2.NAME LIKE 'Mini%' THEN 183.5
				WHEN b2.NAME LIKE '%steg 1%' THEN 183.5
				WHEN b2.NAME LIKE '%Babysim%' THEN 206.25
				WHEN b2.NAME = 'Simskola Krabba fr 4 år' THEN 183.35
				WHEN b2.NAME LIKE 'Simskola privatlektion barn%' THEN 499
				WHEN b2.NAME LIKE 'Simskola privatlektion%' THEN 599
				WHEN b2.NAME LIKE 'Crawl privatlektion%' THEN 699
				WHEN b2.NAME LIKE 'Simskola%' THEN 150
				WHEN b2.NAME LIKE '%Crawlkurs%' THEN 186
				WHEN b2.NAME = 'Crawl vuxen avancerad' THEN 186
				WHEN b2.NAME LIKE '%Simträning%' THEN 186
				ELSE 187.5
			END
	ELSE 187.5
	END AS TEXT) AS PRICE_PER_BOOKING,
	c.NAME AS CENTER_NAME

FROM BOOKINGS b2
LEFT JOIN PARTICIPATIONS par
	ON par.BOOKING_CENTER = b2.CENTER
	AND par.BOOKING_ID = b2.ID
	AND par.STATE IN('BOOKED','PARTICIPATION','PARTICIPATING')
LEFT JOIN CENTERS c ON
	b2.CENTER = c.ID
LEFT JOIN BOOKING_RESOURCE_USAGE brs 
	ON brs.BOOKING_CENTER = b2.CENTER
	AND brs.BOOKING_ID = b2.ID
	AND brs.STATE = 'ACTIVE'
LEFT JOIN BOOKING_RESOURCES res ON
	brs.BOOKING_RESOURCE_CENTER = res.CENTER
	AND brs.BOOKING_RESOURCE_ID = res.ID

WHERE 
	b2.CENTER = :centerId
	AND b2.BOOKING_PROGRAM_ID = :courseId
	AND b2.STATE = 'ACTIVE'
GROUP BY
	b2.ID,
	b2.CENTER,
	b2.BOOKING_PROGRAM_ID,
	b2.NAME,
	b2.STARTTIME,
	b2.STOPTIME,
	b2.DESCRIPTION,
	b2.CLASS_CAPACITY,
	c.NAME,
	c.ID
ORDER BY
	b2.STARTTIME
