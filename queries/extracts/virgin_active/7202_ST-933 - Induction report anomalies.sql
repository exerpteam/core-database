WITH
    q1 AS
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
            DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4, 'TRANSFERED', 5,'DUPLICATE'
            , 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
            prod.NAME SUBSCRIPTION_NAME ,
            /* Specification rule 18 */
            atts.TXTVALUE MC_PID,
            mcp.FULLNAME MC_NAME,
            ROW_NUMBER() OVER (PARTITION BY p.center, p.id ORDER BY s.START_DATE ASC) rn
            /* Specification rule 15 do a total count on the different participation states */
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
        WHERE
            --p.CENTER = 30 AND p.iD = 11230
            /* Get all subsciptions that has been created within the selected date range */
            /* Specification rule 1, 4 */
            /* Use the first active start date instead */
            --p.LAST_ACTIVE_START_DATE + 30 >= $$fromDate$$
            s.start_date BETWEEN $$fromDate$$ AND $$toDate$$
            --AND s.start_date >= p.LAST_ACTIVE_START_DATE
            /* If we look back in time we can only have ACTIVE or TEMP_ACTIVE subs */
            AND s.STATE IN (2,4,3)
            /* Only ACTIVE OR TEMP_INACTIVE */
            /* Specification rule 2 */
            AND p.STATUS IN (3,1)
            /* Specification rule 5 */
            AND s.CENTER IN ($$scopes$$)
            /* Filter out some product groups */
            /* Specification rule 7, 8, 9, 10 */
            AND pg.NAME NOT IN ('Mem Cat: Complimentary',
                                'Mem Cat: Jnr PAYP',
                                'Mem Cat: Junior DD',
                                'Mem Cat: Junior Diamond')
            /* Specification rule 3 */
            AND pg.EXCLUDE_FROM_MEMBER_COUNT = 0
            AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    subscriptions sp
                JOIN
                    persons pi
                ON
                    pi.CENTER = sp.OWNER_CENTER
                    AND pi.ID = sp.OWNER_ID
                WHERE
                    sp.END_DATE + 30 > s.start_date
                    AND sp.SUB_STATE not in (7,8)
                    AND pi.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
                    AND pi.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID )
    )
    ,
    q2 AS
    (
        SELECT
            q1.CENTER,
            q1.ID,
            q1.START_DATE,
            q1.CENTER_ID,
            q1.CLUB_NAME,
            q1.MEMBER_START_DATE,
            q1.MEMBERSHIP_NUMBER,
            q1.MEMBER_NAME,
            q1.pid,
            q1.status,
            q1.SUBSCRIPTION_NAME,
            q1.mc_pid,
            q1.mc_name,
            act.NAME,
            par.state,
            CASE
                WHEN par.CANCELATION_REASON IN ('NO_SHOW',
                                                'USER_CANCEL_LATE')
                THEN 'FAIL'
                ELSE 'OK'
            END CANCELATION_REASON_CAT
        FROM
            q1
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
            /* Specification rule 14 - only bookings starting from sub start and 30 days ahead in
            time */
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
                             'Get to Grips with Weight Training' )
        WHERE
            rn=1
    )
    ,
    q3 AS
    (
        SELECT
            q2.CENTER,
            q2.ID,
            q2.START_DATE,
            q2.CENTER_ID,
            q2.CLUB_NAME,
            q2.MEMBER_START_DATE,
            q2.MEMBERSHIP_NUMBER,
            q2.MEMBER_NAME,
            q2.pid,
            q2.status,
            q2.SUBSCRIPTION_NAME,
            q2.mc_pid,
            q2.mc_name,
            q2.NAME || ' - ' || q2.STATE || ' - ' || q2.CANCELATION_REASON_CAT combination
        FROM
            q2
        UNION ALL
        SELECT
            q2.CENTER,
            q2.ID,
            q2.START_DATE,
            q2.CENTER_ID,
            q2.CLUB_NAME,
            q2.MEMBER_START_DATE,
            q2.MEMBERSHIP_NUMBER,
            q2.MEMBER_NAME,
            q2.pid,
            q2.status,
            q2.SUBSCRIPTION_NAME,
            q2.mc_pid,
            q2.mc_name,
            CASE
                WHEN q2.NAME IS NOT NULL
                    AND q2.STATE = 'BOOKED'
                THEN 'TOTAL_BOOKED'
                WHEN q2.NAME IS NOT NULL
                    AND q2.STATE = 'CANCELLED'
                    AND q2.CANCELATION_REASON_CAT ='FAIL'
                THEN 'TOTAL_CANCELLED_INV'
                WHEN q2.NAME IS NOT NULL
                    AND q2.STATE = 'CANCELLED'
                    AND q2.CANCELATION_REASON_CAT ='OK'
                THEN 'TOTAL_CANCELLED_OK'
                WHEN q2.NAME IS NOT NULL
                    AND q2.STATE = 'PARTICIPATION'
                THEN 'TOTAL_PARTICIPATION'
                ELSE 'NULL'
            END combination
        FROM
            q2
    )
