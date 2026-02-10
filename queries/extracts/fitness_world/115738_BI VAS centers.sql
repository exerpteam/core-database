-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            datetolongTZ(TO_CHAR(date_trunc('day', CURRENT_DATE)- INTERVAL '5 days', 'YYYY-MM-DD HH24:MI'), 'Europe/Copenhagen')::bigint AS FROMDATE,
            datetolongTZ(TO_CHAR(date_trunc('day', CURRENT_DATE+INTERVAL '1 days'), 'YYYY-MM-DD HH24:MI'), 'Europe/Copenhagen')::bigint AS TODATE
		)
select
cen.ID,
cea.TXT_VALUE AS Region
from params, centers cen
LEFT JOIN CENTER_EXT_ATTRS cea
ON cen.ID = cea.CENTER_ID
AND cea.NAME = 'Region'
Where cen.ID in (:scope)
AND cen.LAST_MODIFIED >= params.FROMDATE 
AND cen.LAST_MODIFIED < params.TODATE 
