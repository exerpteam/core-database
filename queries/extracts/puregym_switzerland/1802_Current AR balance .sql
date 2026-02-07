select 
CASE AR_TYPE WHEN 1 THEN 'Cash' WHEN 4 THEN 'Payment' WHEN 5 THEN 'Debt' WHEN 6 THEN 'installment' END AS AR_TYPE,
ar.customercenter ||'p'|| ar.customerid as memberid,
ext.txtvalue as OldmemberID,
ar.balance



from  ACCOUNT_RECEIVABLES AR

left join person_ext_attrs ext
on
ext.personcenter = ar.customercenter
and ext.personid = ar.customerid
and ext.name = '_eClub_OldSystemPersonId'


where 
ar.center in (:scope)