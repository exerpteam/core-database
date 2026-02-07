WITH
        params AS
        (
                SELECT
                    /*+ materialize */
                    datetolongTZ(TO_CHAR(current_date,'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS cutDate,
                    -- December 25, 2018 - Christmas Day - Canadian Statutory Holiday
                    datetolongTZ(TO_CHAR(to_date('2018-12-25','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateDec25,
                    datetolongTZ(TO_CHAR(to_date('2018-12-26','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateDec25,
                    -- December 26, 2018 - Boxing Day - Provincial Statutory Holiday: Ontario 
                    datetolongTZ(TO_CHAR(to_date('2018-12-26','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateDec26,
                    datetolongTZ(TO_CHAR(to_date('2018-12-27','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateDec26,
                    -- January 1, 2019 - New Years Day - Canadian Statutory Holiday
                    datetolongTZ(TO_CHAR(to_date('2019-01-01','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateJan,
                    datetolongTZ(TO_CHAR(to_date('2019-01-02','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateJan,
                    -- February 18 2019 - Family Day - Provincial Statutory Holiday: Ontario, Alberta, British Columbia, Manitoba, Saskatchewan, Nova Scotia, New Brunswick, PEI
                    datetolongTZ(TO_CHAR(to_date('2019-02-18','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateFeb,
                    datetolongTZ(TO_CHAR(to_date('2019-02-19','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateFeb,
                    -- April 19, 2019 - Good Friday - Canadian Statutory Holiday
                    datetolongTZ(TO_CHAR(to_date('2019-04-19','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateApr,
                    datetolongTZ(TO_CHAR(to_date('2019-04-20','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateApr,
                    -- May 20, 2019 - Victoria Day - Provincial Statutory Holiday: Ontario, Alberta, British Columbia, Manitoba, Saskatchewan
                    datetolongTZ(TO_CHAR(to_date('2019-05-20','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateMay,
                    datetolongTZ(TO_CHAR(to_date('2019-05-21','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateMay,
                    -- July 1, 2019 - Canada Day - Canadian Statutory Holiday
                    datetolongTZ(TO_CHAR(to_date('2019-07-01','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateJul,
                    datetolongTZ(TO_CHAR(to_date('2019-07-02','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateJul,
                    -- August 5, 2019 - Civic Holiday - Canadian Statutory Holiday
                    datetolongTZ(TO_CHAR(to_date('2019-08-05','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateAug,
                    datetolongTZ(TO_CHAR(to_date('2019-08-06','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateAug,
                    -- September 2, 2019 - Labour Day - Canadian Statutory Holiday
                    datetolongTZ(TO_CHAR(to_date('2019-09-02','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateSep,
                    datetolongTZ(TO_CHAR(to_date('2019-09-03','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateSep,
                    -- October 14, 2019 - Thanksgiving - Provincial Statutory Holiday: Ontario, Alberta, British Columbia, Manitoba, Saskatchewan
                    datetolongTZ(TO_CHAR(to_date('2019-10-14','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateOct,
                    datetolongTZ(TO_CHAR(to_date('2019-10-15','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateOct,
                    -- November 11, 2019 - Remembrance Day - Provincial Statutory Holiday: Alberta, British Columbia, Manitoba, Saskatchewan, Nova Scotia, New Brunswick, Newfoundland, PEI
                    datetolongTZ(TO_CHAR(to_date('2019-11-11','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateNov,
                    datetolongTZ(TO_CHAR(to_date('2019-11-12','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateNov,
                    -- December 25, 2019 - Christmas Day - Canadian Statutory Holiday
                    datetolongTZ(TO_CHAR(to_date('2019-12-25','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateDec25_2019,
                    datetolongTZ(TO_CHAR(to_date('2019-12-26','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateDec25_2019,
                    -- December 26, 2019 - Boxing Day - Provincial Statutory Holiday: Ontario 
                    datetolongTZ(TO_CHAR(to_date('2019-12-26','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateDec26_2019,
                    datetolongTZ(TO_CHAR(to_date('2019-12-27','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateDec26_2019,
                    -- January 1, 2020 - New Years Day - Canadian Statutory Holiday
                    datetolongTZ(TO_CHAR(to_date('2020-01-01','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS fromDateJan_2020,
                    datetolongTZ(TO_CHAR(to_date('2020-01-02','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone)  AS toDateJan_2020,
                    c.id AS centerid,
                    z.province
                FROM
                    goodlife.centers c
                JOIN
                    goodlife.zipcodes z ON c.country = z.country AND c.zipcode = z.zipcode AND z.city = c.city
                WHERE
                    c.time_zone IS NOT NULL
        )
SELECT
        TO_CHAR(longtodateC(bk.starttime, bk.center),'YYYY-MM-DD HH24:MI') AS startTime,
        TO_CHAR(longtodateC(bk.stoptime, bk.center),'YYYY-MM-DD HH24:MI') AS stopTime,
		TO_CHAR(longtodateC(bk.creation_time, bk.center),'YYYY-MM-DD HH24:MI') AS creationTime,
        params.province,
        bk.center AS BookingCenter,
        bk.id AS BookingId,
        bk.name AS BookingName,
        act.name AS ActivityName,
        ag.name AS ActivityGroupName,
		part.booking_participation_type,
        part.participant_center || 'p' || part.participant_id AS Participant,
        part.owner_center || 'p' || part.owner_id AS OwnerPart
FROM goodlife.bookings bk
JOIN params ON bk.center = params.centerid
JOIN goodlife.activity act ON bk.activity = act.id
JOIN goodlife.activity_group ag ON ag.id = act.activity_group_id
LEFT JOIN goodlife.participations part ON part.booking_center = bk.center AND part.booking_id = bk.id
--JOIN BOOKINGS main ON bk.MAIN_BOOKING_CENTER = main.CENTER AND bk.MAIN_BOOKING_ID = main.ID
WHERE 
        --bk.CENTER = 50 AND 
        (
        act.activity_type = 4 -- Staff Booking
        OR
        (act.activity_type = 2 AND act.activity_group_id IN (7,203,1201))
        )
        AND bk.state != 'CANCELLED'
        AND act.state = 'ACTIVE'
        AND     
                (
                        -- December 25, 2018 - Christmas Day - Canadian Statutory Holiday
                        (bk.STARTTIME BETWEEN params.fromDateDec25 AND params.toDateDec25)
                        OR
                        -- December 26, 2018 - Boxing Day - Provincial Statutory Holiday: Ontario
                        (
                                bk.STARTTIME BETWEEN params.fromDateDec26 AND params.toDateDec26
                                AND params.province = 'ON'
                        )
                        OR
                        -- January 1, 2019 - New Years Day - Canadian Statutory Holiday
                        (bk.STARTTIME BETWEEN params.fromDateJan AND params.toDateJan)
                        OR
                        -- February 18 2019 - Family Day - Provincial Statutory Holiday: Ontario, Alberta, British Columbia, Manitoba, Saskatchewan, Nova Scotia, New Brunswick, PEI
                        (
                                bk.STARTTIME BETWEEN params.fromDateFeb AND params.toDateFeb
                                AND params.province IN ('ON','AB','BC','MB','SK','NS','NB','PE')
                        )
                        OR
                        -- April 19, 2019 - Good Friday - Canadian Statutory Holiday
                        (bk.STARTTIME BETWEEN params.fromDateApr AND params.toDateApr)
                        OR
                        -- May 20, 2019 - Victoria Day - Provincial Statutory Holiday: Ontario, Alberta, British Columbia, Manitoba, Saskatchewan
                        (
                                bk.STARTTIME BETWEEN params.fromDateMay AND params.toDateMay
                                AND params.province IN ('ON','AB','BC','MB','SK')
                        )
                        OR
                        -- July 1, 2019 - Canada Day - Canadian Statutory Holiday
                        (bk.STARTTIME BETWEEN params.fromDateJul AND params.toDateJul)
                        OR
                        -- August 5, 2019 - Civic Holiday - Canadian Statutory Holiday
                        (bk.STARTTIME BETWEEN params.fromDateAug AND params.toDateAug)
                        OR
                        -- September 2, 2019 - Labour Day - Canadian Statutory Holiday
                        (bk.STARTTIME BETWEEN params.fromDateSep AND params.toDateSep)
                        OR
                        -- October 14, 2019 - Thanksgiving - Provincial Statutory Holiday: Ontario, Alberta, British Columbia, Manitoba, Saskatchewan
                        (
                                bk.STARTTIME BETWEEN params.fromDateOct AND params.toDateOct
                                AND params.province IN ('ON','AB','BC','MB','SK')
                        )
                        OR
                        -- November 11, 2019 - Remembrance Day - Provincial Statutory Holiday: Alberta, British Columbia, Manitoba, Saskatchewan, Nova Scotia, New Brunswick, Newfoundland, PEI
                        (
                                bk.STARTTIME BETWEEN params.fromDateNov AND params.toDateNov
                                AND params.province IN ('AB','BC','MB','SK','NS','NB','NL','PE')
                        )
                        OR
                        -- December 25, 2019 - Christmas Day - Canadian Statutory Holiday
                        (bk.STARTTIME BETWEEN params.fromDateDec25_2019 AND params.toDateDec25_2019)
                        OR
                        -- December 26, 2019 - Boxing Day - Provincial Statutory Holiday: Ontario 
                        (
                                bk.STARTTIME BETWEEN params.fromDateDec26_2019 AND params.toDateDec26_2019
                                AND params.province = 'ON'
                        )
                        OR
                        -- January 1, 2020 - New Years Day - Canadian Statutory Holiday
                        (bk.STARTTIME BETWEEN params.fromDateJan_2020 AND params.toDateJan_2020)
                )
AND bk.STARTTIME > params.cutDate
         ORDER BY bk.starttime
       
