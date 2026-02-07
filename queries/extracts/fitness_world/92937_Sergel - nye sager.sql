-- This is the version from 2026-02-05
--  
SELECT DISTINCT
p.center ||'p'|| p.id AS person_id,
p.fullname AS full_name,
p.address1 AS address_1,
p.zipcode AS postcode,
p.city AS city,
replace(mobile.txtvalue, '+45', '') AS phone_mobile,
email.txtvalue AS e_mail,
p.ssn AS ssn,
ccr.ref AS invoice_ref,
pr.req_date AS req_date,
pr.due_date AS due_date,
pr.req_amount AS original_amount,
prs.inv_diff*-1 AS rykker2,
--prs.open_amount AS open_amount,
TO_CHAR(p.birthdate, 'dd-MM-YYYY') AS DOB
FROM
cashcollection_requests ccr
JOIN
cashcollectioncases ccc
ON
ccc.center = ccr.center
AND ccc.id = ccr.id
JOIN
payment_requests pr
ON
pr.center = ccr.payment_request_center
AND pr.id = ccr.payment_request_id
AND pr.subid = ccr.payment_request_subid
JOIN
payment_request_specifications prs
ON
prs.center = ccr.prscenter
AND prs.id = ccr.prsid
AND prs.subid = ccr.prssubid
JOIN
persons p
ON
p.center = ccc.personcenter
AND p.id = ccc.personid
LEFT JOIN
person_ext_attrs mobile
ON
mobile.personcenter = p.center
AND mobile.personid = p.id
AND mobile.name = '_eClub_PhoneSMS'
LEFT JOIN
person_ext_attrs email
ON
email.personcenter = p.center
AND email.personid = p.id
AND email.name = '_eClub_Email'
WHERE
CAST(ccr.req_delivery AS VARCHAR(10)) IN (:file)