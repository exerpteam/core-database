-- cutdate = longdate
-- from and to -date = date
SELECT
	c.EXTERNAL_ID						AS Cost,
    su.owner_center                    as Club, -- center scope
    c.name                             as ClubName,
    SU.OWNER_CENTER||'p'||SU.OWNER_ID  as SubscriptionOwnerKey,
	per.BIRTHDATE,
	TO_CHAR(trunc(months_between(TRUNC(exerpsysdate()), per.birthdate)/12)) AS Age,
    DECODE (per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS SubscriptionOwnerType,
	 DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') AS CurrentPersonStatus,
    pr.name                            as Subscription,
--    SP.PRICE,
   CASE
         WHEN st.st_type = 0 THEN ceil(( su.subscription_price /( ( su.end_date - su.start_date)-2) )*30) -- cash pr month
         WHEN st.st_type = 1 THEN su.subscription_price
    END   AS MonthlyPrice,  
    DECODE(st.ST_TYPE, 0, 'Cash', 1, 'EFT', 3, 'Prospect') as PaymentType,
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
    AND SCL2.BOOK_START_TIME < :CutDate + (1000 * 60 * 60 * 24)
    AND
        (
            SCL2.BOOK_END_TIME IS NULL
            OR SCL2.BOOK_END_TIME >= :CutDate + (1000 * 60 * 60 * 24)
        )
    )
LEFT JOIN SUBSCRIPTIONPERIODPARTS SPP
ON
    (
		SPP.CENTER = SU.CENTER
		AND SPP.ID = SU.ID
		AND SPP.FROM_DATE <= :from_date
		AND SPP.TO_DATE >= :to_date
		AND SPP.SPP_STATE = 1
		AND SPP.ENTRY_TIME < :CutDate + (1000 * 60 * 60 * 24)
    )
LEFT JOIN SUBSCRIPTION_PRICE SP
ON
    (
    SP.SUBSCRIPTION_CENTER = SU.CENTER
    AND SP.SUBSCRIPTION_ID = SU.ID
    AND SP.FROM_DATE <= :from_date
    AND
        (
         SP.TO_DATE IS NULL
         OR SP.TO_DATE >= :to_date
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


left join PAYMENT_REQUESTS pr
on
	ar.center = pr.center
	and ar.id = pr.id



WHERE
    (
        SU.CENTER IN (:scope)
    AND SCL1.ENTRY_TYPE = 2
    AND SCL1.STATEID IN (2, 4)
    AND SCL1.BOOK_START_TIME < :CutDate + (1000 * 60 * 60 * 24)
    AND
        (
            SCL1.BOOK_END_TIME IS NULL
            OR SCL1.BOOK_END_TIME >= :CutDate + (1000 * 60 * 60 * 24)
        )
    AND SCL1.ENTRY_START_TIME < :CutDate + (1000 * 60 * 60 * 24)
    AND SCL2.STATEID IN (1, 9, 3, 8, 6, 7, 5, 0, 4)
    AND SU.START_DATE >= :from_date --StartDateFrom
    AND SU.START_DATE <= :to_date --StartDateTo
    )

group by
	c.EXTERNAL_ID,
    su.owner_center,
    SU.OWNER_CENTER||'p'||SU.OWNER_ID,
	per.BIRTHDATE,
	TO_CHAR(trunc(months_between(TRUNC(exerpsysdate()), per.birthdate)/12)),
    c.name,
    per.PERSONTYPE,
	per.STATUS,
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


