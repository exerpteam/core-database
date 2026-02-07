
select p.center, p.id, p.FULLNAME, pag.ref, pag.BANK_ACCOUNT_HOLDER,
decode(sub.STATE, 2, 'ACTIVE', 4, 'FROZEN', 8, 'CREATED') as SubscriptionState,
DECODE(pag.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') as DDIState,
acl.TEXT as ReasonCode, acl.LOG_DATE,
sub.start_date, sub.BILLED_UNTIL_DATE, sub.END_DATE, longtodate(pag.CREATION_TIME) as DDI_CREATED, ar.balance, ccc.STARTDATE as DEBT_START, ccc.AMOUNT as DEBT_AMOUNT


from 
persons p
left join PUREGYM.SUBSCRIPTIONS sub on sub.OWNER_CENTER = p.center and sub.OWNER_ID = p.id and sub.state in (2,4,8)
join PUREGYM.PRODUCTS prod on prod.CENTER = sub.SUBSCRIPTIONTYPE_CENTER and prod.ID = sub.SUBSCRIPTIONTYPE_ID
left join PUREGYM.SUBSCRIPTIONTYPES st on st.center = sub.SUBSCRIPTIONTYPE_CENTER and st.id = sub.SUBSCRIPTIONTYPE_ID and st.ST_TYPE = 1
join PUREGYM.ACCOUNT_RECEIVABLES ar on ar.CUSTOMERCENTER = p.center and ar.CUSTOMERID = p.id
join PUREGYM.PAYMENT_ACCOUNTS pa on pa.CENTER = ar.CENTER and pa.id = ar.id
join PUREGYM.PAYMENT_AGREEMENTS pag on pag.center = pa.ACTIVE_AGR_CENTER and pag.id = pa.ACTIVE_AGR_ID and pag.subid = pa.ACTIVE_AGR_SUBID
left join PUREGYM.CASHCOLLECTIONCASES mac on mac.PERSONCENTER = p.center and mac.PERSONID = p.id and mac.CLOSED = 0 and mac.MISSINGPAYMENT = 0
left join PUREGYM.CASHCOLLECTIONCASES ccc on ccc.PERSONCENTER = p.center and ccc.PERSONID = p.id and ccc.CLOSED = 0 and ccc.MISSINGPAYMENT = 1

join (
    select acl2.AGREEMENT_CENTER, acl2.AGREEMENT_id, acl2.AGREEMENT_SUBID, acl2.state, max(acl2.id) as Id
    from PUREGYM.AGREEMENT_CHANGE_LOG acl2 where (acl2.text is null or acl2.text not like 'Deduction day%')
    group by acl2.AGREEMENT_center, acl2.AGREEMENT_id, acl2.AGREEMENT_SUBID, acl2.state
) acl3 on acl3.AGREEMENT_center = pag.center and acl3.AGREEMENT_id = pag.id and acl3.AGREEMENT_subid = pag.subid and acl3.state = pag.STATE
left join PUREGYM.AGREEMENT_CHANGE_LOG acl on acl.ID = acl3.id

where 
p.sex != 'C'
and p.persontype = 2
and prod.GLOBALID in ('PT_RENT_1000', 'PT_RENT_400', 'PT_RENT_500', 'PT_RENT_600', 'PT_RENT_700', 'PT_RENT_800')
and (pag.STATE not in (1,2,4,15)
and acl.text in ('Cancelled by payer', 'Instruction cancelled', 'Cancelled, Refer to payer', 'No account','No instruction','Payer deceased','Account closed', 'Instruction cancelled by payer') or p.status not in (1,3,9) or (pag.state in (6) and acl.TEXT is null))
and (sub.center is null or st.center is not null)

--stop now
and (ccc.center is not null and ar.balance < 0)

and not exists(
        -- we exclude those who have a pending request at BACS
        select 1 from payment_requests pr3 where pr3.REQUEST_TYPE in (1,6) and pr3.center = pag.center and pr3.id = pag.id and pr3.STATE in (1,2)
)

and pag.center in (:scope)
and pag.center not in (147, 141, 149, 123) 

union all

-- 2. Members with last DD rep "Refer to payer"
select p.center, p.id, p.FULLNAME, pag.ref, pag.BANK_ACCOUNT_HOLDER,
decode(sub.STATE, 2, 'ACTIVE', 4, 'FROZEN', 8, 'CREATED') as SubscriptionState,
DECODE(pag.STATE,1,'Created',2,'Sent',3,'Failed',4,'OK',5,'Ended, bank',6,'Ended, clearing house',7,'Ended, debtor',8,'Cancelled, not sent',9,'Cancelled, sent',10,'Ended, creditor',11,'No agreement (deprecated)',12,'Cash payment (deprecated)',13,'Agreement not needed (invoice payment)',14,'Agreement information incomplete') as DDIState,
pr.xfr_info as ReasonCode
, pr.xfr_date as LOG_DATE,
sub.start_date, sub.BILLED_UNTIL_DATE, sub.END_DATE, longtodate(pag.CREATION_TIME) as DDI_CREATED, ar.balance, ccc.STARTDATE as DEBT_START, ccc.AMOUNT as DEBT_AMOUNT
from 
persons p
left join PUREGYM.SUBSCRIPTIONS sub on sub.OWNER_CENTER = p.center and sub.OWNER_ID = p.id and sub.state in (2,4,8)
join PUREGYM.PRODUCTS prod on prod.CENTER = sub.SUBSCRIPTIONTYPE_CENTER and prod.ID = sub.SUBSCRIPTIONTYPE_ID
join PUREGYM.ACCOUNT_RECEIVABLES ar on ar.CUSTOMERCENTER = p.center and ar.CUSTOMERID = p.id
join PUREGYM.PAYMENT_ACCOUNTS pa on pa.CENTER = ar.CENTER and pa.id = ar.id
join PUREGYM.PAYMENT_AGREEMENTS pag on pag.center = pa.ACTIVE_AGR_CENTER and pag.id = pa.ACTIVE_AGR_ID and pag.subid = pa.ACTIVE_AGR_SUBID
join PUREGYM.CASHCOLLECTIONCASES ccc on ccc.PERSONCENTER = p.center and ccc.PERSONID = p.id and ccc.CLOSED = 0 and ccc.MISSINGPAYMENT = 1

-- find latest prs and its representation
join (
        select prs2.center, prs2.id, max(prs2.subid) as subid from PUREGYM.PAYMENT_REQUEST_SPECIFICATIONS prs2 
        where prs2.cancelled = 0 and prs2.ENTRY_TIME > datetolong(to_char(sysdate - 31, 'YYYY-MM-DD HH24:MI')) group by prs2.center, prs2.id
) latest_prs on latest_prs.center = pag.center and latest_prs.id = pag.id 

join PUREGYM.PAYMENT_REQUESTS pr on pr.INV_COLL_CENTER = latest_prs.center and pr.INV_COLL_ID = latest_prs.id and pr.INV_COLL_SUBID = latest_prs.subid and pr.REQUEST_TYPE = 6 and pr.state not in (1,2,8) and pr.XFR_INFO in ('Refer to payer') 

and not exists(
        -- we exclude those who have a pending request at BACS
        select 1 from payment_requests pr3 where pr3.REQUEST_TYPE in (1,6) and pr3.center = pag.center and pr3.id = pag.id and pr3.STATE in (1,2)
)

where
ccc.CENTER is not null
and pag.STATE = 4
and prod.GLOBALID in ('PT_RENT_1000', 'PT_RENT_400', 'PT_RENT_500', 'PT_RENT_600', 'PT_RENT_700', 'PT_RENT_800')
and ar.balance < 0
and p.sex != 'C'
and p.persontype = 2
and pag.center in (:scope)
and pag.center not in (147, 141, 149, 123) 