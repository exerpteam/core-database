WITH
    params AS
    (
        SELECT
            /*+ materialize */
			c.id AS center,
			datetolongC(to_char(to_date('12-03-2020', 'dd-MM-yyyy'),'YYYY-MM-DD HH24:MI'), c.ID) AS StartDate,
			datetolongC(to_char(to_date('25-03-2020', 'dd-MM-yyyy')+1,'YYYY-MM-DD HH24:MI'), c.ID) AS EndDate,
			dateToLongC(to_char(trunc(current_date),'YYYY-MM-DD HH24:MI'), c.ID) AS today
--     	    ClosedFromDate AS StartDate,
--			ClosedToDate AS EndDate,
		FROM
			CENTERS c
    )
SELECT 
	c.OWNER_CENTER||'p'||c.OWNER_ID AS PersonID,
	c.CENTER||'cc'||c.ID||'cc'||c.SUBID AS ClipCardID,
	TO_CHAR(longtodateC(c.VALID_FROM,c.CENTER),'YYYY-MM-DD') AS ValidFrom,
	TO_CHAR(longtodateC(c.VALID_UNTIL,c.CENTER),'YYYY-MM-DD') AS ValidUntil,
	TO_CHAR(longtodateC(c.VALID_UNTIL+60*24*60*60*1000,c.CENTER),'YYYY-MM-DD') AS New_Valid_Until_Date,
	c.clips_left  AS ClipsLeft
FROM
    CLIPCARDS C
JOIN
    PARAMS
ON
    c.CENTER = PARAMS.CENTER
WHERE 
    c.VALID_UNTIL >= params.startDate
	AND c.VALID_FROM < params.EndDate
	AND c.CANCELLED = 0 
	AND c.BLOCKED = 0 
	AND c.CLIPS_LEFT > 0
	AND 
	(
	-- Clipcard is valid before closed period ends
		(c.VALID_UNTIL > params.EndDate AND c.FINISHED = 0)
	OR
	-- Clipcard was valid just after closed period but it is ended before we run this script, 
	-- so it has been cancelled by batch job even though it has clips left on it.
		(c.VALID_UNTIL < params.today AND c.VALID_UNTIL >= params.StartDate AND c.FINISHED = 1 )
	)
	AND c.center in ($$Scope$$)
