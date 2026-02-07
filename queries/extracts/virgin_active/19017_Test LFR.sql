SELECT
    pid AS "Membership nbr",
    CLUB_NAME,
    MEMBER_START_DATE,
    -- MEMBERSHIP_NUMBER,
    MEMBER_NAME,
    STATUS,
    SUBSCRIPTION_NAME,
    -- MC_PID,
    MC_NAME,
    TOTAL_BOOKED + TOTAL_CANCELLED_INV + TOTAL_CANCELLED_OK + TOTAL_PARTICIPATION TOTAL_BOOKINGS,
    TOTAL_BOOKED AS "Total future bookings",
    TOTAL_PARTICIPATION AS "Total attended",
    TOTAL_CANCELLED_INV AS "Total no-show",
    TOTAL_CANCELLED_OK AS "Total cancelled",
    INDUCTION_BOOKED AS "Induction future bookings",
    INDUCTION_PARTICIPATION AS "Induction attended",
    INDUCTION_CANCELLED_INV AS "Induction no-show",
    INDUCTION_CANCELLED_OK AS "Induction cancelled",
    PT_INTRO_BOOKED AS "Get into PT future bookings",
    PT_INTRO_PARTICIPATION AS "Get into PT attended",
    PT_INTRO_CANCELLED_INV AS "Get into PT no-show",
    PT_INTRO_CANCELLED_OK AS "Get into PT cancelled" ,
    GRIPS_ABS_CORE_BOOOKED AS "GTG core future bookings",
    GRIPS_ABS_CORE_PARTICIPATING AS "GTG core attended",
    GRIPS_ABS_CORE_CANCELLED_INV AS "GTG core no-show",
    GRIPS_ABS_CORE_CANCELLED_OK AS "GTG core cancelled",
    GRIPS_CARDIO_BOOOKED AS "GTG cardio future bookings",
    GRIPS_CARDIO_PARTICIPATING AS "GTG cardio attended",
    GRIPS_CARDIO_CANCELLED_INV AS "GTG cardio no-show",
    GRIPS_CARDIO_CANCELLED_OK AS "GTG cardio cancelled",
    GRIPS_FUNC_BOOOKED AS "GTG func future bookings",
    GRIPS_FUNC_PARTICIPATING AS "GTG func attended",
    GRIPS_FUNC_CANCELLED_INV AS "GTG func no-show",
    GRIPS_FUNC_CANCELLED_OK AS "GTG func cancelled",
    GRIPS_GROUP_BOOOKED AS "GTG GroupEx future bookings",
    GRIPS_GROUP_PARTICIPATING AS "GTG GroupEx attended",
    GRIPS_GROUP_CANCELLED_INV AS "GTG GroupEx no-show",
    GRIPS_GROUP_CANCELLED_OK AS "GTG GroupEx cancelled",
    GRIPS_STRETCH_BOOOKED AS "GTG stretch future bookings",
    GRIPS_STRETCH_PARTICIPATING AS "GTG stretch attended",
    GRIPS_STRETCH_CANCELLED_INV AS "GTG stretch no-show",
    GRIPS_STRETCH_CANCELLED_OK AS "GTG stretch cancelled",
    GRIPS_WEIGHT_BOOOKED AS "GTG weights future bookings" ,
    GRIPS_WEIGHT_PARTICIPATING AS "GTG weights attended",
    GRIPS_WEIGHT_CANCELLED_INV AS "GTG weights no-show",
    GRIPS_WEIGHT_CANCELLED_OK AS "GTG weights cancelled",
    CLUB_WELCOME_BOOOKED AS "Club Welcome future bookings",
    CLUB_WELCOME_PARTICIPATING AS "Club Welcome attended",
    CLUB_WELCOME_CANCELLED_INV AS "Club Welcome no-show",
    CLUB_WELCOME_CANCELLED_OK AS "Club Welcome cancelled"
