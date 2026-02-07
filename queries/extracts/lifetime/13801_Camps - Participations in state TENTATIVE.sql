SELECT
        t1.owner_person_id,
        t1.owner_external_id,
        t1.participant_person_id,
        t1.participant_external_id,
        t1.participation_center_name,
        t1.participation_center_id,
        t1.participation_creation_time,
        t1.participation_creator,
        t1.participation_start_time,
        t1.participation_stop_time,
        t1.participation_state,
        t1.after_sale_process,
        t1.installment_plan_id,
        t1.booking_program_name,
        t1.booking_program_start_date,
        t1.booking_program_stop_date
FROM
(
        SELECT
                main_p.center || 'p' || main_p.id AS owner_person_id,
                main_p.external_id AS owner_external_id,
                p.center || 'p' || p.id AS participant_person_id,
                p.external_id AS participant_external_id,
                --b.name AS booking_name,
                /*(CASE a.activity_type
                        WHEN 11 THEN 'CAMP_PROGRAM'
                        ELSE 'CAMP_ELECTIVE'
                END) AS activity_type,*/
                c.name AS participation_center_name,
                part.center AS participation_center_id,
                longtoDateC(part.creation_time, part.center) AS participation_creation_time,
                creator.fullname AS participation_creator,
                longtodatec(part.start_time, part.center) AS participation_start_time,
                longtodatec(part.stop_time, part.center) AS participation_stop_time,
                part.state AS participation_state,
                part.after_sale_process,
                rp.installment_plan_id AS installment_plan_id,
                bp.name AS booking_program_name,
                bp.startdate AS booking_program_start_date,
                bp.stopdate AS booking_program_stop_date,
                rp.id,
                rank () OVER (PARTITION BY rp.id ORDER BY part.start_time) AS ranking
        FROM lifetime.participations part
        JOIN lifetime.bookings b ON part.booking_center = b.center AND part.booking_id = b.id
        JOIN lifetime.activity a ON b.activity = a.id
        JOIN lifetime.persons main_p ON part.owner_center = main_p.center AND part.owner_id = main_p.id
        JOIN lifetime.persons p ON p.center = part.participant_center AND p.id = part.participant_id
        JOIN lifetime.centers c ON part.center = c.id
        LEFT JOIN lifetime.persons creator ON creator.center = part.creation_by_center AND creator.id = part.creation_by_id
        LEFT JOIN lifetime.recurring_participations rp ON rp.id = part.recurring_participation_key
        LEFT JOIN lifetime.booking_programs bp ON rp.booking_program_id = bp.id
        WHERE
                part.state = 'TENTATIVE'
                AND a.activity_type IN (11)--,12)
) t1
WHERE
        t1.ranking = 1