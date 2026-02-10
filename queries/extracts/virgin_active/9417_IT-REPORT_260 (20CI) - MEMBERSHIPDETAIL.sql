-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct 
    i1."MembershipDetailID",
    i1."PersonID",
    i1."MembershipNumber",
    i1."MembershipCategory",
    i1."MembershipGroup",
    i1."MembershipType",
    i1."MembershipDuration",
    i1."SoldBy",
longToDate(FIRST_VALUE(scl.BOOK_START_TIME) IGNORE NULLS  OVER (PARTITION BY i1."MembershipNumber" ORDER BY scl.BOOK_START_TIME asc)) "InitialJoinDate",
FIRST_VALUE(i1."ObligationDate") IGNORE NULLS  OVER (PARTITION BY i1."MembershipNumber" ORDER BY scl.BOOK_START_TIME asc) "ObligationDate",
    i1."AutoRenewMembership",
    i1."JoinDate",
    i1."StartDate",
    i1."CostingDate",
    i1."ExpiryDate",
    i1."SubscriptionReference",
    i1."SubscriptionType",
    i1."SiteID",
    i1."ProductID",
    i1."PaymentMethod",
    i1."SubscriptionStatus",
    i1."PrimaryPaysInd"
FROM
    (
        SELECT
            p.CURRENT_CENTER,
            p.CURRENT_ID,
            s.CENTER || 'ss' || s.ID "MembershipDetailID",
            p.EXTERNAL_ID "PersonID",
            s.CENTER || 'ss' || s.ID "MembershipNumber",
            s.PRODUCT_GROUP_NAME "MembershipCategory",
            s.PRODUCT_GROUP_NAME "MembershipGroup",
            DECODE(st.ST_TYPE, 0, 'FIXED_LENGTH', 1, 'RECURRING', 'UNDEFINED') "MembershipType",
            st.BINDINGPERIODCOUNT "MembershipDuration",
            s.EMPLOYEE_CENTER ||'emp' || s.EMPLOYEE_ID "SoldBy",
            NULL "InitialJoinDate",
            s.BINDING_END_DATE "ObligationDate",
            s.RENEWAL_TYPE "AutoRenewMembership",
            longToDate(s.CREATION_TIME) "JoinDate",
            s.START_DATE "StartDate",
            s.END_DATE "CostingDate",
            s.END_DATE "ExpiryDate",
            s.CENTER || 'ss' || s.ID "SubscriptionReference",
            DECODE(st.ST_TYPE,0,'FIXED',1,'RECURRING','UNDEFINED') "SubscriptionType",
            s.CENTER "SiteID",
            prod.CENTER || 'prod' || prod.ID "ProductID",
            ch.NAME "PaymentMethod",
            s.STATE "SubscriptionStatus",
            DECODE(p.OTHER_PAYER_UNIQUE_KEY,NULL,0,1) "PrimaryPaysInd"
        FROM
            SUBSCRIPTIONS_VW s
        JOIN SUBSCRIPTIONTYPES st
        ON
            st.CENTER = s.SUBSCRIPTION_TYPE_CENTER
            AND st.ID = s.SUBSCRIPTION_TYPE_ID
        JOIN PRODUCTS prod
        ON
            prod.CENTER = st.CENTER
            AND prod.ID = st.ID
        JOIN PERSONS oldP
        ON
            oldP.CENTER = s.PERSON_CENTER
            AND oldP.ID = s.PERSON_ID
        JOIN PERSONS_VW p
        ON
            p.CENTER = oldP.CURRENT_PERSON_CENTER
            AND p.ID = oldP.CURRENT_PERSON_ID
        JOIN STATE_CHANGE_LOG scl
        ON
            scl.CENTER = oldP.CENTER
            AND scl.ID = oldP.ID
            AND scl.ENTRY_TYPE = 1
        LEFT JOIN ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = p.CENTER
            AND ar.CUSTOMERID = p.ID
            AND ar.AR_TYPE = 4
        LEFT JOIN PAYMENT_ACCOUNTS pac
        ON
            pac.CENTER = ar.CENTER
            AND pac.ID = ar.ID
        LEFT JOIN PAYMENT_AGREEMENTS pagr
        ON
            pagr.CENTER = pac.ACTIVE_AGR_CENTER
            AND pagr.ID = pac.ACTIVE_AGR_ID
            AND pagr.SUBID = pac.ACTIVE_AGR_SUBID
        LEFT JOIN CLEARINGHOUSES ch
        ON
            ch.ID = pagr.CLEARINGHOUSE

    )
    i1
JOIN PERSONS allP
ON
    allP.CURRENT_PERSON_CENTER = i1.CURRENT_CENTER
    AND allP.CURRENT_PERSON_ID = i1.CURRENT_ID
LEFT JOIN STATE_CHANGE_LOG scl
ON
    scl.CENTER = allP.CENTER
    AND scl.ID = allP.ID
    AND scl.ENTRY_TYPE = 1
    AND scl.STATEID = 1
	where allP.center IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT')
/*
GROUP BY
	scl.center,
    i1."MembershipDetailID",
    i1."PersonID",
    i1."MembershipNumber",
    i1."MembershipCategory",
    i1."MembershipGroup",
    i1."MembershipType",
    i1."MembershipDuration",
    i1."SoldBy",
    i1."ObligationDate",
    i1."AutoRenewMembership",
    i1."JoinDate",
    i1."StartDate",
    i1."CostingDate",
    i1."ExpiryDate",
    i1."SubscriptionReference",
    i1."SubscriptionType",
    i1."SiteID",
    i1."ProductID",
    i1."PaymentMethod",
    i1."SubscriptionStatus",
    i1."PrimaryPaysInd"
*/