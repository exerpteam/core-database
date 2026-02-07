SELECT DISTINCT
    SS.CENTER,
    SS.ID,
    SS.OWNER_CENTER || 'p' || SS.OWNER_ID personid,
    SS.SUBSCRIPTION_PRICE,
    SS.BINDING_PRICE,
    SS.BINDING_END_DATE,
    SS.START_DATE,
    longtodate(SS.CREATION_TIME) creationTime,
    per.PERSONTYPE
    /* All subscription for which a SubscriptionPeriodPart has been bought with the privileges */
FROM
    subscriptionperiodparts SPP
JOIN subscriptions SS
    ON
    SS.CENTER = SPP.CENTER
    AND SS.ID = SPP.ID
JOIN PERSONS per
    ON
    per.center = SS.OWNER_CENTER
    AND per.id = SS.OWNER_ID
WHERE
    per.PERSONTYPE in (:persontype)
	AND SPP.CENTER in (:scope)
    AND SS.SUBSCRIPTION_PRICE >= :PriceFrom
    AND SS.SUBSCRIPTION_PRICE <= :PriceTo
    and (
        SPP.invoiceline_center, SPP.invoiceline_id, SPP.invoiceline_subid
    )
    IN
    (
        SELECT
            PU.TARGET_CENTER,
            PU.TARGET_ID,
            PU.TARGET_SUBID
            /* The target is the object the privilege has been applied to. Here an invoice line */
        FROM
            PRIVILEGE_USAGES PU
            /* Select PrivilegeUsages not cancelled, used for invoice lines coming from a campaign */
        WHERE
            PU.PRIVILEGE_TYPE = 'PRODUCT' and PU.TARGET_SERVICE = 'InvoiceLine'
            AND PU.STATE <> 'CANCELLED'
            AND PU.SOURCE_ID in
            (
                SELECT
                    ID
                    /* Select the PrivilegeReceiverGroup Id from the name of the campaign */
                FROM
                    PRIVILEGE_RECEIVER_GROUPS
                WHERE
                    name = :campaign
            )

    )
ORDER by SS.CENTER, SS.subscription_price desc