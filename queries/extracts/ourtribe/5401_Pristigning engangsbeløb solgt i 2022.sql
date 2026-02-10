-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center||'p'|| p.id as personid,
    p.firstname,
    p.lastname,
email.TXTVALUE         as        "e-mail",
    CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
    inv.text,
    prod.NAME "Product name",
    invl.QUANTITY "Product sold",
    invl.TOTAL_AMOUNT "Product price",
 --   to_char(exerpro.longtodate(inv.trans_time), 'DD-MM-YYYY HH24:MI')  "Entry date",
--cn.CENTER ||'cred'|| cn.id,
longtodate(inv.TRANS_TIME) as salesdate

FROM
   INVOICES inv
JOIN
    invoice_lines_mt invl 
ON
    invl.CENTER = inv.CENTER
    AND invl.ID = inv.ID    
JOIN PERSONS p
ON
    p.id = invl.person_id
    AND p.center = invl.person_center    
JOIN
    PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
    AND prod.PTYPE = 2
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER=p.center
    AND email.PERSONID=p.id
    AND email.name='_eClub_Email'

WHERE
 inv.text = 'Prisstigning, engangsbeløb'