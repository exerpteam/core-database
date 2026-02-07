SELECT
    p.CENTER || 'p' || p.ID              pid,
    sa.ID                                addon_id,
    exerpro.longToDate(je.CREATION_TIME) message_sent,
    mpr.CACHED_PRODUCTNAME               addon_name
FROM
    JOURNALENTRIES je
JOIN
    PERSONS p
ON
    p.CENTER = je.PERSON_CENTER
    AND p.ID= je.PERSON_ID
LEFT JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
LEFT JOIN
    SUBSCRIPTION_ADDON sa
ON
    sa.SUBSCRIPTION_CENTER = s.CENTER
    AND sa.SUBSCRIPTION_ID = s.ID
LEFT JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = sa.ADDON_PRODUCT_ID
WHERE
    je.name = 'PT by DD Increase Letter Sent'
    AND sa.CREATION_TIME < je.CREATION_TIME
    AND (
        sa.END_DATE IS NULL
        OR sa.END_DATE > SYSDATE)
    AND sa.CANCELLED = 0