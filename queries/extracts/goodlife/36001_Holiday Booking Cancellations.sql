-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-6050

https://github.com/exerpteam/client-services-sql/blob/pipeline/Bookings/Cancellations/Holiday_bookings_cancel_GL.sql
WITH
    params AS
    (
        select 
        /*TO DATE, BASED ON FROM DATE*/
        datetolongTZ(to_char(CanadianStatutoryHoliday+add_days,'yyyy-mm-dd HH24:MI:SS'),time_zone)-1 as to_CanadianStatutoryHoliday,
        datetolongTZ(to_char(FamilyDay+add_days,'yyyy-mm-dd HH24:MI:SS'),time_zone)-1 as to_FamilyDay,
        datetolongTZ(to_char(GoodFriday+add_days,'yyyy-mm-dd HH24:MI:SS'),time_zone)-1 as to_GoodFriday,
        datetolongTZ(to_char(VictoriaDay+add_days,'yyyy-mm-dd HH24:MI:SS'),time_zone)-1 as to_VictoriaDay,
        datetolongTZ(to_char(CanadaDay+add_days,'yyyy-mm-dd HH24:MI:SS'),time_zone)-1 as to_CanadaDay,
        datetolongTZ(to_char(CivicHoliday+add_days,'yyyy-mm-dd HH24:MI:SS'),time_zone)-1 as to_CivicHoliday,
        datetolongTZ(to_char(Labourday+add_days,'yyyy-mm-dd HH24:MI:SS'),time_zone)-1 as to_Labourday,
        datetolongTZ(to_char(ThanksGiving+add_days,'yyyy-mm-dd HH24:MI:SS'),time_zone)-1 as to_ThanksGiving,
        datetolongTZ(to_char(Remembranceday+add_days,'yyyy-mm-dd HH24:MI:SS'),time_zone)-1 as to_Remembranceday,
        datetolongTZ(to_char(Christmasday+add_days,'yyyy-mm-dd HH24:MI:SS'),time_zone)-1 as to_Christmasday,
        datetolongTZ(to_char(Boxingday+add_days,'yyyy-mm-dd HH24:MI:SS'),time_zone)-1 as to_Boxingday,

        /*From DATE, BASED ON FROM DATE*/
        datetolongTZ(to_char(CanadianStatutoryHoliday,'yyyy-mm-dd HH24:MI:SS'),time_zone) as from_CanadianStatutoryHoliday,
        datetolongTZ(to_char(FamilyDay,'yyyy-mm-dd HH24:MI:SS'),time_zone) as from_FamilyDay,
        datetolongTZ(to_char(GoodFriday,'yyyy-mm-dd HH24:MI:SS'),time_zone) as from_GoodFriday,
        datetolongTZ(to_char(VictoriaDay,'yyyy-mm-dd HH24:MI:SS'),time_zone) as from_VictoriaDay,
        datetolongTZ(to_char(CanadaDay,'yyyy-mm-dd HH24:MI:SS'),time_zone) as from_CanadaDay,
        datetolongTZ(to_char(CivicHoliday,'yyyy-mm-dd HH24:MI:SS'),time_zone) as from_CivicHoliday,
        datetolongTZ(to_char(Labourday,'yyyy-mm-dd HH24:MI:SS'),time_zone) as from_Labourday,
        datetolongTZ(to_char(ThanksGiving,'yyyy-mm-dd HH24:MI:SS'),time_zone) as from_ThanksGiving,
        datetolongTZ(to_char(Remembranceday,'yyyy-mm-dd HH24:MI:SS'),time_zone) as from_Remembranceday,
        datetolongTZ(to_char(Christmasday,'yyyy-mm-dd HH24:MI:SS'),time_zone) as from_Christmasday,
        datetolongTZ(to_char(Boxingday,'yyyy-mm-dd HH24:MI:SS'),time_zone) as from_Boxingday,
        centerid,
        startdate,
        add_days,
        time_zone,
        z_province

        from (SELECT
            /*+ materialize */
            -- March  - Corona Virus
           to_date('2026-01-01','yyyy-mm-dd') AS CanadianStatutoryHoliday,
           to_date('2026-02-16','yyyy-mm-dd') AS FamilyDay,
           to_date('2026-04-03','yyyy-mm-dd') AS GoodFriday,
           to_date('2026-05-18','yyyy-mm-dd') AS VictoriaDay,
           to_date('2026-07-01','yyyy-mm-dd') AS CanadaDay,
           to_date('2026-08-03','yyyy-mm-dd') AS CivicHoliday,
           to_date('2026-09-07','yyyy-mm-dd') AS Labourday,
           to_date('2026-10-12','yyyy-mm-dd') AS ThanksGiving,
           to_date('2026-11-11','yyyy-mm-dd') AS Remembranceday,
           to_date('2026-12-25','yyyy-mm-dd') AS Christmasday,
           to_date('2026-12-26','yyyy-mm-dd') AS Boxingday,
           
            c.id               AS centerid,
            (4*24*3600*1000.0) AS startdate,
            interval '1 days' AS add_days,
            time_zone,
            z.province as z_province
        FROM
            centers c
        JOIN
            zipcodes z
        ON
            c.country = z.country
        AND c.zipcode = z.zipcode
        AND z.city = c.city
        WHERE
            c.time_zone IS NOT NULL)t
    )
