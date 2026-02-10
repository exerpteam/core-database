-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
chin.centerid,
chin.center,
chin.totalcheckins,
chin.checkindate,
chin.maxallowed,
chin.t06 AS "06 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t06 :: DECIMAL) AS "06 AVAILABLE",
chin.t07 AS "07 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t07 :: DECIMAL) AS "07 AVAILABLE",
chin.t08 AS "08 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t08 :: DECIMAL) AS "08 AVAILABLE",
chin.t09 AS "09 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t09 :: DECIMAL) AS "09 AVAILABLE",
chin.t10 AS "10 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t10 :: DECIMAL) AS "10 AVAILABLE",
chin.t11 AS "11 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t11 :: DECIMAL) AS "11 AVAILABLE",
chin.t12 AS "12 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t12 :: DECIMAL) AS "12 AVAILABLE",
chin.t13 AS "13 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t13 :: DECIMAL) AS "13 AVAILABLE",
chin.t14 AS "14 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t14 :: DECIMAL) AS "14 AVAILABLE",
chin.t15 AS "15 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t15 :: DECIMAL) AS "15 AVAILABLE",
chin.t16 AS "16 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t16 :: DECIMAL) AS "16 AVAILABLE",
chin.t17 AS "17 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t17 :: DECIMAL) AS "17 AVAILABLE",
chin.t18 AS "18 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t18 :: DECIMAL) AS "18 AVAILABLE",
chin.t19 AS "19 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t19 :: DECIMAL) AS "19 AVAILABLE",
chin.t20 AS "20 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t20 :: DECIMAL) AS "20 AVAILABLE",
chin.t21 AS "21 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t21 :: DECIMAL) AS "21 AVAILABLE",
chin.t22 AS "22 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t22 :: DECIMAL) AS "22 AVAILABLE",
chin.t23 AS "23 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t23 :: DECIMAL) AS "23 AVAILABLE"
FROM
(SELECT
    ci.checkin_center                                  AS CenterId,
    c.name                                             AS Center,
    COUNT(ci.ID)                                       AS TotalCheckIns,
    TO_CHAR(longtodate(ci.checkin_time), 'dd-MM-YYYY') AS CheckinDate,
    sys.txtvalue                                       AS MaxAllowed,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '07'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '06'
                OR  ci.checkout_time IS NULL)
            THEN 1
        END) t06,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '08'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '07'
                OR  ci.checkout_time IS NULL)
            THEN 1
        END) t07,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '09'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '08'
                OR  ci.checkout_time IS NULL)
            THEN 1
        END) t08,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '10'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '09'
                OR  ci.checkout_time IS NULL)
            THEN 1
        END) t09,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '11'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '10'
                OR  ci.checkout_time IS NULL)
            THEN 1
        END) t10,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '12'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '11'
                OR  ci.checkout_time IS NULL)
            THEN 1
        END) t11,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '13'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '12'
                OR  ci.checkout_time IS NULL)
            THEN 1
        END) t12,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '14'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '13'
                OR  ci.checkout_time IS NULL)
            THEN 1
        END) t13,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '15'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '14'
                OR  ci.checkout_time IS NULL)
            THEN 1
        END) t14,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '16'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '15'
                OR  ci.checkout_time IS NULL)
            THEN 1
        END) t15,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '17'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '16'
                OR  ci.checkout_time IS NULL)
            THEN 1
        END) t16,
    COUNT(
        CASE
            WHEN (TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '18'
                AND TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '17'
                OR  ci.checkout_time IS NULL)
            THEN 1
        END) t17,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '19'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '18'
                OR  ci.checkout_time IS NULL)
            THEN 1
        END) t18,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '20'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '19'
                OR  ci.checkout_time IS NULL
                OR  to_timestamp(ci.checkout_time/1000) :: DATE > :date)
            THEN 1
        END) t19,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '21'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '20'
                OR  ci.checkout_time IS NULL
                OR  to_timestamp(ci.checkout_time/1000) :: DATE > :date)
            THEN 1
        END) t20,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '22'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '21'
                OR  ci.checkout_time IS NULL
                OR  to_timestamp(ci.checkout_time/1000) :: DATE > :date)
            THEN 1
        END) t21,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') < '23'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '22'
                OR  ci.checkout_time IS NULL
                OR  to_timestamp(ci.checkout_time/1000) :: DATE > :date)
            THEN 1
        END) t22,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24:MI') <= '23:59'
            AND (TO_CHAR(longtodate(ci.checkout_time), 'hh24') >= '23'
                OR  ci.checkout_time IS NULL
                OR  to_timestamp(ci.checkout_time/1000) :: DATE > :date)
            THEN 1
        END) t23
FROM
    checkins ci
JOIN
    centers c
ON
    c.id = ci.checkin_center
LEFT JOIN
    systemproperties SYS
ON
    sys.scope_id = ci.checkin_center
AND sys.scope_type = 'C'
AND sys.globalid = 'MaximumAllowedCheckedInPerCenter'
WHERE
    ci.checkin_center IN (:scope)
AND ci.checkin_result IN (1,2)
AND to_timestamp(ci.checkin_time/1000) :: DATE = :date
GROUP BY
    ci.checkin_center,
    c.name,
    CheckinDate,
    MaxAllowed ) chin