-- The extract is extracted from Exerp on 2026-02-08
-- Tracking number of induction type bookings made for members within the first 30 days  of their membership. Basis of report is membership start date, NOT join date.
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
    TOTAL_BOOKED                                                                  AS
    "Total future bookings",
    TOTAL_PARTICIPATION          AS "Total attended",
    TOTAL_CANCELLED_INV          AS "Total no-show",
    TOTAL_CANCELLED_OK           AS "Total cancelled",
    INDUCTION_BOOKED             AS "Induction future bookings",
    INDUCTION_PARTICIPATION      AS "Induction attended",
    INDUCTION_CANCELLED_INV      AS "Induction no-show",
    INDUCTION_CANCELLED_OK       AS "Induction cancelled",
    PT_INTRO_BOOKED              AS "Get into PT future bookings",
    PT_INTRO_PARTICIPATION       AS "Get into PT attended",
    PT_INTRO_CANCELLED_INV       AS "Get into PT no-show",
    PT_INTRO_CANCELLED_OK        AS "Get into PT cancelled" ,
    GRIPS_ABS_CORE_BOOOKED       AS "GTG core future bookings",
    GRIPS_ABS_CORE_PARTICIPATING AS "GTG core attended",
    GRIPS_ABS_CORE_CANCELLED_INV AS "GTG core no-show",
    GRIPS_ABS_CORE_CANCELLED_OK  AS "GTG core cancelled",
    GRIPS_CARDIO_BOOOKED         AS "GTG cardio future bookings",
    GRIPS_CARDIO_PARTICIPATING   AS "GTG cardio attended",
    GRIPS_CARDIO_CANCELLED_INV   AS "GTG cardio no-show",
    GRIPS_CARDIO_CANCELLED_OK    AS "GTG cardio cancelled",
    GRIPS_FUNC_BOOOKED           AS "GTG func future bookings",
    GRIPS_FUNC_PARTICIPATING     AS "GTG func attended",
    GRIPS_FUNC_CANCELLED_INV     AS "GTG func no-show",
    GRIPS_FUNC_CANCELLED_OK      AS "GTG func cancelled",
    GRIPS_GROUP_BOOOKED          AS "GTG GroupEx future bookings",
    GRIPS_GROUP_PARTICIPATING    AS "GTG GroupEx attended",
    GRIPS_GROUP_CANCELLED_INV    AS "GTG GroupEx no-show",
    GRIPS_GROUP_CANCELLED_OK     AS "GTG GroupEx cancelled",
    GRIPS_STRETCH_BOOOKED        AS "GTG stretch future bookings",
    GRIPS_STRETCH_PARTICIPATING  AS "GTG stretch attended",
    GRIPS_STRETCH_CANCELLED_INV  AS "GTG stretch no-show",
    GRIPS_STRETCH_CANCELLED_OK   AS "GTG stretch cancelled",
    GRIPS_WEIGHT_BOOOKED         AS "GTG weights future bookings" ,
    GRIPS_WEIGHT_PARTICIPATING   AS "GTG weights attended",
    GRIPS_WEIGHT_CANCELLED_INV   AS "GTG weights no-show",
    GRIPS_WEIGHT_CANCELLED_OK    AS "GTG weights cancelled",
    CLUB_WELCOME_BOOOKED         AS "Club Welcome future bookings",
    CLUB_WELCOME_PARTICIPATING   AS "Club Welcome attended",
    CLUB_WELCOME_CANCELLED_INV   AS "Club Welcome no-show",
    CLUB_WELCOME_CANCELLED_OK    AS "Club Welcome cancelled"
