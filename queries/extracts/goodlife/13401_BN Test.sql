-- Price Changes Triggered by Me

SELECT
sp.subscription_center||'ss'||sp.subscription_id AS subscription_id
,sp.from_date
,sp.to_date
,TO_CHAR(LONGTODATEC(sp.entry_time,990),'YYYY-MM-DD HH24:MI:SS') AS entry_date
,sp.type
,sp.coment
,sp.price
,sp2.price AS previous_price

FROM

subscription_price sp

JOIN subscription_price sp2
ON sp.subscription_center = sp2.subscription_center
AND sp.subscription_id = sp2.subscription_id
AND sp.id != sp2.id
AND sp.from_date - sp2.to_date = 1

JOIN subscriptions s
ON s.center = sp.subscription_center
AND s.id = sp.subscription_id

WHERE

sp.employee_center = 990
AND sp.employee_id = 2660 -- Employee id of associate processing person type change
AND sp.cancelled = FALSE
AND sp2.cancelled = FALSE
AND sp.price != sp2.price
AND TO_DATE(TO_CHAR(LONGTODATEC(sp.entry_time,990),'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD') = CURRENT_DATE

AND s.sub_state NOT IN (7,8) -- Regretted, Cancelled
    -- Can probably exclude more, but will add as needed. Easier to keep a wider net