SELECT
    pid AS "Membership nbr",
    CLUB_NAME,
    TO_CHAR(MEMBER_START_DATE, 'YYYY-MM-DD') LAST_ACTIVE_START,
    TO_CHAR(START_DATE, 'YYYY-MM-DD') START_DATE,
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
    GRIPS_WEIGHT_CANCELLED_OK AS "GTG weights cancelled"
FROM
    q3 pivot ( COUNT(center) FOR combination IN ('TOTAL_BOOKED' AS TOTAL_BOOKED,
                                                 'TOTAL_CANCELLED_INV' AS TOTAL_CANCELLED_INV,
                                                 'TOTAL_CANCELLED_OK' AS TOTAL_CANCELLED_OK,
                                                 'TOTAL_PARTICIPATION' AS TOTAL_PARTICIPATION,
                                                 'Induction - BOOKED - OK' AS Induction_BOOKED,
                                                 'Induction - PARTICIPATION - OK' AS Induction_PARTICIPATION,
                                                 'Induction - CANCELLED - FAIL' AS Induction_CANCELLED_INV,
                                                 'Induction - CANCELLED - OK' AS Induction_CANCELLED_OK,
                                                 'PT Intro – 45 Minute Session - BOOKED - OK' AS PT_Intro_BOOKED,
                                                 'PT Intro – 45 Minute Session - PARTICIPATION - OK' AS
                                                 PT_Intro_PARTICIPATION,
                                                 'PT Intro – 45 Minute Session - CANCELLED - FAIL' AS
                                                 PT_Intro_CANCELLED_INV,
                                                 'PT Intro – 45 Minute Session - CANCELLED - OK' AS
                                                 PT_Intro_CANCELLED_OK,
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
                                                 'Get to Grips with Cardio - CANCELLED - OK' AS
                                                 Grips_Cardio_CANCELLED_OK,
                                                 'Get to Grips with Functional Training - BOOKED - OK' AS
                                                 Grips_Func_BOOOKED,
                                                 'Get to Grips with Functional Training - PARTICIPATION - OK' AS
                                                 Grips_Func_PARTICIPATING,
                                                 'Get to Grips with Functional Training - CANCELLED - FAIL' AS
                                                 Grips_Func_CANCELLED_INV,
                                                 'Get to Grips with Functional Training - CANCELLED - OK' AS
                                                 Grips_Func_CANCELLED_OK,
                                                 'Get to Grips with Group Exercise - BOOKED - OK' AS
                                                 Grips_Group_BOOOKED,
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
                                                 'Get to Grips with Weight Training - BOOKED - OK' AS
                                                 Grips_Weight_BOOOKED,
                                                 'Get to Grips with Weight Training - PARTICIPATION - OK' AS
                                                 Grips_Weight_PARTICIPATING,
                                                 'Get to Grips with Weight Training - CANCELLED - FAIL' AS
                                                 Grips_Weight_CANCELLED_INV,
                                                 'Get to Grips with Weight Training - CANCELLED - OK' AS
                                                 Grips_Weight_CANCELLED_OK ) )
ORDER BY
    MEMBERSHIP_NUMBER