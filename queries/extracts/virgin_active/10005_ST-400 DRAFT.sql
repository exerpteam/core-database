SELECT
    --    p.CENTER,
    --    p.ID,
    --    s.CENTER SUB_CENTER,
    --    s.ID SUB_ID,
    c.ID                     CENTER_ID,
    c.NAME                   CLUB_NAME,
    s.START_DATE             MEMBER_START_DATE,
    s.CENTER || 'ss' || s.ID MEMBERSHIP_NUMBER,
    p.FULLNAME               MEMBER_NAME,
    prod.NAME                SUBSCRIPTION_NAME ,
    atts.TXTVALUE            MC
FROM
    SUBSCRIPTIONS s
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
JOIN
    CENTERS c
ON
    c.id = p.CENTER
    AND c.COUNTRY = 'GB'
JOIN
    PERSON_EXT_ATTRS atts
ON
    atts.PERSONCENTER = p.CENTER
    AND atts.PERSONID = p.ID
    AND atts.NAME = 'MC'
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
WHERE
    /* Get all subsciptions that has been created within X days from midnight today */
    s.CREATION_TIME >= exerpro.dateToLong(TO_CHAR(TRUNC(sysdate) - 30,'YYYY-MM-DD') || '00:00')
    /* Only ACTIVE OR FROZEN */
    AND s.STATE IN (2,4,8)
    AND s.CENTER in ($$scopes$$)
    /* Remove any that had another ACTIVE sub within 30 days from the latests creation date including transfered */
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            PERSONS p2
        JOIN
            SUBSCRIPTIONS s2
        ON
            s2.OWNER_CENTER = p2.CENTER
            AND s2.OWNER_ID = p2.ID
            /* Pick all state changes for ACTIVE and FROZEN subs */
        JOIN
            STATE_CHANGE_LOG scl
        ON
            scl.CENTER = s2.CENTER
            AND scl.ID = s2.ID
            AND scl.ENTRY_TYPE = 2
            AND scl.STATEID IN (2,4)
        WHERE
            /* Make sure we also get transferred persons */
            p2.CURRENT_PERSON_CENTER = p.CENTER
            AND p2.CURRENT_PERSON_ID = p.ID
            /* Exclude cancellations */
            AND s2.SUB_STATE NOT IN (8)
            /* Check if we have an ACTIVE/FROZEN state change log 30 days before the new sub was created and sysdate */
            AND (
                scl.BOOK_END_TIME IS NULL
                OR scl.BOOK_END_TIME BETWEEN (s.CREATION_TIME - 30 * 24 * 60 * 60 * 1000) AND exerpro.dateToLong(TO_CHAR(TRUNC(SYSDATE) ,'YYYY-MM-DD') || '00:00') )
            /* Remove the sub we are looking at */
            AND (
                s2.CENTER,s2.ID) NOT IN ((s.CENTER,
                                          s.ID)) )
    /* Filter out some product groups */
    AND pg.NAME NOT IN ('Mem Cat: Complimentary',
                        'Mem Cat: Jnr PAYP',
                        'Mem Cat: Junior DD',
                        'Mem Cat: Junior Diamonds')
    AND pg.EXCLUDE_FROM_MEMBER_COUNT = 0
