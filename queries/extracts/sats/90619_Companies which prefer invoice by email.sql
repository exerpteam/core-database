select
p.center ||'p'|| p.id as CompanyID,
p.fullname as companyname,
pea.txtvalue,
p.prefer_invoice_by_email,
ch.name as clearing_house


from persons p

join person_ext_attrs pea
on
pea.personcenter = p.center
and
pea.personid = p.id
and pea.name = '_eClub_InvoiceEmail'

JOIN ACCOUNT_RECEIVABLES ar ON p.CENTER = ar.CUSTOMERCENTER AND p.ID = ar.CUSTOMERID

JOIN PAYMENT_ACCOUNTS pac on pac.CENTER = ar.CENTER AND pac.ID = ar.ID AND ar.AR_TYPE = 4

join PAYMENT_AGREEMENTS pag on pac.ACTIVE_AGR_CENTER = pag.CENTER AND pac.ACTIVE_AGR_ID = pag.ID AND pac.ACTIVE_AGR_SUBID = pag.SUBID

join CLEARINGHOUSES ch ON ch.ID = pag.CLEARINGHOUSE

where 
p.sex = 'C'
--and p.center = 500 and p.id = 468149
and p.prefer_invoice_by_email is true
and p.center in (:scope)
and ch.id = :clearing_house