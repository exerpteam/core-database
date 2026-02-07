SELECT
    ag.ID                                                                     AS "ID",
    ag.NAME                                                                   AS "NAME",
    ag.STATE                                                                  AS "STATE",
    COALESCE(CAST(CAST (ag.BOOKABLE_IN_KIOSK AS INT) AS SMALLINT) ,0)         AS "BOOK_KIOSK",
    COALESCE(CAST(CAST (ag.BOOKABLE_ON_WEB AS INT) AS SMALLINT) ,0)           AS "BOOK_WEB",
    COALESCE(CAST(CAST (ag.BOOKABLE_VIA_API AS INT) AS SMALLINT) ,0)          AS "BOOK_API",
    COALESCE(CAST(CAST (ag.BOOKABLE_VIA_MOBILE_API AS INT) AS SMALLINT) ,0)   AS "BOOK_MOBILE_API",
    COALESCE(CAST(CAST (ag.BOOKABLE_ON_FRONTDESK_APP AS INT) AS SMALLINT) ,0) AS "BOOK_CLIENT",
    ag.PARENT_ACTIVITY_GROUP_ID                                               AS "PARENT_ACTIVITY_GROUP_ID",
    ag.EXTERNAL_ID                                                            AS "EXTERNAL_ID",
    ag.LAST_MODIFIED                                                          AS "ETS"
FROM
    ACTIVITY_GROUP ag
WHERE
    ag.TOP_NODE_ID IS NULL
    AND ag.STATE != 'DRAFT'
