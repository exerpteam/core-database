-- This is the version from 2026-02-05
--  
select 
p.center || 'p' || p.id MemberNo,
sub.center || 'ss' || sub.id SubscriptionId,
pd.NAME as MembershipType,
sub.START_DATE as StartDate,
sub.END_DATE as EndDate,
case when (sub.STATE in (2,4,8) and (sub.end_date is null or sub.end_date >= to_date(to_char(trunc(exerpsysdate()), 'YYYY-MM-DD'), 'YYYY-MM-DD'))) then 'Y' else 'N' end as Active,
sub.SUBSCRIPTION_PRICE as Price,
decode(st.ST_TYPE, 0, 'KONTANT', 1, 'PBS') as PaymentType,
pg.NAME as ProductGroup,
case when (ces.LASTUPDATED is not null and ces.LASTUPDATED >= longtodate(sub.CREATION_TIME)) then 'YES' else 'NO' end as Imported
,ivl.TOTAL_AMOUNT as JoiningFee
--sp.FROM_DATE AS PriceChange,
--exerpro.longtodate(scl.BOOK_START_TIME) AS StateChange,
--exerpro.longtodate(sc.CHANGE_TIME) as EndDateChange
from persons p 
JOIN SUBSCRIPTIONS sub 
        ON p.center = sub.OWNER_CENTER AND p.id = sub.OWNER_ID
JOIN SUBSCRIPTIONTYPES st 
        ON st.center = sub.SUBSCRIPTIONTYPE_CENTER AND st.id = sub.SUBSCRIPTIONTYPE_ID
JOIN PRODUCTS pd 
        ON pd.center = st.center AND pd.id = st.id
JOIN PRODUCT_GROUP pg 
        ON pd.PRIMARY_PRODUCT_GROUP_ID = pg.ID
LEFT JOIN INVOICELINES ivl 
        ON ivl.CENTER = sub.INVOICELINE_CENTER AND ivl.id = sub.INVOICELINE_ID AND ivl.subid = sub.INVOICELINE_SUBID
LEFT JOIN CONVERTER_ENTITY_STATE ces 
        ON ces.NEWENTITYCENTER = p.center AND ces.NEWENTITYID = p.id AND ces.WRITERNAME = 'ClubLeadSubscriptionWriter'
-- Price Change
LEFT JOIN SUBSCRIPTION_PRICE sp 
        ON sub.CENTER = sp.SUBSCRIPTION_CENTER  AND sub.ID = sp.SUBSCRIPTION_ID AND sp.FROM_DATE < to_date(to_char(trunc(exerpsysdate()), 'YYYY-MM-DD'), 'YYYY-MM-DD') 
                AND (sp.TO_DATE >= to_date(to_char(trunc(exerpsysdate()), 'YYYY-MM-DD'), 'YYYY-MM-DD') OR sp.TO_DATE IS NULL) AND sp.CANCELLED=0
-- State Change
LEFT JOIN STATE_CHANGE_LOG scl
        ON scl.CENTER = sub.CENTER AND scl.ID = sub.ID AND scl.ENTRY_TYPE = 2 and scl.BOOK_START_TIME < exerpro.datetolong(to_char(trunc(exerpsysdate()),'YYYY-MM-DD HH24:MI'))
                AND (scl.BOOK_END_TIME >= exerpro.datetolong(to_char(trunc(exerpsysdate()),'YYYY-MM-DD HH24:MI')) OR scl.BOOK_END_TIME IS NULL)
-- EndDate Change
LEFT JOIN SUBSCRIPTION_CHANGE sc
        ON nvl(sc.NEW_SUBSCRIPTION_CENTER,sc.OLD_SUBSCRIPTION_CENTER)=sub.CENTER AND nvl(sc.NEW_SUBSCRIPTION_ID,sc.OLD_SUBSCRIPTION_ID)=sub.ID 
                AND sc.TYPE='END_DATE' AND sc.CANCEL_TIME IS NULL
       
WHERE 
        p.status IN (0,1,2,3,4,6,9)  
        AND p.sex != 'C' 
        AND p.center NOT IN (100)
        AND p.center IN (:scope) 
        AND ((trunc(exerpsysdate()-4) <= sp.FROM_DATE) 
                OR (trunc(exerpsysdate()-4) <= exerpro.longtodate(scl.BOOK_START_TIME)) 
                        OR (trunc(exerpsysdate()-4) <= exerpro.longtodate(sc.CHANGE_TIME)))
ORDER BY 1, 3