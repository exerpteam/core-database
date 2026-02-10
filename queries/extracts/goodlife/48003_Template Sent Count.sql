-- The extract is extracted from Exerp on 2026-02-08
-- Created by: Sandra G Created on: 5.7.24  Created for: DE Team to see which email templates are sent the most  Note: run with small date range or it will hang
SELECT


TO_DATE(TO_CHAR(longtodateC(m.senttime,990),'YYYY-MM-DD'),'YYYY-MM-DD') AS sentdate
,CASE 
	WHEN m.subject LIKE 'Your GoodLife Fitness verification code is:%'
	THEN 'Your GoodLife Fitness verification code is: ********'
	WHEN m.subject LIKE 'Booking Cancelled%'
	THEN 'Booking Cancelled'
	ELSE COALESCE(t.description,m.subject,'NULL') 
END AS subject
,COUNT(*)

FROM


messages m

LEFT JOIN templates t
ON t.id = m.templateid


WHERE

m.deliverymethod = 1 -- email
AND m.senttime BETWEEN EXTRACT(EPOCH FROM CAST($$dayFrom$$ AS DATE)) * 1000
AND EXTRACT(EPOCH FROM CAST($$dayTo$$ AS DATE)) * 1000
AND 
TO_DATE(TO_CHAR(longtodateC(m.senttime,990),'YYYY-MM-DD'),'YYYY-MM-DD') BETWEEN CAST($$dayFrom$$ AS DATE) AND CAST($$dayTo$$ AS DATE)

GROUP BY 1,2