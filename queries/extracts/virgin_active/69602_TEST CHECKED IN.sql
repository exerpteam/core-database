SELECT
chin.centerid,
chin.center,
chin.totalcheckins,
chin.checkindate,
chin.maxallowed,

chin.t06 AS "ore 06 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t06 :: DECIMAL) AS "ore 06 AVAILABLE",

chin.t07 AS "ore 07 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t07 :: DECIMAL) AS "ore 07 AVAILABLE",

chin.t08 AS "ore 08 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t08 :: DECIMAL) AS "ore 08 AVAILABLE",

chin.t09 AS "ore 09 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t09 :: DECIMAL) AS "ore 09 AVAILABLE",

chin.t10 AS "ore 10 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t10 :: DECIMAL) AS "ore 10 AVAILABLE",

chin.t11 AS "ore 11 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t11 :: DECIMAL) AS "ore 11 AVAILABLE",

chin.t12 AS "ore 12 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t12 :: DECIMAL) AS "ore 12 AVAILABLE",

chin.t13 AS "ore 13 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t13 :: DECIMAL) AS "ore 13 AVAILABLE",

chin.t14 AS "ore 14 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t14 :: DECIMAL) AS "ore 14 AVAILABLE",

chin.t15 AS "ore 15 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t15 :: DECIMAL) AS "ore 15 AVAILABLE",

chin.t16 AS "ore 16 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t16 :: DECIMAL) AS "ore 16 AVAILABLE",

chin.t17 AS "ore 17 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t17 :: DECIMAL) AS "ore17 AVAILABLE",

chin.t18 AS "ore 18 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t18 :: DECIMAL) AS "ore 18 AVAILABLE",

chin.t19 AS "ore 19 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t19 :: DECIMAL) AS "ore19 AVAILABLE",

chin.t20 AS "ore 20 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t20 :: DECIMAL) AS "ore 20 AVAILABLE",

chin.t21 AS "ore 21 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t21 :: DECIMAL) AS "ore21 AVAILABLE",

chin.t22 AS "ore 22 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t22 :: DECIMAL) AS "ore22 AVAILABLE",

chin.t23 AS "ore 23 IN",
(chin.MaxAllowed :: DECIMAL)-(chin.t23 :: DECIMAL) AS "ore 23 AVAILABLE"
FROM
(SELECT
    ci.checkin_center                                  AS CenterId,
    c.name                                             AS Center,
    COUNT(ci.ID)                                       AS TotalCheckIns,
    TO_CHAR(longtodate(ci.checkin_time), 'dd-MM-YYYY') AS CheckinDate,
    sys.txtvalue                                       AS MaxAllowed,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '06'
            
            THEN 1
        END) t06,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '07'
          
            THEN 1
        END) t07,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '08'
            
            THEN 1
        END) t08,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '09'
            
            THEN 1
        END) t09,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '10'
            
            THEN 1
        END) t10,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '11'
            
            THEN 1
        END) t11,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '12'
            
            THEN 1
        END) t12,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '13'
            
            THEN 1
        END) t13,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '14'
            
            THEN 1
        END) t14,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '15'
            
            THEN 1
        END) t15,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '16'
           
            THEN 1
        END) t16,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '17'
               
            THEN 1
        END) t17,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '18'
            
            THEN 1
        END) t18,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '19'
            
            THEN 1
        END) t19,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '20'
           
            THEN 1
        END) t20,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '21'
            
            THEN 1
        END) t21,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24') = '22'
            
            THEN 1
        END) t22,
    COUNT(
        CASE
            WHEN TO_CHAR(longtodate(ci.checkin_time), 'hh24:MI') = '23'
           
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