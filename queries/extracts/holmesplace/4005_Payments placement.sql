select ch.name, cli.FILENAME,
up.xfr_date as PaymentDate, up.XFR_AMOUNT as Amount, up.XFR_DEBITOR_ID as VariableSymbolFromBankFile, xfr_text as InfoFromBank
--up.*, 
, decode(up.STATE, 1, 'NEW', 2, 'PLACED MANUALLY', 4, 'OLD/IGNORED', 5, 'LENIENT MATCHED ON VS') as Placement

, case when p.center is not null then p.center || 'p' || p.id else null end as PersonId, p.FULLNAME as PersonName
from HP.UNPLACED_PAYMENTS up
join HP.CLEARING_IN cli on cli.ID = up.XFR_DELIVERY
join HP.CLEARINGHOUSES ch on ch.ID = cli.CLEARINGHOUSE
left join HP.ACCOUNT_RECEIVABLES ar on ar.CENTER = up.ACCOUNT_CENTER and ar.id = up.ACCOUNT_ID
left join HP.PERSONS p on p.center = ar.CUSTOMERCENTER and p.id = ar.CUSTOMERID
where ch.id in (3003) and up.xfr_date >= :from_date and up.xfr_date < (:to_date + 1)
order by 1,4, cli.id, 3