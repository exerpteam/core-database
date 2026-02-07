WITH
    params AS
    (
        SELECT
            /*+ materialize */
			c.id AS center,
			to_date('12-03-2020', 'dd-MM-yyyy') AS StartDate,
			datetolongC(to_char(to_date('25-03-2020', 'dd-MM-yyyy')+1,'YYYY-MM-DD HH24:MI'), c.ID) AS EndDate,
			dateToLongC(to_char(trunc(current_date),'YYYY-MM-DD HH24:MI'), c.ID) AS today
--     	    ClosedFromDate AS StartDate,
--			ClosedToDate AS EndDate,
		FROM
			CENTERS c
    )
SELECT 
	gc.PAYER_CENTER||'p'||gc.PAYER_ID as person, 
	DECODE(gc.STATE, 0, 'ISSUED', 1, 'CANCELLED', 2, 'EXPIRED', 3, 'USED', 4, 'PARTIAL USED') AS "State",
	gc.EXPIRATIONDATE,
	gc.center||'gc'||gc.id AS Gift_Card_Id,
	gc.Amount,
	gc.AMOUNT_REMAINING,
    to_char(longtodateC(gc.use_time, gc.center),'YYYY-MM-DD') AS Last_Used_Date
FROM
	GIFT_CARDS gc
JOIN
    PARAMS
ON
	PARAMS.center = gc.center
WHERE
	gc.EXPIRATIONDATE >= PARAMS.StartDate 
	AND gc.state = 2
	AND gc.center != 584