SELECT DISTINCT
    CAST(b.center AS TEXT) AS "bookingCenter",
    CAST(b.id AS TEXT)     AS "bookingID",
    'false'                AS "notifyParticipants",
    'false'                AS "notifyStaff",
    CASE
        WHEN b.starttime BETWEEN from_CanadianStatutoryHoliday AND to_CanadianStatutoryHoliday
        THEN 'Canadian Statutory Holiday'
        WHEN b.starttime BETWEEN from_FamilyDay AND to_FamilyDay
        THEN 'Family Day - Provincial Statutory Holiday'
        WHEN b.starttime BETWEEN from_GoodFriday AND to_GoodFriday
        THEN 'Good Friday - Canadian Statutory Holiday'
        WHEN b.starttime BETWEEN from_VictoriaDay AND to_VictoriaDay
        THEN 'Victoria Day - Provincial Statutory Holiday'
        WHEN b.starttime BETWEEN from_CanadaDay AND to_CanadaDay
        THEN 'Canada Day - Canadian Statutory Holiday'
        WHEN b.starttime BETWEEN from_CivicHoliday AND to_CivicHoliday
        THEN 'Civic Holiday - Provincial Statutory Holiday'
        WHEN b.starttime BETWEEN from_Labourday AND to_Labourday
        THEN 'Labour Day - Canadian Statutory Holiday'
        WHEN b.starttime BETWEEN from_ThanksGiving AND to_ThanksGiving
        THEN 'Thanksgiving - Provincial Statutory Holiday'
        WHEN b.starttime BETWEEN from_Remembranceday AND to_Remembranceday
        THEN 'Remembrance Day - Provincial Statutory Holiday'
        WHEN b.starttime BETWEEN from_Christmasday AND to_Christmasday
        THEN 'Christmas Day - Canadian Statutory Holiday'
        WHEN b.starttime BETWEEN from_Boxingday AND to_Boxingday
        THEN 'Boxing Day - Provincial Statutory Holiday'
        ELSE 'Uknown Holiday'
    END AS "message"
    --,TO_CHAR(longtodateC(b.starttime, b.center),'YYYY-MM-DD HH24:MI') AS startTime,
    --TO_CHAR(longtodateC(b.stoptime, b.center),'YYYY-MM-DD HH24:MI')  AS stopTime,
    --ag.name,
    --b.name,
    --t.province
FROM
    (
        SELECT
            datetolongTZ(TO_CHAR(now(),'yyyy-mm-dd'),c.time_zone) currentdate,
            c.id,
            c.name,
            z.province
        FROM
            centers c
        JOIN
            goodlife.zipcodes z
        ON
            c.country = z.country
        AND c.zipcode = z.zipcode
        AND z.city = c.city )t
JOIN
    params
ON
    t.id = centerid
JOIN
    bookings b
ON
    b.center = centerid
JOIN
    goodlife.activity act
ON
    b.activity = act.id
JOIN
    goodlife.activity_group ag
ON
    ag.id = act.activity_group_id
LEFT JOIN
    goodlife.participations part
ON
    part.booking_center = b.center
AND part.booking_id = b.id
WHERE
    (
        act.activity_type = 4 -- Staff Booking
    OR  (
            act.activity_type = 2
        AND act.activity_group_id IN (7,203,3201)) )
AND act.state = 'ACTIVE'
AND b.state <>'CANCELLED'
AND ( (
            b.starttime BETWEEN from_CanadianStatutoryHoliday AND to_CanadianStatutoryHoliday
        AND currentdate >= from_CanadianStatutoryHoliday-startdate
        AND currentdate <=to_CanadianStatutoryHoliday )
    OR  (
            b.starttime BETWEEN from_FamilyDay AND to_FamilyDay
        AND t.province IN ('ON',
                           'AB',
                           'BC',
                           'MB',
                           'SK',
                           'NS',
                           'NB',
                           'PE')
        AND currentdate >= from_FamilyDay-startdate
        AND currentdate <= to_FamilyDay )
    OR  (
            b.starttime BETWEEN from_GoodFriday AND to_GoodFriday
        AND currentdate >= from_GoodFriday-startdate AND currentdate <=to_GoodFriday)
    OR  (
            b.starttime BETWEEN from_VictoriaDay AND to_VictoriaDay
        AND t.province IN ('ON',
                           'AB',
                           'BC',
                           'MB',
                           'SK')
        AND currentdate >= from_VictoriaDay-startdate
        AND currentdate <=to_VictoriaDay )
    OR  (
            b.starttime BETWEEN from_CanadaDay AND to_CanadaDay
        AND currentdate >= from_CanadaDay-startdate
        AND currentdate <=to_CanadaDay )
    OR  (
            b.starttime BETWEEN from_CivicHoliday AND to_CivicHoliday
        AND t.province IN ('BC',
                           'NB',
                           'SK')
        AND currentdate >= from_CivicHoliday-startdate
        AND currentdate <=to_CivicHoliday)
    OR  (
            b.starttime BETWEEN from_Labourday AND to_Labourday
        AND currentdate >= from_Labourday-startdate
        AND currentdate <=to_Labourday)
    OR  (
            b.starttime BETWEEN from_ThanksGiving AND to_ThanksGiving
        AND t.province IN ('ON',
                           'AB',
                           'BC',
                           'MB',
                           'SK')
        AND currentdate >= from_ThanksGiving-startdate
        AND currentdate <=to_ThanksGiving)
    OR  (
            b.starttime BETWEEN from_Remembranceday AND to_Remembranceday
        AND t.province IN ('AB',
                           'BC',
                           'MB',
                           'SK',
                           'NS',
                           'NB',
                           'NL',
                           'PE')
        AND currentdate >= from_Remembranceday-startdate
        AND currentdate <=to_Remembranceday)
    OR  (
            b.starttime BETWEEN from_Christmasday AND to_Christmasday
        AND currentdate >= from_Christmasday-startdate
        AND currentdate <=to_Christmasday)
    OR  (
            b.starttime BETWEEN from_Boxingday AND to_Boxingday
        AND t.province IN ('ON')
        AND currentdate >= from_Boxingday-startdate
        AND currentdate <=to_Boxingday) )
ORDER BY
    2