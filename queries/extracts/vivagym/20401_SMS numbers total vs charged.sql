-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-9847
WITH params AS materialized
(
   SELECT 
     CAST(datetolongC(TO_CHAR(to_date(:from_date,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI'), 100) AS BIGINT) AS from_datetime,
     CAST(datetolongC(TO_CHAR(to_date(:to_date,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI'), 100) AS BIGINT) + 24*60*60*1000 AS to_datetime

)
SELECT
    count(*) as number_of_sms,
    sum(case when convert_from(MIMEVALUE, 'UTF-8') ~ '[áéíóúÁÉÍÓÚñÑüÜàèìòùÀÈÌÒÙâêîôûÂÊÎÔÛ]' 
          then ceil(length(mimevalue)/70::decimal)
          else ceil(length(mimevalue)/160::decimal)
        end) as charged_sms   
FROM
    messages m,
    params p
WHERE
    m.senttime >= p.from_datetime
AND m.senttime < p.to_datetime
and m.DELIVERYCODE = 6 --sms
