SELECT
    s.CENTER || 'ss' || s.ID "MembershipDetailID",
    p.EXTERNAL_ID "PersonID",
    s.CENTER || 'ss' || s.ID "MembershipNumber",
    s.PRODUCT_GROUP_NAME "MembershipCategory",
    s.PRODUCT_GROUP_NAME "MembershipGroup",
    'Addon,normal, addons servoce?' "MembershipType",
    s.BINDING_PERIOD_IN_MONTH "MembershipDuration",
    s.EMPLOYEE_CENTER ||'emp' || s.EMPLOYEE_ID "SoldBy",
    'person join date? As in active?' "InitialJoinDate",
    '?' "ObligationDate",
    s.RENEWAL_TYPE "AutoRenewMembership",
    '?' "MemberPayment",
    '?' "CorporatePayment",
    '?' "DiscountAmount",
    longToDate(s.CREATION_TIME) "JoinDate",
    s.START_DATE "StartDate",
    s.END_DATE "CostingDate",
    '?' "ExpiryDate",
    'Link to exit quiz?' "TerminatedReason",
    s.CENTER || 'ss' || s.ID "SubscriptionReference",
    s.RENEWAL_TYPE "SubscriptionType",
    s.CENTER "SiteID",
    s.PRODUCT_ID "ProductID",
    p.PAYMENT_AGREE_CLEARING_HOUSE "PaymentMethod",
    s.STATE "SubscriptionStatus",
    DECODE(p.OTHER_PAYER_UNIQUE_KEY,NULL,0,1) "PrimaryPaysInd",
    'EXERP' "SourceSystem",
    'N/A' "ExtRef"
FROM
    JB.SUBSCRIPTIONS_VW s
JOIN PERSONS oldP
ON
    oldP.CENTER = s.CENTER
    AND oldP.ID = s.ID
JOIN JB.PERSONS_VW p
ON
    p.CENTER = oldP.CURRENT_PERSON_CENTER
    AND p.ID = oldP.CURRENT_PERSON_ID
JOIN STATE_CHANGE_LOG scl
ON
    scl.CENTER = oldP.CENTER
    AND scl.ID = oldP.ID
    AND scl.ENTRY_TYPE = 1
ORDER BY
    p.EXTERNAL_ID,
    scl.BOOK_START_TIME ASC
