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
	gc.EXPIRATIONDATE AS EXPIRATION_DATE,
	add_months(gc.EXPIRATIONDATE,2) AS NEW_EXPIRATION_DATE,
	gc.center||'gc'||gc.id AS Gift_Card_Id,
	gc.Amount,
	gc.AMOUNT_REMAINING
FROM
	GIFT_CARDS gc
JOIN
    PARAMS
ON
	PARAMS.center = gc.center
WHERE
	gc.state in (0, 4)
AND gc.EXPIRATIONDATE >= PARAMS.StartDate 
AND gc.center != 584
	

