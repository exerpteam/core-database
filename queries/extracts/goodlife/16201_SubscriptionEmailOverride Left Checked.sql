SELECT

p.personcenter||'p'||p.personid AS "Person_ID"

FROM

person_ext_attrs p, persons per

WHERE

p.name = 'SubscriptionEmailOverride'
AND p.txtvalue = 'true'
AND p.personcenter = per.center
AND p.personid = per.id
AND per.external_id IS NOT NULL