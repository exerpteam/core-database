  SELECT
             b.center ||'bk'||b.id AS COKING_ID,
             b.CLASS_CAPACITY,
             9                       AS NEW_CLASS_CAPACITY,
             params.current_datetime AS NEW_LAST_MODIFIED,
             b.name,
             longtodatetz(b.STARTTIME, c.TIME_ZONE) AS START_DATETIME,
             (
                 SELECT
                     COUNT(*)
                 FROM
                     participations par
                 WHERE
                     par.BOOKING_CENTER = b.center
                 AND par.BOOKING_ID = b.id
                 AND par.STATE NOT IN ('CANCELLED')) AS current_members,
             b.state
         FROM
             BOOKINGS b
         JOIN
             ACTIVITY a
         ON
             b.ACTIVITY = a.id
         JOIN
             ACTIVITY_GROUP ag
         ON
             ag.id = a.ACTIVITY_GROUP_ID
         JOIN
             (
                 SELECT
                     /*+ materialize */
                     c.ID                                                  AS CENTER,
                     dateToLongTZ(getcentertime(c.id), co.DEFAULTTIMEZONE) AS current_datetime
                 FROM
                     CENTERS c
                 JOIN
                     COUNTRIES co
                 ON
                     c.COUNTRY = co.ID) params
         ON
             params.center = b.center
         JOIN
             centers c
         ON
             c.id = b.center
         WHERE
             ag.NAME IN ('Aerobics',
                         'Bootcamp',
                         'Build''n Burn',
                         'Cycling',
                         'External',
                         'HiYoga',
                         'IMMERSIVE FITNESS',
                         'Job & Velfærd',
                         'Kids',
                         'Live Stream',
                         'Lukket hold',
                         'Martial Arts',
                         'Outdoors',
                         'Personal Trainer (Base)',
                         'Prformance',
                         'Priority classes' ,
                         'Run Club',
                         'Running',
                         'Swimming',
                         'Virtuaali',
                         'Working hours PT (Base)' )
         AND b.name NOT IN ('Prformance™ Strength',
                            'Prformance™ Mobility',
                            'Prformance™ Hi-Intensity',
                            'Build''n Burn',
                            'Burn (Build''n Burn)',
                            'Build (Build''n Burn)',
                            'Prformance™ Gymnastics' ,
                            'Build''n Burn Xpress',
                            'Prformance™ Olympic Lifting')
         AND b.CLASS_CAPACITY > 9
         AND b.STARTTIME >= params.current_datetime
         AND c.COUNTRY = 'FI'
         AND b.state IN ('ACTIVE',
                         'PLANNED')
