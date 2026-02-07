SELECT
    p.CENTER||'p'||p.ID AS "MemberID",
    p.FULLNAME          AS "Member Name",
    c.SHORTNAME         AS "Center Name",
    CASE
        WHEN p.STATUS = 0
        THEN 'LEAD'
        WHEN p.STATUS = 1
        THEN 'ACTIVE'
        WHEN p.STATUS = 2
        THEN 'INACTIVE'
        WHEN p.STATUS = 3
        THEN 'TEMPORARYINACTIVE'
        WHEN p.STATUS = 4
        THEN 'TRANSFERED'
        WHEN p.STATUS = 5
        THEN 'DUPLICATE'
        WHEN p.STATUS = 6
        THEN 'PROSPECT'
        WHEN p.STATUS = 7
        THEN 'DELETED'
        WHEN p.STATUS = 8
        THEN 'ANONYMIZED'
        WHEN p.STATUS = 9
        THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END                          AS "Member Status",
    pea_default_channel.TXTVALUE AS "Default communication channel",
    pea_email.TXTVALUE           AS "Member email address",
    CASE
        WHEN pea_newsletter.TXTVALUE = 'true'
        THEN 'Yes'
        ELSE 'No'
    END AS "Accepting newsletter",
    CASE
        WHEN last_change_newsletter.NEW_VALUE = 'true'
        THEN longtodateC(last_change_newsletter.ENTRY_TIME,p.CENTER)
        END  AS
"Accepting newsletter Date",
CASE
WHEN pea_thirdparty.TXTVALUE = 'true'THEN
    'Yes'
ELSE
    'No'
END AS "Accepting third party",
CASE
WHEN last_change_tp.NEW_VALUE = 'true'THEN
    longtodateC(last_change_tp.ENTRY_TIME,p.CENTER)
END AS "Accepting third party Date",
CASE
WHEN pea_childrensfitnesscomms.TXTVALUE = 'true'THEN
    'Yes'
ELSE
    'No'
END AS "Children's Fitness",
CASE
WHEN last_change_cf.NEW_VALUE = 'true'THEN
    longtodateC(last_change_cf.ENTRY_TIME,p.CENTER)
END AS "Children's Fitness Date",
CASE
WHEN pea_FitnessComms.TXTVALUE = 'true'THEN
    'Yes'
ELSE
    'No'
END AS "Comm. Fitness",
CASE
WHEN last_change_comfit.NEW_VALUE = 'true'THEN
    longtodateC(last_change_comfit.ENTRY_TIME,p.CENTER)
END AS "Comm. Fitness Date",
CASE
WHEN pea_groupexercisecomms.TXTVALUE = 'true'THEN
    'Yes'
ELSE
    'No'
END AS "Comm. Group Exercise",
CASE
WHEN last_change_grex.NEW_VALUE = 'true'THEN
    longtodateC(last_change_grex.ENTRY_TIME,p.CENTER)
END AS "Comm. Group Exercise Date",
CASE
WHEN pea_parties.TXTVALUE = 'true'THEN
    'Yes'
ELSE
    'No'
END AS "Comm. on parties & functions",
CASE
WHEN last_change_cparty.NEW_VALUE = 'true'THEN
    longtodateC(last_change_cparty.ENTRY_TIME,p.CENTER)
END AS "Comm. on parties Date",
CASE
WHEN pea_sportscomms.TXTVALUE = 'true'THEN
    'Yes'
ELSE
    'No'
END AS "Comm. on sports",
CASE
WHEN last_change_sport.NEW_VALUE = 'true'THEN
    longtodateC(last_change_sport.ENTRY_TIME,p.CENTER)
END AS "Comm. on sports Date"FROM Persons p 

LEFT JOIN PERSON_EXT_ATTRS pea_default_channel ON
p.CENTER = pea_default_channel.PERSONCENTER
AND
p.ID = pea_default_channel.PERSONID
AND
pea_default_channel.name = '_eClub_DefaultMessaging'LEFT JOIN PERSON_EXT_ATTRS pea_email ON
p.CENTER = pea_email.PERSONCENTER
AND
p.ID = pea_email.PERSONID
AND
pea_email.name = '_eClub_Email'LEFT JOIN PERSON_EXT_ATTRS pea_newsletter ON p.CENTER =
pea_newsletter.PERSONCENTER
AND
p.ID = pea_newsletter.PERSONID
AND
pea_newsletter.name = 'eClubIsAcceptingEmailNewsLetters'LEFT JOIN PERSON_EXT_ATTRS pea_thirdparty
ON p.CENTER = pea_thirdparty.PERSONCENTER
AND
p.ID = pea_thirdparty.PERSONID
AND
pea_thirdparty.name = 'eClubIsAcceptingThirdPartyOffers'LEFT JOIN PERSON_EXT_ATTRS
pea_childrensfitnesscomms ON p.CENTER = pea_childrensfitnesscomms.PERSONCENTER
AND
p.ID = pea_childrensfitnesscomms.PERSONID
AND
pea_childrensfitnesscomms.name = 'childrensfitnesscomms'LEFT JOIN PERSON_EXT_ATTRS pea_FitnessComms
ON p.CENTER = pea_FitnessComms.PERSONCENTER
AND
p.ID = pea_FitnessComms.PERSONID
AND
pea_FitnessComms.name = 'FitnessComms'LEFT JOIN PERSON_EXT_ATTRS pea_groupexercisecomms ON p.CENTER
= pea_groupexercisecomms.PERSONCENTER
AND
p.ID = pea_groupexercisecomms.PERSONID
AND
pea_groupexercisecomms.name = 'groupexercisecomms' LEFT JOIN PERSON_EXT_ATTRS pea_parties ON
p.CENTER = pea_parties.PERSONCENTER
AND
p.ID = pea_parties.PERSONID
AND
pea_parties.name = 'partiesfunctionscomms'LEFT JOIN PERSON_EXT_ATTRS pea_sportscomms ON p.CENTER =
pea_sportscomms.PERSONCENTER
AND
p.ID = pea_sportscomms.PERSONID
AND
pea_sportscomms.name = 'sportscomms' LEFT JOIN
(
    SELECT
        PERSON_CENTER,
        PERSON_ID,
        ENTRY_TIME,
        NEW_VALUE
    FROM
        (
            SELECT
                RANK() over (PARTITION BY PERSON_CENTER, PERSON_ID, CHANGE_ATTRIBUTE ORDER BY
                ENTRY_TIME DESC) AS myRANK,
                pcl.*
            FROM
                PERSON_CHANGE_LOGS pcl
            WHERE
                pcl.CHANGE_ATTRIBUTE IN ('eClubIsAcceptingEmailNewsLetters') ) t
    WHERE
        t.MYRANK = 1) last_change_newsletter ON last_change_newsletter.PERSON_CENTER = p.CENTER
