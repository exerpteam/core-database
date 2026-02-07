SELECT
p.center||'p'|| p.id as memberid,
longtodate(VALID_UNTIL),
 i.EMPLOYEE_CENTER ||'emp'||  i.EMPLOYEE_ID as sales_employee

from
clipcards cl2

join products pr2

on
pr2.center = cl2.center
AND pr2.id = cl2.id

join INVOICE_LINES_MT il
on
il.center = cl2.INVOICELINE_CENTER
and
il.id = cl2.INVOICELINE_ID
and
il.subid = cl2.INVOICELINE_SUBID

join INVOICES i
on
il.center = i.center
and
il.id = i.id

join persons p
on
cl2.OWNER_CENTER = p.center
and
cl2.OWNER_ID = p.id
Where
cl2.VALID_FROM between :fromdate and :todate
and (cl2.finished = 0 and pr2.GLOBALID = 'PTSTARTNEW')
and i.EMPLOYEE_CENTER != 415 and i.EMPLOYEE_ID != 5201
and p.center in (:scope)