-- The extract is extracted from Exerp on 2026-02-08
-- RG WIP 11.05.22
 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             $$startdate$$                    AS PeriodStart,
             ($$enddate$$ + 86400 * 1000) - 1 AS PeriodEnd)

SELECT * 
FROM 
	Bookings BO 
CROSS JOIN
     params
WHERE 
	bo.STARTTIME>= CAST(params.PeriodStart AS BIGINT)
AND 
	bo.STARTTIME<= CAST(params.PeriodEnd AS BIGINT)
AND 
	bo.CENTER IN ($$scope$$)
-- AND 
	-- bo.STATE='ACTIVE'