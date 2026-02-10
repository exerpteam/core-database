-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
s.owner_center AS "Medlem Center",
s.owner_id::varchar(20) AS "Medlem ID",
sfp.start_date AS "Start",
sfp.end_date AS "Stop",
TO_CHAR(longtodateC(sfp.entry_time, s.owner_center), 'dd-MM-YYYY') AS "Registreringsdato",
sfp.text AS "Tekst",
TO_CHAR(longtodateC(sfp.last_modified, s.owner_center), 'dd-MM-YYYY') AS "Seneste justering",
s.binding_end_date AS "Bindingsperiode slut",
s.binding_price AS "Bindingspris",
s.subscription_price AS "Medlemskabspris"
FROM
subscriptions s
JOIN
subscription_freeze_period sfp
ON
sfp.subscription_center = s.center
AND sfp.subscription_id = s.id
WHERE
s.owner_center ||'p'|| s.owner_id IN (:memberid)