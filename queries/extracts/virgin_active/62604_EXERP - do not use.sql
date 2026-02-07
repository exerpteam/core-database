   
    SELECT
    p.center||'p'||p.id,
    p.city,
p.zipcode,
zip.*
FROM
    persons p
    JOIN zipcodes zip
    on zip.zipcode = p.zipcode
WHERE
    p.country= 'IT'
--AND p.zipcode = '80132'
--and p.center = 233
--and p.id = 50072 
AND p.center||'p'||p.id IN ('245p238','233p50072','203p45660')
AND p.city::varchar ~ '[\u0009\u0020\u00A0\u1680\u2000-\u200A\u202F\u205F\u3000]+'