AND
last_change_newsletter.Person_ID = p.ID LEFT JOIN
(
    SELECT
        PERSON_CENTER,
        PERSON_ID,
        ENTRY_TIME,
        NEW_VALUE
    FROM
        (
            SELECT
                RANK() over (PARTITION BY PERSON_CENTER, PERSON_ID, CHANGE_ATTRIBUTE ORDER BY
                ENTRY_TIME DESC) AS myRANK,
                pcl.*
            FROM
                PERSON_CHANGE_LOGS pcl
            WHERE
                pcl.CHANGE_ATTRIBUTE = 'eClubIsAcceptingThirdPartyOffers' ) t
    WHERE
        t.MYRANK = 1) last_change_tp ON last_change_tp.PERSON_CENTER = p.CENTER
AND
last_change_tp.Person_ID = p.ID LEFT JOIN
(
    SELECT
        PERSON_CENTER,
        PERSON_ID,
        ENTRY_TIME,
        NEW_VALUE
    FROM
        (
            SELECT
                RANK() over (PARTITION BY PERSON_CENTER, PERSON_ID, CHANGE_ATTRIBUTE ORDER BY
                ENTRY_TIME DESC) AS myRANK,
                pcl.*
            FROM
                PERSON_CHANGE_LOGS pcl
            WHERE
                pcl.CHANGE_ATTRIBUTE = 'childrensfitnesscomms' ) t
    WHERE
        t.MYRANK = 1) last_change_cf ON last_change_cf.PERSON_CENTER = p.CENTER
AND
last_change_cf.Person_ID = p.ID LEFT JOIN
(
    SELECT
        PERSON_CENTER,
        PERSON_ID,
        ENTRY_TIME,
        NEW_VALUE
    FROM
        (
            SELECT
                RANK() over (PARTITION BY PERSON_CENTER, PERSON_ID, CHANGE_ATTRIBUTE ORDER BY
                ENTRY_TIME DESC) AS myRANK,
                pcl.*
            FROM
                PERSON_CHANGE_LOGS pcl
            WHERE
                pcl.CHANGE_ATTRIBUTE = 'FitnessComms' ) t
    WHERE
        t.MYRANK = 1) last_change_comfit ON last_change_comfit.PERSON_CENTER = p.CENTER
AND
last_change_comfit.Person_ID = p.ID LEFT JOIN
(
    SELECT
        PERSON_CENTER,
        PERSON_ID,
        ENTRY_TIME,
        NEW_VALUE
    FROM
        (
            SELECT
                RANK() over (PARTITION BY PERSON_CENTER, PERSON_ID, CHANGE_ATTRIBUTE ORDER BY
                ENTRY_TIME DESC) AS myRANK,
                pcl.*
            FROM
                PERSON_CHANGE_LOGS pcl
            WHERE
                pcl.CHANGE_ATTRIBUTE = 'groupexercisecomms' ) t
    WHERE
        t.MYRANK = 1) last_change_grex ON last_change_grex.PERSON_CENTER = p.CENTER
AND
last_change_grex.Person_ID = p.ID LEFT JOIN
(
    SELECT
        PERSON_CENTER,
        PERSON_ID,
        ENTRY_TIME,
        NEW_VALUE
    FROM
        (
            SELECT
                RANK() over (PARTITION BY PERSON_CENTER, PERSON_ID, CHANGE_ATTRIBUTE ORDER BY
                ENTRY_TIME DESC) AS myRANK,
                pcl.*
            FROM
                PERSON_CHANGE_LOGS pcl
            WHERE
                pcl.CHANGE_ATTRIBUTE = 'partiesfunctionscomms' ) t
    WHERE
        t.MYRANK = 1) last_change_cparty ON last_change_cparty.PERSON_CENTER = p.CENTER
AND
last_change_cparty.Person_ID = p.ID LEFT JOIN
(
    SELECT
        PERSON_CENTER,
        PERSON_ID,
        ENTRY_TIME,
        NEW_VALUE
    FROM
        (
            SELECT
                RANK() over (PARTITION BY PERSON_CENTER, PERSON_ID, CHANGE_ATTRIBUTE ORDER BY
                ENTRY_TIME DESC) AS myRANK,
                pcl.*
            FROM
                PERSON_CHANGE_LOGS pcl
            WHERE
                pcl.CHANGE_ATTRIBUTE = 'sportscomms' ) t
    WHERE
        t.MYRANK = 1) last_change_sport ON last_change_sport.PERSON_CENTER = p.CENTER
AND
last_change_sport.Person_ID = p.ID JOIN centers c ON c.ID = p.CENTER WHERE p.CENTER IN (:Scope)