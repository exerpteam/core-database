SELECT crt.center AS CashRegisterCenter
, crt.id AS CashRegisterId
, TO_CHAR(longtodateC(crt.transtime, 100), 'YYYY-MM-dd HH24:MI') AS TransactionTime
, TO_CHAR(longtodateC(crr.reporttime, 100), 'YYYY-MM-dd HH24:MI') AS ReportTime
,* 

FROM cashregistertransactions crt

JOIN cashregisterreports crr
ON crr.center = crt.crcenter
AND crr.id = crt.crid
AND crr.subid = crt.crsubid

WHERE crt.center=$$CashRegisterCenter$$
AND crt.id IN ($$CashRegisterNumber$$)
	AND crt.transtime BETWEEN
		CAST((:Transaction_Start_Date-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000 
        AND CAST((:Transaction_End_Date-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000+86399000