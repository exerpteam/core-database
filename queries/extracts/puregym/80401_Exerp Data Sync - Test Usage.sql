-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
			TO_CHAR(make_date(2023, 1, 9), 'YYYY-MM-DD HH24:MI') AS ABSDATE,
            datetolongC(TO_CHAR(make_date(2023, 1, 9), 'YYYY-MM-DD HH24:MI'), 100)::bigint AS ABSDATELONG
