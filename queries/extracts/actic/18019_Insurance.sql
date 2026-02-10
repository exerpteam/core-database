-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.FULLNAME,
    p.ssn,
    p.center AS "center ID",
    pr.NAME  AS "subscription",
	p.center || 'p' || p.id PID,
    longtodate(sa.CREATION_TIME) AS "addon creation time",
    sa.START_DATE                AS "addon start date",
    sa.END_DATE                  AS "addon end date",
    mpr.CACHED_PRODUCTNAME       AS "add on name",
    sa.INDIVIDUAL_PRICE_PER_UNIT AS "add on individual price",
    pr2.PRICE                    AS "add on normal price",
	TO_CHAR(TRUNC(exerpsysdate()), 'YYYY-MM-DD') todays_date
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
    sa.START_DATE <= TRUNC(exerpsysdate())
    AND (
        sa.END_DATE > = TRUNC(exerpsysdate())

	



 
        OR sa.END_DATE IS NULL)
        and sa.CANCELLED = 0
    AND s.CENTER IN ($$scope$$)
	 AND mpr.CACHED_PRODUCTNAME LIKE 'Olycksfallsförsäkring (Löpande)'