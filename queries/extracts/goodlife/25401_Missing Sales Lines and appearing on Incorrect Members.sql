
select 
  DISTINCT 
  il.person_center||'p'||il.person_id AS "Member ID"
  ,i.payer_center||'p'||i.payer_id AS "Payer ID"
  ,TO_CHAR(longtodateC(i.entry_time, i.center),'YYYY-MM-DD') "Sales Date"
from 
  invoices i
JOIN
  invoice_lines_mt il
ON
  i.center = il.center
  AND i.ID = il.ID
LEFT JOIN
  relatives r
ON
  r.center = i.payer_center  
  AND r.id = i.payer_id   
  AND r.rtype in (12,14, 2)  -- other payer, parenting
where 
  i.payer_center||'p'||i.payer_ID <> il.person_center||'p'||il.person_id 
  AND
  r.center IS NULL 
  AND i.center in (:center)
  AND i.entry_time > 1546300800000
  