-- The extract is extracted from Exerp on 2026-02-08
-- EC-156
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            datetolongTZ(TO_CHAR(to_date('2020-10-28','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI'),
            'Europe/Copenhagen') AS fromDateCorona,
            datetolongTZ(TO_CHAR(to_date('2022-01-01','yyyy-mm-dd'),'YYYY-MM-DD HH24:MI'),
            'Europe/Copenhagen')-1 AS toDateCorona
        FROM
            dual
    )
SELECT

p.PARTICIPANT_CENTER ||'p' ||p.PARTICIPANT_ID,
    bk.center                                                   AS BookingCenter,
    bk.id                                                       AS BookingId,
    bk.CLASS_CAPACITY AS CURRENT_CLASS_CAPACITY,
    TO_CHAR(longtodateC(bk.starttime, bk.center),'YYYY-MM-DD HH24:MI') AS startTime,
    TO_CHAR(longtodateC(bk.stoptime, bk.center),'YYYY-MM-DD HH24:MI')  AS stopTime,
    bk.name                                                            AS BookingName
--    act.name                                                           AS ActivityName
    --count(*)
FROM
    bookings bk
JOIN
    CENTERS c
ON
    c.ID = bk.CENTER
AND c.COUNTRY = 'DK' -- Only DK
JOIN
    PARTICIPATIONS p
ON
    bk.id = p.BOOKING_ID
AND bk.center = p.BOOKING_CENTER
CROSS JOIN
    params
JOIN
    activity act
ON
    bk.activity = act.id
WHERE
    bk.state != 'CANCELLED'
AND bk.STARTTIME BETWEEN params.fromDateCorona AND params.toDateCorona
AND (
        bk.CENTER < 400
    OR  bk.CENTER > 499) -- exclude UG
AND act.activity_type = 2

AND bk.NAME != 'Squash'
AND bk.CLASS_CAPACITY >=10
AND p.PARTICIPANT_CENTER ||'p' ||p.PARTICIPANT_ID IN ('101p181614',
                                                      '101p182436',
                                                      '112p23024',
                                                      '113p45751',
                                                      '114p108695',
                                                      '114p115704',
                                                      '117p126219',
                                                      '117p89147',
                                                      '118p135627',
                                                      '122p116295',
                                                      '123p11571',
                                                      '123p44358',
                                                      '124p123163',
                                                      '124p96965',
                                                      '131p132511',
                                                      '134p63805',
                                                      '136p13927',
                                                      '152p131293',
                                                      '152p170474',
                                                      '153p155217',
                                                      '155p137991',
                                                      '155p172410',
                                                      '155p172425',
                                                      '160p133864',
                                                      '161p56032',
                                                      '164p118229',
                                                      '166p81402',
                                                      '172p66603',
                                                      '191p121434',
                                                      '191p1747',
                                                      '191p52207',
                                                      '192p57038',
                                                      '200p134829',
                                                      '201p131242',
                                                      '201p49460',
                                                      '212p116407',
                                                      '215p14142',
                                                      '215p69201',
                                                      '216p101601',
                                                      '217p71426',
                                                      '221p105610',
                                                      '222p489',
                                                      '229p91016',
                                                      '239p90073',
                                                      '244p70602',
                                                      '246p43410',
                                                      '251p57843',
                                                      '262p25817',
                                                      '269p15206',
                                                      '269p28830',
                                                      '272p2637',
                                                      '277p1831',
                                                      '283p2552',
                                                      '601p103257',
                                                      '604p27808',
                                                      '604p87010',
                                                      '605p54645',
                                                      '617p81251')
ORDER BY
    1