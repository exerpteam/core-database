-- The extract is extracted from Exerp on 2026-02-08
-- Refund ex Id 5004125 for Germany
Select
c.shortname as "Beschreibung (intern)",
p.center ||'p'|| p.id as "Kategorie", 
'' as "Hohe Priorität",
'Ja' as "Sammelbuchung",
cea.txt_value as "Auftraggeber IBAN",
'' as "Auftraggeber BIC",
pa.bank_account_holder as "Empfänger",
'' as "Abweichender Auftraggeber",
pa.iban as "EmpfängerIBAN",
pa.bic as "Empfänger BIC", 
'' as "Abweichender Zahlungsempfänger",
art.amount as "Betrag",
'' as "Ende-zu-Ende Referenz",
longtodate(art.trans_time) as "Ausführungsdatum",
'' as "Anweisung-ID",
'' as "Vwz.-Code",
art.text as "Verwendungszweck" 

   
From   
   ACCOUNT_RECEIVABLES ar
                JOIN
                    persons p
                ON
                    p.center = ar.CUSTOMERCENTER
                AND p.id = ar.CUSTOMERID
                JOIN
                    AR_TRANS art
                ON
                    ar.CENTER = art.CENTER
                AND ar.ID = art.ID
join account_trans act
on
act.center = art.ref_center
and
act.id = art.ref_id
and
act.subid = art.ref_subid

LEFT JOIN  ACCOUNTS credit
on
act.credit_accountcenter = credit.center
and
act.credit_accountid = credit.id

left join ACCOUNTS debit
on
act.debit_accountcenter = debit.center
and
act.debit_accountid = debit.id

left join payment_agreements pa
on
pa.id = ar.id
and
pa.center = ar.center
and
active = 'true'
 
join centers c
on
p.center = c.id

left join center_ext_attrs cea
on
c.id = cea.center_id
and cea.name = 'CompanyIBAN'

where 
ar.customercenter in (:scope)
and
art.trans_time between(:fromdate)and (:todate)+86400 
 and
 (debit.external_id =  (:externalid) or
 credit.external_id = (:externalid))
