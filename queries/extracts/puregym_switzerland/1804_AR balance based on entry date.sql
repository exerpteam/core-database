select distinct
CASE AR_TYPE WHEN 1 THEN 'Cash' WHEN 4 THEN 'Payment' WHEN 5 THEN 'Debt' WHEN 6 THEN 'installment' END AS AR_TYPE,
ar.customercenter ||'p'|| ar.customerid as memberid,
ext.txtvalue as OldmemberID,
ar.balance as "Balance today",
sum(art.amount) as "AR balance at cut date"


from  ACCOUNT_RECEIVABLES AR

join ar_trans art
on
art.center = ar.center
and
art.id = ar.id

left join person_ext_attrs ext
on
ext.personcenter = ar.customercenter
and ext.personid = ar.customerid
and ext.name = '_eClub_OldSystemPersonId'


where 
ar.center in (:scope)
--and ar.balance != 0
and art.entry_time <= (:cut_date)

group by
 AR_TYPE,
memberid,
ext.txtvalue,
ar.balance