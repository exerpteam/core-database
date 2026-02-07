SELECT
    pid,
    CLUB_NAME,
    MEMBER_START_DATE,
    MEMBERSHIP_NUMBER,
    MEMBER_NAME,
    STATUS,
    SUBSCRIPTION_NAME,
    MC_PID,
    MC_NAME,
    TOTAL_BOOKED + TOTAL_CANCELLED_INV +  TOTAL_CANCELLED_OK +     
    TOTAL_PARTICIPATION TOTALS_SUMMED,
    TOTAL_BOOKED,
    TOTAL_CANCELLED_INV,
    TOTAL_CANCELLED_OK,    
    TOTAL_PARTICIPATION,
    INDUCTION_BOOKED,
    INDUCTION_PARTICIPATION,
    INDUCTION_CANCELLED_INV,
    INDUCTION_CANCELLED_OK,
    PT_INTRO_BOOKED,
    PT_INTRO_PARTICIPATION,
    PT_INTRO_CANCELLED_INV,
    PT_INTRO_CANCELLED_OK ,
    GRIPS_ABS_CORE_BOOOKED,
    GRIPS_ABS_CORE_PARTICIPATING,
    GRIPS_ABS_CORE_CANCELLED_INV,
    GRIPS_ABS_CORE_CANCELLED_OK,
    GRIPS_CARDIO_BOOOKED,
    GRIPS_CARDIO_PARTICIPATING,
    GRIPS_CARDIO_CANCELLED_INV,
    GRIPS_CARDIO_CANCELLED_OK,
    GRIPS_FUNC_BOOOKED,
    GRIPS_FUNC_PARTICIPATING,
    GRIPS_FUNC_CANCELLED_INV,
    GRIPS_FUNC_CANCELLED_OK,
    GRIPS_GROUP_BOOOKED,
    GRIPS_GROUP_PARTICIPATING,
    GRIPS_GROUP_CANCELLED_INV,
    GRIPS_GROUP_CANCELLED_OK,
    GRIPS_STRETCH_BOOOKED,
    GRIPS_STRETCH_PARTICIPATING,
    GRIPS_STRETCH_CANCELLED_INV,
    GRIPS_STRETCH_CANCELLED_OK,
    GRIPS_WEIGHT_BOOOKED,
    GRIPS_WEIGHT_PARTICIPATING,
    GRIPS_WEIGHT_CANCELLED_INV,
    GRIPS_WEIGHT_CANCELLED_OK 
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
                    c.ID         CENTER_ID,
                    c.NAME       CLUB_NAME,
                    s.START_DATE MEMBER_START_DATE,
                    /* Specification rule 17 */
                    s.CENTER || 'ss' || s.ID MEMBERSHIP_NUMBER,
                    /* Specification rule 17 */
                    p.FULLNAME              MEMBER_NAME,
                    p.CENTER || 'p' || p.ID pid,
                    /* Specification rule 17 */
                    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
                    prod.NAME                                                                                                                                                                          SUBSCRIPTION_NAME ,
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
                                AND par.STATE = 'CANCELLED' and par.CANCELATION_REASON IN ('NO_SHOW',
                                                'USER_CANCEL_LATE')
                            THEN 1
                            ELSE 0
                        END) AS TOTAL_CANCELLED_INV,
                    SUM(
                        CASE
                            WHEN act.NAME IS NOT NULL
                                AND par.STATE = 'CANCELLED' and par.CANCELATION_REASON NOT IN ('NO_SHOW',
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
                join PERSONS mcp on mcp.CENTER || 'p' || mcp.ID = atts.TXTVALUE   
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
                                     'Get to Grips with Weight Training')
                WHERE
                    /* Get all subsciptions that has been created within the selected date range */
                    /* Specification rule 1, 4 */
                    s.START_DATE BETWEEN $$fromDate$$ AND $$toDate$$
                    /* Only ACTIVE OR TEMP_INACTIVE */
                    /* Specification rule 2 */
                    AND p.STATUS IN (3,1)
                    /* Specification rule 5 */
                    AND s.CENTER IN ($$scopes$$)
                    /* Remove any that had another ACTIVE sub within 30 days from the latests creation date including transfered */
                    /* Specification rule 6 */
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
                            /* Pick all state changes for ACTIVE and FROZEN subs */
                        JOIN
                            STATE_CHANGE_LOG scl
                        ON
                            scl.CENTER = s2.CENTER
                            AND scl.ID = s2.ID
                            AND scl.ENTRY_TYPE = 2
                            AND scl.STATEID IN (2,4)
                        WHERE
                            /* Make sure we also get transferred persons */
                            p2.CURRENT_PERSON_CENTER = p.CENTER
                            AND p2.CURRENT_PERSON_ID = p.ID
                            /* Exclude cancellations */
                            AND s2.SUB_STATE NOT IN (8)
                            /* Check if we have an ACTIVE/FROZEN state change log 30 days before the new sub was created and sysdate */
                            AND (
                                scl.BOOK_END_TIME IS NULL
                                OR (
                                    scl.BOOK_END_TIME BETWEEN exerpro.dateToLong(TO_CHAR(s.START_DATE-30,'YYYY-MM-DD') || ' 00:00')
                                    AND exerpro.dateToLong(TO_CHAR(s.START_DATE,'YYYY-MM-DD') || ' 00:00')-1 ))
                            /* Remove the sub we are looking at */
                            AND (
                                s2.CENTER,s2.ID) NOT IN ((s.CENTER,
                                                          s.ID)) )
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
                    s.START_DATE,
                    c.ID ,
					atts.TXTVALUE,
                    c.NAME ,
                    s.START_DATE ,
                    s.CENTER || 'ss' || s.ID ,
                    p.FULLNAME ,
                    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') ,
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
                             'Get to Grips with Weight Training' ) )
    /* Specification rule 15 - drill down on each activity type */
    pivot ( COUNT(center) FOR combination IN ( 'Induction - BOOKED - OK'                                         AS Induction_BOOKED,
                                              'Induction - PARTICIPATION - OK'                                     AS Induction_PARTICIPATION,
                                              'Induction - CANCELLED - FAIL'                                     AS Induction_CANCELLED_INV,
                                              'Induction - CANCELLED - OK'                                       AS Induction_CANCELLED_OK,
                                              'PT Intro – 45 Minute Session - BOOKED - OK'                       AS PT_Intro_BOOKED,
                                              'PT Intro – 45 Minute Session - PARTICIPATION - OK'                AS PT_Intro_PARTICIPATION,
                                              'PT Intro – 45 Minute Session - CANCELLED - FAIL'                  AS PT_Intro_CANCELLED_INV,
                                              'PT Intro – 45 Minute Session - CANCELLED - OK'                    AS PT_Intro_CANCELLED_OK,
                                              'Get to Grips with Abs/Core - BOOKED - OK'                         AS Grips_Abs_Core_BOOOKED,
                                              'Get to Grips with Abs/Core - PARTICIPATION - OK'                  AS Grips_Abs_Core_PARTICIPATING,
                                              'Get to Grips with Abs/Core - CANCELLED - FAIL'                    AS Grips_Abs_Core_CANCELLED_INV,
                                              'Get to Grips with Abs/Core - CANCELLED - OK'                      AS Grips_Abs_Core_CANCELLED_OK,
                                              'Get to Grips with Cardio - BOOKED - OK'                           AS Grips_Cardio_BOOOKED,
                                              'Get to Grips with Cardio - PARTICIPATION - OK'                    AS Grips_Cardio_PARTICIPATING,
                                              'Get to Grips with Cardio - CANCELLED - FAIL'                      AS Grips_Cardio_CANCELLED_INV,
                                              'Get to Grips with Cardio - CANCELLED - OK'                        AS Grips_Cardio_CANCELLED_OK,
                                              'Get to Grips with Functional Training - BOOKED - OK'              AS Grips_Func_BOOOKED,
                                              'Get to Grips with Functional Training - PARTICIPATION - OK'       AS Grips_Func_PARTICIPATING,
                                              'Get to Grips with Functional Training - CANCELLED - FAIL'         AS Grips_Func_CANCELLED_INV,
                                              'Get to Grips with Functional Training - CANCELLED - OK'           AS Grips_Func_CANCELLED_OK,
                                              'Get to Grips with Group Exercise - BOOKED - OK'                   AS Grips_Group_BOOOKED,
                                              'Get to Grips with Group Exercise - PARTICIPATION - OK'            AS Grips_Group_PARTICIPATING,
                                              'Get to Grips with Group Exercise - CANCELLED - FAIL'              AS Grips_Group_CANCELLED_INV,
                                              'Get to Grips with Group Exercise - CANCELLED - OK'                AS Grips_Group_CANCELLED_OK,
                                              'Get to Grips with Stretching & Self-Massage - BOOKED - OK'        AS Grips_Stretch_BOOOKED,
                                              'Get to Grips with Stretching & Self-Massage - PARTICIPATION - OK' AS Grips_Stretch_PARTICIPATING,
                                              'Get to Grips with Stretching & Self-Massage - CANCELLED - FAIL'   AS Grips_Stretch_CANCELLED_INV,
                                              'Get to Grips with Stretching & Self-Massage - CANCELLED - OK'     AS Grips_Stretch_CANCELLED_OK,
                                              'Get to Grips with Weight Training - BOOKED - OK'                  AS Grips_Weight_BOOOKED,
                                              'Get to Grips with Weight Training - PARTICIPATION - OK'           AS Grips_Weight_PARTICIPATING,
                                              'Get to Grips with Weight Training - CANCELLED - FAIL'             AS Grips_Weight_CANCELLED_INV,
                                              'Get to Grips with Weight Training - CANCELLED - OK'               AS Grips_Weight_CANCELLED_OK ) )


ORDER BY
    MEMBERSHIP_NUMBER