FROM
    (
        SELECT
            pid,
            CLUB_NAME,
            MEMBER_START_DATE,
            -- MEMBERSHIP_NUMBER,
            MEMBER_NAME,
            STATUS,
            SUBSCRIPTION_NAME,
            -- MC_PID,
            MC_NAME,
            TOTAL_BOOKED,
            total_cancelled_inv,
            TOTAL_CANCELLED_OK,
            TOTAL_PARTICIPATION,
            MEMBERSHIP_NUMBER,
            CASE WHEN combination ='Induction - BOOKED - OK' THEN COUNT(center) end as Induction_BOOKED,
            CASE WHEN combination = 'Induction - PARTICIPATION - OK' THEN COUNT(center) end as Induction_PARTICIPATION,
            CASE WHEN combination = 'Induction - CANCELLED - FAIL' THEN COUNT(center) end as Induction_CANCELLED_INV,
            CASE WHEN combination = 'Induction - CANCELLED - OK' THEN COUNT(center) end as Induction_CANCELLED_OK,
            CASE WHEN combination = 'PT Intro \342\200\223 45 Minute Session - BOOKED - OK' THEN COUNT(center) end as PT_Intro_BOOKED,
            CASE WHEN combination = 'PT Intro \342\200\223 45 Minute Session - PARTICIPATION - OK' THEN COUNT(center) end as PT_Intro_PARTICIPATION,
            CASE WHEN combination = 'PT Intro \342\200\223 45 Minute Session - CANCELLED - FAIL' THEN COUNT(center) end as PT_Intro_CANCELLED_INV,
            CASE WHEN combination = 'PT Intro \342\200\223 45 Minute Session - CANCELLED - OK' THEN COUNT(center) end as PT_Intro_CANCELLED_OK,
            CASE WHEN combination = 'Get to Grips with Abs/Core - BOOKED - OK' THEN COUNT(center) end as Grips_Abs_Core_BOOOKED,
            CASE WHEN combination = 'Get to Grips with Abs/Core - PARTICIPATION - OK' THEN COUNT(center) end as Grips_Abs_Core_PARTICIPATING,
            CASE WHEN combination = 'Get to Grips with Abs/Core - CANCELLED - FAIL' THEN COUNT(center) end as Grips_Abs_Core_CANCELLED_INV,
            CASE WHEN combination = 'Get to Grips with Abs/Core - CANCELLED - OK' THEN COUNT(center) end as Grips_Abs_Core_CANCELLED_OK,
            CASE WHEN combination = 'Get to Grips with Cardio - BOOKED - OK' THEN COUNT(center) end as Grips_Cardio_BOOOKED,
            CASE WHEN combination = 'Get to Grips with Cardio - PARTICIPATION - OK' THEN COUNT(center) end as Grips_Cardio_PARTICIPATING,
            CASE WHEN combination = 'Get to Grips with Cardio - CANCELLED - FAIL' THEN COUNT(center) end as Grips_Cardio_CANCELLED_INV,
            CASE WHEN combination = 'Get to Grips with Cardio - CANCELLED - OK' THEN COUNT(center) end as Grips_Cardio_CANCELLED_OK,
            CASE WHEN combination = 'Get to Grips with Functional Training - BOOKED - OK' THEN COUNT(center) end as Grips_Func_BOOOKED,
            CASE WHEN combination = 'Get to Grips with Functional Training - PARTICIPATION - OK' THEN COUNT(center) end as Grips_Func_PARTICIPATING,
            CASE WHEN combination = 'Get to Grips with Functional Training - CANCELLED - FAIL' THEN COUNT(center) end as Grips_Func_CANCELLED_INV,
            CASE WHEN combination = 'Get to Grips with Functional Training - CANCELLED - OK' THEN COUNT(center) end as Grips_Func_CANCELLED_OK,
            CASE WHEN combination = 'Get to Grips with Group Exercise - BOOKED - OK' THEN COUNT(center) end as Grips_Group_BOOOKED,
            CASE WHEN combination = 'Get to Grips with Group Exercise - PARTICIPATION - OK' THEN COUNT(center) end as Grips_Group_PARTICIPATING,
            CASE WHEN combination = 'Get to Grips with Group Exercise - CANCELLED - FAIL' THEN COUNT(center) end as Grips_Group_CANCELLED_INV,
            CASE WHEN combination = 'Get to Grips with Group Exercise - CANCELLED - OK' THEN COUNT(center) end as Grips_Group_CANCELLED_OK,
            CASE WHEN combination = 'Get to Grips with Stretching & Self-Massage - BOOKED - OK' THEN COUNT(center) end as Grips_Stretch_BOOOKED,
            CASE WHEN combination = 'Get to Grips with Stretching & Self-Massage - PARTICIPATION - OK' THEN COUNT(center) end as Grips_Stretch_PARTICIPATING,
            CASE WHEN combination = 'Get to Grips with Stretching & Self-Massage - CANCELLED - FAIL' THEN COUNT(center) end as Grips_Stretch_CANCELLED_INV,
            CASE WHEN combination = 'Get to Grips with Stretching & Self-Massage - CANCELLED - OK' THEN COUNT(center) end as Grips_Stretch_CANCELLED_OK,
            CASE WHEN combination = 'Get to Grips with Weight Training - BOOKED - OK' THEN COUNT(center) end as Grips_Weight_BOOOKED,
            CASE WHEN combination = 'Get to Grips with Weight Training - PARTICIPATION - OK' THEN COUNT(center) end as Grips_Weight_PARTICIPATING,
            CASE WHEN combination = 'Get to Grips with Weight Training - CANCELLED - FAIL' THEN COUNT(center) end as Grips_Weight_CANCELLED_INV,
            CASE WHEN combination = 'Get to Grips with Weight Training - CANCELLED - OK' THEN COUNT(center) end as Grips_Weight_CANCELLED_OK,
            CASE WHEN combination = 'Club Welcome - BOOKED - OK' THEN COUNT(center) end as Club_Welcome_BOOOKED,
            CASE WHEN combination = 'Club Welcome - PARTICIPATION - OK' THEN COUNT(center) end as Club_Welcome_PARTICIPATING,
            CASE WHEN combination = 'Club Welcome - CANCELLED - FAIL' THEN COUNT(center) end as Club_Welcome_CANCELLED_INV,
            CASE WHEN combination = 'Club Welcome - CANCELLED - OK' THEN COUNT(center) end as Club_Welcome_CANCELLED_OK
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
                            c.ID                     CENTER_ID,
                            c.NAME                   CLUB_NAME,
                            p.LAST_ACTIVE_START_DATE MEMBER_START_DATE,
                            /* Specification rule 17 */
                            s.CENTER || 'ss' || s.ID MEMBERSHIP_NUMBER,
                            /* Specification rule 17 */
                            p.FULLNAME              MEMBER_NAME,
                            p.CENTER || 'p' || p.ID pid,
                            /* Specification rule 17 */
                            CASE p.STATUS
                                WHEN 0
                                THEN 'LEAD'
                                WHEN 1
                                THEN 'ACTIVE'
                                WHEN 2
                                THEN 'INACTIVE'
                                WHEN 3
                                THEN 'TEMPORARYINACTIVE'
                                WHEN 4
                                THEN 'TRANSFERED'
                                WHEN 5
                                THEN 'DUPLICATE'
                                WHEN 6
                                THEN 'PROSPECT'
                                WHEN 7
                                THEN 'DELETED'
                                WHEN 8
                                THEN 'ANONYMIZED'
                                WHEN 9
                                THEN 'CONTACT'
                                ELSE 'UNKNOWN'
                            END       AS STATUS,
                            prod.NAME    SUBSCRIPTION_NAME ,
                            /* Specification rule 18 */
                            atts.TXTVALUE MC_PID,
                            mcp.FULLNAME  MC_NAME,
                            /* Specification rule 15 do a total count on the different
                            participation states
                            */
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
                            /* Specification rule 14 - only bookings starting from sub start and 30
                            days
                            ahead in time */
                        AND book.STARTTIME BETWEEN dateToLong(TO_CHAR(s.START_DATE,'YYYY-MM-DD') ||
                            ' 00:00')
                        AND dateToLong(TO_CHAR(s.START_DATE + 31,'YYYY-MM-DD') || ' 00:00')-1
                            /* Specification rule 13 left join */
                        LEFT JOIN
                            ACTIVITY act
                        ON
                            act.ID = book.ACTIVITY
                            /* Specification rule 12 only include these activity names*/
                        AND act.NAME IN ('Induction',
                                         'PT Intro \342\200\223 45 Minute Session',
                                         'Get to Grips with Abs/Core',
                                         'Get to Grips with Cardio',
                                         'Get to Grips with Functional Training',
                                         'Get to Grips with Group Exercise',
                                         'Get to Grips with Stretching & Self-Massage',
                                         'Get to Grips with Weight Training',
                                         'Club Welcome')
                        WHERE
                            /* Get all subsciptions that has been created within the selected date
                            range */
                            /* Specification rule 1, 4 */
                            /* Use the first active start date instead */
                            p.LAST_ACTIVE_START_DATE BETWEEN $$fromDate$$ AND $$toDate$$
                            /* If we look back in time we can only have ACTIVE or TEMP_ACTIVE subs
                            */
                        AND s.STATE IN (2,4)
                            /* Only ACTIVE OR TEMP_INACTIVE */
                            /* Specification rule 2 */
                        AND p.STATUS IN (3,1)
                            /* Specification rule 5 */
                        AND s.CENTER IN ($$scopes$$)
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
                            CASE p.STATUS
                                WHEN 0
                                THEN 'LEAD'
                                WHEN 1
                                THEN 'ACTIVE'
                                WHEN 2
                                THEN 'INACTIVE'
                                WHEN 3
                                THEN 'TEMPORARYINACTIVE'
                                WHEN 4
                                THEN 'TRANSFERED'
                                WHEN 5
                                THEN 'DUPLICATE'
                                WHEN 6
                                THEN 'PROSPECT'
                                WHEN 7
                                THEN 'DELETED'
                                WHEN 8
                                THEN 'ANONYMIZED'
                                WHEN 9
                                THEN 'CONTACT'
                                ELSE 'UNKNOWN'
                            END ,
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
                    /* Specification rule 14 - only bookings starting from sub start and 30 days
                    ahead in
                    time */
                AND book.STARTTIME BETWEEN dateToLong(TO_CHAR(q1.START_DATE,'YYYY-MM-DD') ||
                    ' 00:00')
                AND dateToLong(TO_CHAR(q1.START_DATE + 31,'YYYY-MM-DD') || ' 00:00')-1
                    /* We only wants some activities */
                LEFT JOIN
                    ACTIVITY act
                ON
                    act.ID = book.ACTIVITY
                    /* Specification rule 12 only include these activity names*/
                AND act.NAME IN ('Induction',
                                 'PT Intro \342\200\223 45 Minute Session',
                                 'Get to Grips with Abs/Core',
                                 'Get to Grips with Cardio',
                                 'Get to Grips with Functional Training',
                                 'Get to Grips with Group Exercise',
                                 'Get to Grips with Stretching & Self-Massage',
                                 'Get to Grips with Weight Training',
                                 'Club Welcome') )t
        GROUP BY
            pid,
            CLUB_NAME,
            MEMBER_START_DATE,
            -- MEMBERSHIP_NUMBER,
            MEMBER_NAME,
            STATUS,
            SUBSCRIPTION_NAME,
            -- MC_PID,
            MC_NAME,
            combination,
            TOTAL_BOOKED,
            total_cancelled_inv,
            TOTAL_CANCELLED_OK,
            TOTAL_PARTICIPATION,
            MEMBERSHIP_NUMBER )t
    /* Specification rule 15 - drill down on each activity type */
ORDER BY
    MEMBERSHIP_NUMBER