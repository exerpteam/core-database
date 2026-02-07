SELECT DISTINCT
    COUNT(*),
    CASE
        WHEN
            /* If the subscription start date is before the transfer of the member */
            s.START_DATE < ces.LASTUPDATED
            /* Use the date of the transfer instead of the start date of the subscription */
            AND remainder(floor(months_between(:sys_date,ces.LASTUPDATED)),6) = 0
            /* Make sure the subsription is transferred by checking the sub_comment tha is null else */
            AND s.SUB_COMMENT IS NOT NULL
            /* Also check that the person has an entry of type old system id */
            AND pea.TXTVALUE IS NOT NULL
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS "IMPORTED FROM SATS",
    TO_CHAR(s.START_DATE,'YYYY-MM-DD') start_date,
    TO_CHAR(s.END_DATE,'YYYY-MM-DD') end_date
FROM
    SUBSCRIPTIONS s
JOIN SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = s.SUBSCRIPTIONTYPE_ID
JOIN PRODUCTS pr
ON
    pr.CENTER = st.CENTER
    AND pr.ID = st.ID
JOIN PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
LEFT JOIN CONVERTER_ENTITY_STATE ces
ON
    ces.NEWENTITYCENTER = s.center
    AND ces.NEWENTITYID = s.id
    AND ces.WRITERNAME = 'ClubLeadSubscriptionWriter'
LEFT JOIN PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = p.CENTER
    AND pea.PERSONID = p.ID
    AND pea.NAME = '_eClub_OldSystemPersonId'
WHERE
    /* Remove the ones created in the same month */
    floor(months_between(:sys_date,s.START_DATE)) != 0
	and s.sub_state not in (8)
    AND
    (
        /* then ones having an unbroken 6 month interval that has not been transferred */
        (
            remainder(floor(months_between(:sys_date,s.START_DATE)),6) = 0
            /* the comment won't be null if converted membership */
            AND s.SUB_COMMENT IS NULL
        )
        /* Deals with the ones imported from SATS with a subscription start date before the import */
        OR
        (
            /* If the subscription start date is before the transfer of the member */
            s.START_DATE < ces.LASTUPDATED
            /* Use the date of the transfer instead of the start date of the subscription */
            AND remainder(floor(months_between(:sys_date,ces.LASTUPDATED)),6) = 0
            /* Make sure the subsription is transferred by checking the sub_comment tha is null else */
            AND s.SUB_COMMENT IS NOT NULL
            /* Also check that the person has an entry of type old system id */
            AND pea.TXTVALUE IS NOT NULL
        )
    )
    AND
    (
        s.END_DATE IS NULL
        OR s.END_DATE >= last_day(:sys_date)
    )
    AND st.ST_TYPE = 1
    and s.CENTER in (:scope)
    AND pr.GLOBALID NOT IN ('EFT_BLACK_LABEL_GUEST')
    AND p.PERSONTYPE NOT IN (2)
GROUP BY
    CASE
        WHEN
            /* If the subscription start date is before the transfer of the member */
            s.START_DATE < ces.LASTUPDATED
            /* Use the date of the transfer instead of the start date of the subscription */
            AND remainder(floor(months_between(:sys_date,ces.LASTUPDATED)),6) = 0
            /* Make sure the subsription is transferred by checking the sub_comment tha is null else */
            AND s.SUB_COMMENT IS NOT NULL
            /* Also check that the person has an entry of type old system id */
            AND pea.TXTVALUE IS NOT NULL
        THEN 'TRUE'
        ELSE 'FALSE'
    END ,
    TO_CHAR(s.START_DATE,'YYYY-MM-DD') ,
    TO_CHAR(s.END_DATE,'YYYY-MM-DD')