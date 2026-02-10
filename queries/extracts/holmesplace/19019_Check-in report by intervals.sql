-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-8272
https://clublead.atlassian.net/browse/ST-10033
WITH param_dates AS
(
        SELECT
                 /*+ materialize */
                CAST (datetolongC(TO_CHAR( DATE_TRUNC('day',CURRENT_DATE), 'YYYY-MM-dd HH24:MI' ), c.id) AS BIGINT) AS TODAY,
                CAST (datetolongC(TO_CHAR( DATE_TRUNC('day',CURRENT_DATE - interval '7 days'), 'YYYY-MM-dd HH24:MI' ), c.id) AS BIGINT) AS SEVEN_DAYS,
                CAST (datetolongC(TO_CHAR( DATE_TRUNC('day',CURRENT_DATE - interval '30 days'), 'YYYY-MM-dd HH24:MI' ), c.id) AS BIGINT) AS THIRTY_DAYS,
                CAST (datetolongC(TO_CHAR( DATE_TRUNC('day',CURRENT_DATE - interval '90 days'), 'YYYY-MM-dd HH24:MI' ), c.id) AS  BIGINT) AS NINETY_DAYS,
                CAST (datetolongC(TO_CHAR( DATE_TRUNC('day',CURRENT_DATE - interval '180 days'), 'YYYY-MM-dd HH24:MI' ), c.id) AS BIGINT) AS ONE_EIHTY_DAYS,
                c.id AS CENTER
        FROM
                CENTERS c
),
v_checkin AS
    (
        SELECT
            p.center,
            p.id,
            SUM(
                CASE
                    WHEN c.checkin_time BETWEEN pd.SEVEN_DAYS AND pd.TODAY
                    THEN 1
                    ELSE 0
                END) AS Total7days,
            SUM(
                CASE
                    WHEN c.checkin_time BETWEEN pd.THIRTY_DAYS AND pd.TODAY
                    THEN 1
                    ELSE 0
                END) AS Total30days,
            SUM(
                CASE
                    WHEN c.checkin_time BETWEEN pd.NINETY_DAYS AND pd.TODAY
                    THEN 1
                    ELSE 0
                END) AS Total90days,
            SUM(
                CASE
                    WHEN c.checkin_time BETWEEN pd.ONE_EIHTY_DAYS AND pd.TODAY
                    THEN 1
                    ELSE 0
                END) AS Total180days
        FROM
            PERSONS p
        JOIN
            PERSON_EXT_ATTRS gdprOptin
        ON
            p.center=gdprOptin.PERSONCENTER
            AND p.id=gdprOptin.PERSONID
            AND gdprOptin.name='GDPROPTIN'
        JOIN 
            PERSONS cp 
        ON
            cp.TRANSFERS_CURRENT_PRS_CENTER = p.CENTER
            AND cp.TRANSFERS_CURRENT_PRS_ID = p.ID
        JOIN
            checkins c
        ON
            c.person_center = cp.center
            AND c.person_id = cp.id
        JOIN 
            param_dates pd ON pd.CENTER = c.person_center
        WHERE
            p.center IN (:Scope)
            AND gdprOptin.txtvalue = 'true'
            AND p.status != 5
            --AND c.checkin_time >= datetolongC(TO_CHAR( DATE_TRUNC('day',CURRENT_DATE - interval '180 days'), 'YYYY-MM-dd HH24:MI' ), c.person_center)
			AND c.checkin_time >= pd.ONE_EIHTY_DAYS
        GROUP BY
            p.center,
            p.id
    )
SELECT
    p.external_id                                                                                                                                                                   AS "EXTERNAL ID",
    p.center || 'p' || p.id                                                                                                                                                         AS "PERSON ID",
    p.center                                                                                                                                                                        AS "CENTER ID",
    email.txtvalue                                                                                                                                                                  AS "EMAIL",
    originalStartDate.txtvalue                                                                                                                                                      AS "ORIGINAL_START_DATE",
    (CASE p.PERSONTYPE
        WHEN 0 THEN 'Private'
        WHEN 1 THEN 'Student'
        WHEN 2 THEN 'Staff'
        WHEN 3 THEN 'Friend'
        WHEN 4 THEN 'Corporate'
        WHEN 5 THEN 'Onemancorporate'
        WHEN 6 THEN 'Family'
        WHEN 7 THEN 'Senior'
        WHEN 8 THEN 'Guest'
        WHEN 9 THEN 'Child'
        WHEN 10 THEN 'External_Staff'
        ELSE 'Unknown'
    END) AS "PERSONTYPE",
    (CASE p.STATUS
        WHEN 0 THEN 'Lead'
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'Inactive'
        WHEN 3 THEN 'Temporary Inactive'
        WHEN 4 THEN 'Transferred'
        WHEN 5 THEN 'Duplicate'
        WHEN 6 THEN 'Prospect'
        WHEN 7 THEN 'Deleted'
        WHEN 8 THEN 'Anonymized'
        WHEN 9 THEN 'Contact'
        ELSE 'Unknown'
    END) AS "STATUS",
    c.Total7days                                                                                                                                                                    AS "Checkin Count Last 7 Days",
    c.Total30days                                                                                                                                                                   AS "Checkin Count Last 30 Days",
    c.Total90days                                                                                                                                                                   AS "Checkin Count Last 90 Days",
    c.Total180days                                                                                                                                                                  AS "Checkin Count Last 180 Days"
FROM
    v_checkin c
JOIN
    PERSONS p
ON
    p.center = c.center
    AND p.id = c.id
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS originalStartDate
ON
    p.center=originalStartDate.PERSONCENTER
    AND p.id=originalStartDate.PERSONID
    AND originalStartDate.name='OriginalStartDate'