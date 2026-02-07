SELECT
	sa.id sa_id,
    p.CENTER || 'p' || p.ID                                                                                                                                                            pid,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS PERSON_STATUS,
    p.FULLNAME,
    email.TXTVALUE                                                                            email,
    prod.NAME                                                                                 SUB_NAME,
    DECODE(st.ST_TYPE, 0, 'Cash', 1, 'EFT', 3, 'Prospect') as SUB_TYPE,
    DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS SUB_STATE,
    s.CENTER || 'ss' || s.ID                                                                  sid,
	s.billed_until_date,
    mpr.CACHED_PRODUCTNAME                                                                    ADDON_NAME,
    sa.START_DATE,
    sa.END_DATE
FROM
    SUBSCRIPTION_ADDON sa
JOIN
    SUBSCRIPTIONS s
ON
    s.CENTER = sa.SUBSCRIPTION_CENTER
    AND s.ID = sa.SUBSCRIPTION_ID
JOIN
    MASTERPRODUCTREGISTER mpr
ON
    mpr.ID = sa.ADDON_PRODUCT_ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
join SUBSCRIPTIONTYPES st on st.CENTER = s.SUBSCRIPTIONTYPE_CENTER and st.ID = s.SUBSCRIPTIONTYPE_ID    
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = p.CENTER
    AND email.PERSONID = p.ID
    AND email.NAME = '_eClub_Email'
WHERE
    mpr.CACHED_PRODUCTNAME in ( $$types$$)
    AND (
        sa.END_DATE IS  null
        OR sa.END_DATE > to_date('2015-10-31','YYYY-MM-DD'))
    AND sa.CANCELLED = 0
	and s.center in ($$scope$$)