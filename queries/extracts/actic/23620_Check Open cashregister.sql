/*
* Creator: Exerp
* Purpose: List all cashregisters of type POS and status OPEN.
*/
SELECT 
	cr.CENTER,
	cr.ID,
	cr.CENTER || 'cr' || cr.ID AS crID,
	cr.NAME,
	cr.CONTROL_DEVICE_ID,
	cr.CASH_BALANCE,
	cr.STATE

FROM CASHREGISTERS cr

WHERE
	cr.TYPE = 'POS'
AND
	cr.STATE = 'OPEN'
ORDER BY
	cr.CENTER