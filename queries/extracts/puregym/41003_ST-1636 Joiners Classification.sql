SELECT
    memberid,
    CASE
        WHEN CHANGE_TEXT = 'REJOINER'
            AND LAST_LEAVER < CHANGE_DATE -365
        THEN 'EX MEMBER'
        WHEN CHANGE_TEXT = 'JOINER'
        THEN 'NEW JOINER'
        WHEN CHANGE_TEXT = 'REACTIVATED'
        THEN 'REINSTALLED'
        ELSE CHANGE_TEXT
    END         AS CLASS,
    CHANGE_DATE AS JOIN_DATE,
    EXTERNAL_ID,
    Subscription,
    "Date of Birth",
    gender
    /*,
    TO_CHAR(LAST_LEAVER,'yyyy-MM-dd') AS LAST_LEAVE_DATE*/
FROM
    (
        SELECT
            p.CURRENT_PERSON_CENTER||'p'||p.CURRENT_PERSON_ID                                                                                                                                                             AS memberid,
            DECODE (CHANGE, 0,'OTHER', 1,'JOINER', 2,'REJOINER', 3,'REACTIVATED',4,'LEAVER',5,'LEAVER_END_OF_DAY',6,'CHANGE_MEMBERSHIP',7,'TRANSFER_OUT',8,'TRANSFER_IN',9,'TRANSFER_IN_AND_CHANGE_MEMBERSHIP','UNKNOWN') AS CHANGE_TEXT,
            dms.CHANGE_DATE,
            dms.change,
            (
                SELECT
                    TRUNC(longtodatetz(MAX(scl.BOOK_START_TIME),'Europe/London'))
                FROM
                    PUREGYM.STATE_CHANGE_LOG scl
                JOIN
                    PUREGYM.PERSONS p1
                ON
                    p1.CENTER = scl.center
                    AND p1.id = scl.id
                WHERE
                    p1.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
                    AND p1.CURRENT_PERSON_ID= p.CURRENT_PERSON_ID
                    AND scl.ENTRY_START_TIME < dms.ENTRY_START_TIME
                    AND scl.ENTRY_TYPE = 5
                    AND scl.STATEID = 5
                    AND scl.SUB_STATE = 5 ) AS LAST_LEAVER,
            cp.EXTERNAL_ID,
            cp.BIRTHDATE AS "Date of Birth",
            cp.SEX       AS gender,
            ss.subscription
        FROM
            PUREGYM.DAILY_MEMBER_STATUS_CHANGES dms
        JOIN
            PUREGYM.PERSONS p
        ON
            p.center = dms.PERSON_CENTER
            AND p.id = dms.PERSON_ID
        JOIN
            persons cp
        ON
            cp.center = p.CURRENT_PERSON_CENTER
            AND cp.id = p.CURRENT_PERSON_ID
        JOIN
            PUREGYM.BI_DECODE_VALUES dv
        ON
            dv.TABLE_NAME = 'DAILY_MEMBER_STATUS_CHANGES'
            AND dv.FIELD_NAME = 'CHANGE'
            AND dv.NUM_VALUE = dms.CHANGE
        LEFT JOIN
            (
                SELECT DISTINCT
                    ss.SALES_DATE,
                    pr.name AS subscription,
                    p1.CURRENT_PERSON_CENTER,
                    p1.CURRENT_PERSON_ID
                FROM
                    PUREGYM.SUBSCRIPTION_SALES ss
                JOIN
                    PUREGYM.PRODUCTS pr
                ON
                    pr.center = ss.SUBSCRIPTION_TYPE_CENTER
                    AND pr.id = ss.SUBSCRIPTION_TYPE_ID
                JOIN
                    PUREGYM.PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
                ON
                    ppgl.PRODUCT_CENTER = pr.center
                    AND ppgl.PRODUCT_ID = pr.id
                JOIN
                    PUREGYM.PERSONS p1
                ON
                    p1.center = ss.OWNER_CENTER
                    AND p1.id =ss.owner_id
                WHERE
                    (
                        ss.CANCELLATION_DATE IS NULL
                        OR ss.CANCELLATION_DATE > ss.SALES_DATE)
                    AND NOT EXISTS
                    (
                        SELECT
                            1
                        FROM
                            PUREGYM.PRODUCT_GROUP pg
                        WHERE
                            pg.EXCLUDE_FROM_MEMBER_COUNT = 1
                            AND pg.id = ppgl.PRODUCT_GROUP_ID)) ss
        ON
            ss.SALES_DATE = dms.CHANGE_DATE
            AND ss.CURRENT_PERSON_CENTER = cp.CURRENT_PERSON_CENTER
            AND ss.CURRENT_PERSON_ID = cp.CURRENT_PERSON_ID
        WHERE
            dms.CHANGE_DATE BETWEEN $$from_date$$ AND $$to_date$$
            AND dms.PERSON_CENTER IN ($$scope$$)
            AND dms.ENTRY_STOP_TIME IS NULL
            AND dms.MEMBER_NUMBER_DELTA = 1)