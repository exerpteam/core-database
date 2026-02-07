-- This is the version from 2026-02-05
--  
SELECT 
    p.center,
    SUM(
        CASE
            WHEN acc_news.TXTVALUE IS NULL
                OR acc_news.TXTVALUE = 'false'
            THEN 0
            ELSE 1
        END) as cnt_accept,

    SUM(
        CASE
            WHEN acc_news.TXTVALUE IS NULL
                OR acc_news.TXTVALUE = 'false'
            THEN 1
            ELSE 0
        END) as cnt_dont_accept
FROM
    PERSONS P
LEFT JOIN SUBSCRIPTIONS S
ON
    P.CENTER = S.OWNER_CENTER
    AND P.ID = S.OWNER_ID

LEFT JOIN PERSON_EXT_ATTRS acc_news
ON
    acc_news.PERSONCENTER= P.CENTER
    AND acc_news.PERSONID = P.ID
    AND acc_news.NAME IN ( '_eClub_IsAcceptingEmailNewsLetters' )
WHERE
S.CREATION_TIME >= :Creation_DATE_FROM AND S.CREATION_TIME < :Creation_DATE_TO
GROUP BY
    p.center