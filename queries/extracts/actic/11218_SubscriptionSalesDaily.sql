-- The extract is extracted from Exerp on 2026-02-08
--  
-- CutDate = LongDate, time/date in ms
-- to_date & from_date = Date, ex. 2013-04-05

SELECT
    su.owner_center                    as Club, -- center scope
    SU.OWNER_CENTER||'p'||SU.OWNER_ID  as SubscriptionOwnerKey,
	CAST(EXTRACT('year' FROM age(per.birthdate)) AS VARCHAR) AS Age,
    c.name                             as ClubName,
    CASE  per.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS SubscriptionOwnerType,
    pr.name                            as Subscription,
--    SP.PRICE,
   CASE
         WHEN st.st_type = 0 THEN ceil(( su.subscription_price /( ( su.end_date - su.start_date)-2) )*30) -- cash pr month
         WHEN st.st_type = 1 THEN su.subscription_price
    END   AS MonthlyPrice,  
    CASE st.ST_TYPE  WHEN 0 THEN  'Cash'  WHEN 1 THEN  'EFT'  WHEN 3 THEN  'Prospect' END as PaymentType,
    SU.START_DATE                      as StartDate,
    COMPANY.LASTNAME                   AS COMPANY_NAME,
    CA.NAME                            AS CA_COMPANY_AGREEMENT_NAME,
	PR.GLOBALID						   AS GLOBAL_ID
FROM
    SUBSCRIPTIONS SU
INNER JOIN SUBSCRIPTIONTYPES ST
ON
    (
        SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
    AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
    )
INNER JOIN PRODUCTS PR
ON
    (
        ST.CENTER = PR.CENTER
    AND ST.ID = PR.ID
    )
INNER JOIN STATE_CHANGE_LOG SCL1
ON
    (
        SCL1.CENTER = SU.CENTER
    AND SCL1.ID = SU.ID
    AND SCL1.ENTRY_TYPE = 2
    )
LEFT JOIN STATE_CHANGE_LOG SCL2
ON
    (
        SU.OWNER_CENTER = SCL2.CENTER
    AND SU.OWNER_ID = SCL2.ID
    AND SCL2.ENTRY_TYPE = 3
--    AND SCL2.BOOK_START_TIME < CutDate + (1000 * 60 * 60 * 24) -- BOOK_START_TIME ex. 1372986662558. 86400000ms for 1 day
    AND SCL2.BOOK_START_TIME < datetolong(TO_CHAR(TRUNC(current_timestamp), 'YYYY-MM-DD HH24:MI'))
    AND
        (
            SCL2.BOOK_END_TIME IS NULL
--            OR SCL2.BOOK_END_TIME >= CutDate + (1000 * 60 * 60 * 24)
            OR SCL2.BOOK_END_TIME >= datetolong(TO_CHAR(TRUNC(current_timestamp), 'YYYY-MM-DD HH24:MI'))
        )
    )
LEFT JOIN SUBSCRIPTIONPERIODPARTS SPP
ON
    (
        SPP.CENTER = SU.CENTER
    AND SPP.ID = SU.ID
--    AND SPP.FROM_DATE <= from_date
--    AND SPP.TO_DATE >= to_date
    AND SPP.FROM_DATE <= TRUNC(current_timestamp -1)
    AND SPP.TO_DATE >= TRUNC(current_timestamp -1)
    AND SPP.SPP_STATE = 1
--    AND SPP.ENTRY_TIME < CutDate + (1000 * 60 * 60 * 24)
    AND SPP.ENTRY_TIME < datetolong(TO_CHAR(TRUNC(current_timestamp), 'YYYY-MM-DD HH24:MI'))
    )
LEFT JOIN SUBSCRIPTION_PRICE SP
ON
    (
        SP.SUBSCRIPTION_CENTER = SU.CENTER
    AND SP.SUBSCRIPTION_ID = SU.ID
--    AND SP.FROM_DATE <= from_date
    AND SP.FROM_DATE <= TRUNC(current_timestamp -1)
    AND
        (
            SP.TO_DATE IS NULL
--         OR SP.TO_DATE >= to_date
         OR SP.TO_DATE >= TRUNC(current_timestamp -1)
        )
    )
LEFT JOIN RELATIVES companyAgrRel
ON
        su.owner_center = companyAgrRel.CENTER
    AND su.owner_id = companyAgrRel.ID
    AND companyAgrRel.RTYPE = 3
    AND companyAgrRel.STATUS = 1
LEFT JOIN COMPANYAGREEMENTS ca
ON
        ca.CENTER = companyAgrRel.RELATIVECENTER
    AND ca.ID = companyAgrRel.RELATIVEID
    AND ca.SUBID = companyAgrRel.RELATIVESUBID
LEFT JOIN PERSONS company
ON
        company.CENTER = ca.CENTER
    AND company.ID = ca.id
    AND company.sex = 'C'
LEFT JOIN product_group PG
ON
    PR.primary_product_group_id = PG.id
left join centers c
on
    su.owner_center = c.id
join persons per
on
        su.owner_center = per.center
    and su.owner_id = per.id


left join ACCOUNT_RECEIVABLES ar
on
        per.center = ar.CUSTOMERCENTER 
    and per.id = ar.customerid


left join PAYMENT_REQUESTS prq
on
        ar.center = prq.center
    and ar.id = prq.id



WHERE
    (
        SU.CENTER IN (:scope)
    AND SCL1.ENTRY_TYPE = 2
    AND SCL1.STATEID IN (2, 4)
--    AND SCL1.BOOK_START_TIME < CutDate + (1000 * 60 * 60 * 24)
    AND SCL1.BOOK_START_TIME < datetolong(TO_CHAR(TRUNC(current_timestamp), 'YYYY-MM-DD HH24:MI'))
    AND
        (
            SCL1.BOOK_END_TIME IS NULL
--            OR SCL1.BOOK_END_TIME >= CutDate + (1000 * 60 * 60 * 24)
            OR SCL1.BOOK_END_TIME >= datetolong(TO_CHAR(TRUNC(current_timestamp), 'YYYY-MM-DD HH24:MI'))
        )
--    AND SCL1.ENTRY_START_TIME < CutDate + (1000 * 60 * 60 * 24)
    AND SCL1.ENTRY_START_TIME < datetolong(TO_CHAR(TRUNC(current_timestamp), 'YYYY-MM-DD HH24:MI'))
    AND SCL2.STATEID IN (1, 9, 3, 8, 6, 7, 5, 0, 4)
--    AND SU.START_DATE >= from_date --StartDateFrom
--    AND SU.START_DATE <= to_date --StartDateTo
    AND SU.START_DATE = TRUNC(current_timestamp -1)
    )

group by

    su.owner_center,
    SU.OWNER_CENTER||'p'||SU.OWNER_ID,
	CAST(EXTRACT('year' FROM age(per.birthdate)) AS VARCHAR),
    c.name,
    per.PERSONTYPE,
    pr.name,
    CASE
         WHEN st.st_type = 0 THEN ceil(( su.subscription_price /( ( su.end_date - su.start_date)-2) )*30) -- cash pr month
         WHEN st.st_type = 1 THEN su.subscription_price
    END,
    st.ST_TYPE,
    SU.START_DATE,
    COMPANY.LASTNAME,
    CA.NAME,
	PR.GLOBALID
