-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.CENTER,
    mpr.CACHED_PRODUCTNAME       AS "Add On name",
    longtodate(sa.CREATION_TIME) AS "Add On  creation time",
    sa.START_DATE                AS "Add On  start date",
    sa.END_DATE                  AS "Add On  end date",
    sa.INDIVIDUAL_PRICE_PER_UNIT AS "Add On  individual price",
    pr2.PRICE                    AS "add on normal price",
    p.id,
    p.FULLNAME,
	P.ssn,
	P.ADDRESS1,
    email.TXTVALUE as email,
    p.center AS "center ID",
    pr.NAME  AS "subscription",
    s.SUBSCRIPTION_PRICE,
	longtodate(s.CREATION_TIME) AS "sub creation time"

FROM
    SUBSCRIPTION_ADDON sa
JOIN
    SUBSCRIPTIONS s
ON
    sa.SUBSCRIPTION_CENTER = s.CENTER
    AND sa.SUBSCRIPTION_ID = s.id
LEFT JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = sa.ADDON_PRODUCT_ID
LEFT JOIN
    PRODUCTS pr2
ON
    pr2.GLOBALID = mpr.GLOBALID
    AND pr2.CENTER = s.CENTER
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
    LEFT JOIN
            PERSON_EXT_ATTRS email
        ON
            p.center=email.PERSONCENTER
            AND p.id=email.PERSONID
            AND email.name='_eClub_Email'
WHERE
    sa.START_DATE <= TRUNC(current_timestamp)
    AND (
        sa.END_DATE > TRUNC(current_timestamp)
        OR sa.END_DATE IS NULL)
        and sa.CANCELLED = 0
    AND s.CENTER IN (189,200,184)
	AND mpr.CACHED_PRODUCTNAME IN ('Addon Eskilstuna bad')

ORDER BY
	sa.START_DATE
