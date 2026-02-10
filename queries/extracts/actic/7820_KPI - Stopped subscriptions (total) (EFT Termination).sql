-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
 SU.CENTER, count(*)
FROM
    SUBSCRIPTION_CHANGE SC
INNER JOIN SUBSCRIPTIONS SU
ON
    (
        SC.OLD_SUBSCRIPTION_CENTER = SU.CENTER
        AND SC.OLD_SUBSCRIPTION_ID = SU.ID
    )
INNER JOIN SUBSCRIPTIONTYPES ST
ON
    (
        SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
        AND SU.SUBSCRIPTIONTYPE_ID = ST.ID
    )
INNER JOIN PRODUCTS PR
ON
    (
        ST.CENTER = PR.CENTER
        AND ST.ID = PR.ID
    )
JOIN PERSONS per
ON
    per.center = SU.OWNER_CENTER
    AND per.id = SU.OWNER_ID
LEFT JOIN person_ext_attrs mobil
ON
    per.center = mobil.personcenter
    AND per.id = mobil.personid
    AND mobil.TXTVALUE = '_eClub_PhoneSMS'
LEFT JOIN person_ext_attrs email
ON
    per.center = email.personcenter
    AND per.id = email.personid
    AND email.txtvalue = '_eClub_Email'
WHERE
    (
		SC.OLD_SUBSCRIPTION_CENTER in (:Scope)
        AND SC.TYPE = 'END_DATE'
        AND SC.CHANGE_TIME >= :ExtractFromDate
        AND SC.CHANGE_TIME <= :ExtractToDate + 1000*60*60*24
        AND
        (
            SC.CANCEL_TIME IS NULL
            OR SC.CANCEL_TIME > :ExtractToDate + 1000*60*60*24
        )
        AND ST.ST_TYPE = 1
        AND EXISTS
        (
            SELECT
                PAPGL.PRODUCT_GROUP_ID AS PAPGL_PRODUCT_GROUP_ID
            FROM
                PRODUCT_AND_PRODUCT_GROUP_LINK PAPGL
            WHERE
                (
                    PR.CENTER = PAPGL.PRODUCT_CENTER
                    AND PR.ID = PAPGL.PRODUCT_ID
                    AND PAPGL.PRODUCT_GROUP_ID IN (7)
                )
        )
        AND EXISTS
        (
            SELECT
                SCL.STATEID AS SCL_STATEID
            FROM
                STATE_CHANGE_LOG SCL
            WHERE
                (
                    SCL.CENTER = SU.OWNER_CENTER
                    AND SCL.ID = SU.OWNER_ID
                    AND SCL.BOOK_START_TIME <= :ExtractToDate + 1000*60*60*24
                    AND
                    (
                        SCL.BOOK_END_TIME IS NULL
                        OR SCL.BOOK_END_TIME >= :ExtractToDate + 1000*60*60*24
                    )
                    AND SCL.ENTRY_TYPE = 3
                    AND SCL.STATEID IN (1, 5, 3, 7, 0, 6, 4)
                )
        )
    )
group by SU.CENTER
