SELECT
    p.CENTER,
    p.id,
    p.FULLNAME,
    email.TXTVALUE as email,
    p.center AS "center ID",
    pr.NAME  AS "subscription",
    s.SUBSCRIPTION_PRICE,
	longtodate(s.CREATION_TIME) AS "sub creation time",
    longtodate(sa.CREATION_TIME) AS "addon creation time",
    sa.START_DATE                AS "addon start date",
    sa.END_DATE                  AS "addon end date",
    mpr.CACHED_PRODUCTNAME       AS "add on name",
    sa.INDIVIDUAL_PRICE_PER_UNIT AS "add on individual price",
    pr2.PRICE                    AS "add on normal price"
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
   
         sa.END_DATE IS NULL
        and sa.CANCELLED = 0
		AND mpr.CACHED_PRODUCTNAME = 'ViktVäktarna Online 12 månader (löpande)'

AND sa.START_DATE >= :Start_Date_From 
AND sa.START_DATE <= :Start_Date_To

    AND s.CENTER IN ($$scope$$)