FROM
    (
        SELECT
            q1.*,
            act.NAME || ' - ' || par.STATE || ' - ' ||
            CASE
                WHEN par.CANCELATION_REASON IN ('NO_SHOW',
                                                'USER_CANCEL_LATE')
                THEN 'FAIL'
                ELSE 'OK'
            END combination
        FROM
            (
                SELECT
                    p.CENTER,
                    p.ID,
                    s.START_DATE,
                    c.ID CENTER_ID,
                    c.NAME CLUB_NAME,
                    p.LAST_ACTIVE_START_DATE MEMBER_START_DATE,
                    /* Specification rule 17 */
                    s.CENTER || 'ss' || s.ID MEMBERSHIP_NUMBER,
                    /* Specification rule 17 */
                    p.FULLNAME MEMBER_NAME,
                    p.CENTER || 'p' || p.ID pid,
                    /* Specification rule 17 */
                    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,
                    'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
                    prod.NAME SUBSCRIPTION_NAME ,
                    /* Specification rule 18 */
                    atts.TXTVALUE MC_PID,
                    mcp.FULLNAME MC_NAME,
                    /* Specification rule 15 do a total count on the different participation states */
                    SUM(
                        CASE
                            WHEN act.NAME IS NOT NULL
                                AND par.STATE = 'BOOKED'
                            THEN 1
                            ELSE 0
                        END) AS TOTAL_BOOKED,
                    SUM(
                        CASE
                            WHEN act.NAME IS NOT NULL
                                AND par.STATE = 'CANCELLED'
                                AND par.CANCELATION_REASON IN ('NO_SHOW',
                                                               'USER_CANCEL_LATE')
                            THEN 1
                            ELSE 0
                        END) AS TOTAL_CANCELLED_INV,
                    SUM(
                        CASE
                            WHEN act.NAME IS NOT NULL
                                AND par.STATE = 'CANCELLED'
                                AND par.CANCELATION_REASON NOT IN ('NO_SHOW',
                                                                   'USER_CANCEL_LATE')
                            THEN 1
                            ELSE 0
                        END) AS TOTAL_CANCELLED_OK,
                    SUM(
                        CASE
                            WHEN act.NAME IS NOT NULL
                                AND par.STATE = 'PARTICIPATION'
                            THEN 1
                            ELSE 0
                        END) AS TOTAL_PARTICIPATION
                FROM
                    SUBSCRIPTIONS s
                JOIN
                    PERSONS p
                ON
                    p.CENTER = s.OWNER_CENTER
                    AND p.ID = s.OWNER_ID
                JOIN
                    CENTERS c
                ON
                    c.id = p.CENTER
                    AND c.COUNTRY = 'GB'
                JOIN
                    PERSON_EXT_ATTRS atts
                ON
                    atts.PERSONCENTER = p.CENTER
                    AND atts.PERSONID = p.ID
                    AND atts.NAME = 'MC'
                LEFT JOIN
                    PERSONS mcp
                ON
                    mcp.CENTER || 'p' || mcp.ID = atts.TXTVALUE
                JOIN
                    PRODUCTS prod
                ON
                    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
                    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
                    /* has to have a primary product group */
                    /* Specification rule 11 */
                JOIN
                    PRODUCT_GROUP pg
                ON
                    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
                    /* Specification rule 13 left join */
                LEFT JOIN
                    PARTICIPATIONS par
                ON
                    par.PARTICIPANT_CENTER = p.CENTER
                    AND par.PARTICIPANT_ID = p.ID
                    /* Specification rule 13 left join */
                LEFT JOIN
                    BOOKINGS book
                ON
                    book.CENTER = par.BOOKING_CENTER
                    AND book.ID = par.BOOKING_ID
                    /* Specification rule 14 - only bookings starting from sub start and 30 days ahead in time */
                    AND book.STARTTIME BETWEEN exerpro.dateToLong(TO_CHAR(s.START_DATE,'YYYY-MM-DD') || ' 00:00')
                    AND exerpro.dateToLong(TO_CHAR(s.START_DATE + 31,'YYYY-MM-DD') || ' 00:00')-1
                    /* Specification rule 13 left join */
                LEFT JOIN
                    ACTIVITY act
                ON
                    act.ID = book.ACTIVITY
                    /* Specification rule 12 only include these activity names*/
                    AND act.NAME IN ('Induction',
                                     'PT Intro – 45 Minute Session',
                                     'Get to Grips with Abs/Core',
                                     'Get to Grips with Cardio',
                                     'Get to Grips with Functional Training',
                                     'Get to Grips with Group Exercise',
                                     'Get to Grips with Stretching & Self-Massage',
                                     'Get to Grips with Weight Training',
                                     'Club Welcome')
                WHERE
                    /* Get all subsciptions that has been created within the selected date range */
                    /* Specification rule 1, 4 */

                    /* Use the first active start date instead */
                    p.LAST_ACTIVE_START_DATE BETWEEN '2016-06-01' AND '2016-06-30'
                    /* If we look back in time we can only have ACTIVE or TEMP_ACTIVE subs */
                    AND s.STATE IN (2,4)
                    /* Only ACTIVE OR TEMP_INACTIVE */
                    /* Specification rule 2 */
                    AND p.STATUS IN (3,1)
                    /* Specification rule 5 */
                    AND s.CENTER IN (401)
                    /* Remove any that had another ACTIVE sub within 30 days from the latests creation date including
                    transfered */
                    /* Specification rule 6 */
                    /* We can skip this part now
                    AND NOT EXISTS
                    (
                    SELECT
                    1
                    FROM
                    PERSONS p2
                    JOIN
                    SUBSCRIPTIONS s2
                    ON
                    s2.OWNER_CENTER = p2.CENTER
                    AND s2.OWNER_ID = p2.ID
                    JOIN
                    STATE_CHANGE_LOG scl
                    ON
                    scl.CENTER = s2.CENTER
                    AND scl.ID = s2.ID
                    AND scl.ENTRY_TYPE = 2
                    AND scl.STATEID IN (2,4)
                    WHERE
                    p2.CURRENT_PERSON_CENTER = p.CENTER
                    AND p2.CURRENT_PERSON_ID = p.ID
                    AND s2.SUB_STATE NOT IN (8)
                    AND (
                    scl.BOOK_END_TIME IS NULL
                    OR (
                    scl.BOOK_END_TIME BETWEEN exerpro.dateToLong(TO_CHAR(s.START_DATE-30,'YYYY-MM-DD') || ' 00:00')
                    AND exerpro.dateToLong(TO_CHAR(s.START_DATE,'YYYY-MM-DD') || ' 00:00')-1 ))
                    AND (
                    s2.CENTER,s2.ID) NOT IN ((s.CENTER,
                    s.ID)) )
                    */
                    /* Filter out some product groups */
                    /* Specification rule 7, 8, 9, 10 */
                    AND pg.NAME NOT IN ('Mem Cat: Complimentary',
                                        'Mem Cat: Jnr PAYP',
                                        'Mem Cat: Junior DD',
                                        'Mem Cat: Junior Diamond')
                    /* Specification rule 3 */
                    AND pg.EXCLUDE_FROM_MEMBER_COUNT = 0
                GROUP BY
                    p.CENTER,
                    p.ID,
                    p.LAST_ACTIVE_START_DATE,
                    c.ID ,
                    atts.TXTVALUE,
                    c.NAME ,
                    s.START_DATE ,
                    s.CENTER || 'ss' || s.ID ,
                    p.FULLNAME ,
                    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,
                    'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') ,
                    prod.NAME ,
                    mcp.FULLNAME ) q1
            /* Rejoin all participations to be able to do a drill down per participation */
        LEFT JOIN
            PARTICIPATIONS par
        ON
            par.PARTICIPANT_CENTER = q1.center
            AND par.PARTICIPANT_ID = q1.id
        LEFT JOIN
            BOOKINGS book
        ON
            book.CENTER = par.BOOKING_CENTER
            AND book.ID = par.BOOKING_ID
            /* Specification rule 14 - only bookings starting from sub start and 30 days ahead in time */
            AND book.STARTTIME BETWEEN exerpro.dateToLong(TO_CHAR(q1.START_DATE,'YYYY-MM-DD') || ' 00:00')
            AND exerpro.dateToLong(TO_CHAR(q1.START_DATE + 31,'YYYY-MM-DD') || ' 00:00')-1
            /* We only wants some activities */
        LEFT JOIN
            ACTIVITY act
        ON
            act.ID = book.ACTIVITY
            /* Specification rule 12 only include these activity names*/
            AND act.NAME IN ('Induction',
                             'PT Intro – 45 Minute Session',
                             'Get to Grips with Abs/Core',
                             'Get to Grips with Cardio',
                             'Get to Grips with Functional Training',
                             'Get to Grips with Group Exercise',
                             'Get to Grips with Stretching & Self-Massage',
                             'Get to Grips with Weight Training',
                             'Club Welcome') )
    /* Specification rule 15 - drill down on each activity type */
    pivot ( COUNT(center) FOR combination IN ( 'Induction - BOOKED - OK' AS Induction_BOOKED,
                                              'Induction - PARTICIPATION - OK' AS Induction_PARTICIPATION,
                                              'Induction - CANCELLED - FAIL' AS Induction_CANCELLED_INV,
                                              'Induction - CANCELLED - OK' AS Induction_CANCELLED_OK,
                                              'PT Intro – 45 Minute Session - BOOKED - OK' AS PT_Intro_BOOKED,
                                              'PT Intro – 45 Minute Session - PARTICIPATION - OK' AS
                                              PT_Intro_PARTICIPATION,
                                              'PT Intro – 45 Minute Session - CANCELLED - FAIL' AS
                                              PT_Intro_CANCELLED_INV,
                                              'PT Intro – 45 Minute Session - CANCELLED - OK' AS PT_Intro_CANCELLED_OK,
                                              'Get to Grips with Abs/Core - BOOKED - OK' AS Grips_Abs_Core_BOOOKED,
                                              'Get to Grips with Abs/Core - PARTICIPATION - OK' AS
                                              Grips_Abs_Core_PARTICIPATING,
                                              'Get to Grips with Abs/Core - CANCELLED - FAIL' AS
                                              Grips_Abs_Core_CANCELLED_INV,
                                              'Get to Grips with Abs/Core - CANCELLED - OK' AS
                                              Grips_Abs_Core_CANCELLED_OK,
                                              'Get to Grips with Cardio - BOOKED - OK' AS Grips_Cardio_BOOOKED,
                                              'Get to Grips with Cardio - PARTICIPATION - OK' AS
                                              Grips_Cardio_PARTICIPATING,
                                              'Get to Grips with Cardio - CANCELLED - FAIL' AS
                                              Grips_Cardio_CANCELLED_INV,
                                              'Get to Grips with Cardio - CANCELLED - OK' AS Grips_Cardio_CANCELLED_OK,
                                              'Get to Grips with Functional Training - BOOKED - OK' AS
                                              Grips_Func_BOOOKED,
                                              'Get to Grips with Functional Training - PARTICIPATION - OK' AS
                                              Grips_Func_PARTICIPATING,
                                              'Get to Grips with Functional Training - CANCELLED - FAIL' AS
                                              Grips_Func_CANCELLED_INV,
                                              'Get to Grips with Functional Training - CANCELLED - OK' AS
                                              Grips_Func_CANCELLED_OK,
                                              'Get to Grips with Group Exercise - BOOKED - OK' AS Grips_Group_BOOOKED,
                                              'Get to Grips with Group Exercise - PARTICIPATION - OK' AS
                                              Grips_Group_PARTICIPATING,
                                              'Get to Grips with Group Exercise - CANCELLED - FAIL' AS
                                              Grips_Group_CANCELLED_INV,
                                              'Get to Grips with Group Exercise - CANCELLED - OK' AS
                                              Grips_Group_CANCELLED_OK,
                                              'Get to Grips with Stretching & Self-Massage - BOOKED - OK' AS
                                              Grips_Stretch_BOOOKED,
                                              'Get to Grips with Stretching & Self-Massage - PARTICIPATION - OK' AS
                                              Grips_Stretch_PARTICIPATING,
                                              'Get to Grips with Stretching & Self-Massage - CANCELLED - FAIL' AS
                                              Grips_Stretch_CANCELLED_INV,
                                              'Get to Grips with Stretching & Self-Massage - CANCELLED - OK' AS
                                              Grips_Stretch_CANCELLED_OK,
                                              'Get to Grips with Weight Training - BOOKED - OK' AS Grips_Weight_BOOOKED
                                              ,
                                              'Get to Grips with Weight Training - PARTICIPATION - OK' AS
                                              Grips_Weight_PARTICIPATING,
                                              'Get to Grips with Weight Training - CANCELLED - FAIL' AS
                                              Grips_Weight_CANCELLED_INV,
                                              'Get to Grips with Weight Training - CANCELLED - OK' AS
                                              Grips_Weight_CANCELLED_OK,
                                              'Club Welcome - BOOKED - OK' AS Club_Welcome_BOOOKED,
                                              'Club Welcome - PARTICIPATION - OK' AS Club_Welcome_PARTICIPATING,
                                              'Club Welcome - CANCELLED - FAIL' AS Club_Welcome_CANCELLED_INV,
                                              'Club Welcome - CANCELLED - OK' AS Club_Welcome_CANCELLED_OK ) )
ORDER BY
    MEMBERSHIP_NUMBER