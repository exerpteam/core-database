-- The extract is extracted from Exerp on 2026-02-08
-- Class Participation Detail Report
WITH
params AS
(
	SELECT
		ID   AS CENTERID,
		NAME AS CENTERNAME,
		CAST(datetolongc(to_char(to_date($$FROM_DATE$$,'YYYY-MM-DD HH24:MI'),'YYYY-MM-DD HH24:MI'), c.id) AS BIGINT) AS FROM_DATE,
		CAST(datetolongc(to_char(to_date($$TO_DATE$$,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI'), c.id) AS BIGINT)+24*3600*1000-1 AS  TO_DATE
	FROM
		CENTERS C
	WHERE id IN ($$scope$$)
)
    ,
    j_entries AS materialized
    (
        SELECT
            rank() over (partition BY p.current_person_center, p.current_person_id, je.name
            ORDER BY je.creation_time DESC) AS rnk,
            p.current_person_center,
            p.current_person_id,
            je.person_center,
            je.person_id,
            je.creation_time,
            je.expiration_date,
            je.name
        FROM
            journalentries je
        JOIN
            persons p
        ON
            p.center = je.person_center
        AND p.id = je.person_id
        WHERE
            je.name IN ('Immunization or Exemption Form',
                        'Health History Form',
                        'Rockwall Waiver',
                        'Field Trip Permission',
                        'Swim Test')
        AND je.state = 'ACTIVE'
    )
SELECT
    CENTERNAME AS center,
    booking,
    COALESCE(ap1,'') ap1,
    COALESCE(ap2,'') ap2,
    COALESCE(ap3,'') ap3,
    COALESCE(ec1,'') ec1,
    COALESCE(ec2,'') ec2,
    par1 || par2  AS parents,
    COALESCE(wl,'')  wl,
    starttime,
    centerid,
    centername,
    external_id                       AS external,
    COALESCE(fullname,'')             AS fullname,
    COALESCE(immunization_current,'') AS ic,
    COALESCE(participation_agr || swim_test_form || doc_field_trip || health_history_form ||
    rock_wall_form ,'') AS docs,
    COALESCE(insect_bite_allergy || bee_sting_allergy || seasonal_allergy || medication_allergy ||
    food_allergy || sun_screen_allergy || insect_rep_allergy || other_allergy,'') AS allergy,
    COALESCE(past_med_treatment || prep_medication || non_prepscripion_medicine ||
    will_carry_inhaler || will_not_carry_inhaler || special_diet ,'') AS med
FROM
    (
        SELECT
            b.name                                                      AS booking,
            COALESCE(ap1.txtvalue,'')||'  '||COALESCE(cap1.txtvalue,'') AS AP1,
            COALESCE(ap2.txtvalue,'')||'  '||COALESCE(cap2.txtvalue,'') AS AP2,
            COALESCE(ap3.txtvalue,'')||'  '||COALESCE(cap3.txtvalue,'') AS AP3,
            COALESCE(ec1.txtvalue,'')||'  '||COALESCE(cec1.txtvalue,'')||'  '||COALESCE
            (ec1r.txtvalue,'') AS EC1,
            COALESCE(ec2.txtvalue,'')||'  '||COALESCE(cec2.txtvalue,'')||'  '||COALESCE
            (ec2r.txtvalue,'')                                              AS EC2,
            CASE WHEN parent1.txtvalue IS NULL AND parent1cell.txtvalue IS NULL THEN ''
                 ELSE COALESCE(parent1.txtvalue, '') ||' | '||COALESCE(parent1cell.txtvalue,'') || CHR(10)  
            END AS par1,
            CASE WHEN parent2.txtvalue IS NULL AND parent2cell.txtvalue IS NULL THEN ''
                 ELSE COALESCE(parent2.txtvalue, '') ||' | '||COALESCE(parent2cell.txtvalue,'') || CHR(10)  
            END AS par2,              

            TO_CHAR(longtodateC(b.starttime,b.center),'mm/dd/yyyy HH24:MI') AS starttime,
            CENTERID,
            CENTERNAME,
            cp.external_id,
            CASE
                WHEN PA.ON_WAITING_LIST
                THEN 'Yes'
                ELSE 'No'
            END AS wl,
            CASE
                WHEN LENGTH(p.fullname) > 16
                THEN substring(p.fullname,1,16) ||'..'
                ELSE p.fullname
            END AS fullname,
            CASE
                WHEN immun.name IS NOT NULL
                THEN 'Yes'
                ELSE ''
            END AS immunization_current,
            CASE
                WHEN qa.status = 'COMPLETED'
                THEN ' Participation Agreement            ' || TO_CHAR(longtodatec(qa.log_time,
                    qa.center),'mm/dd/yyyy') || '                       ' || TO_CHAR
                    (qa.expiration_date,'mm/dd/yyyy') || CHR(10)
                ELSE ''
            END participation_agr,
            ---
            CASE
                WHEN doc_field_trip.name IS NOT NULL
                THEN ' Field Trip Permission                 ' || TO_CHAR(longtodatec
                    (doc_field_trip.creation_time,doc_field_trip.person_center),'mm/dd/yyyy') ||
                    '                       ' || TO_CHAR(doc_field_trip.expiration_date,
                    'mm/dd/yyyy') || CHR(10)
                ELSE ''
            END doc_field_trip,
            ---
            CASE
                WHEN health_history_form.name IS NOT NULL
                THEN ' Health History Form                   ' || TO_CHAR(longtodatec
                    (health_history_form.creation_time,health_history_form.person_center),
                    'mm/dd/yyyy') || '                       ' || TO_CHAR
                    (health_history_form.expiration_date,'mm/dd/yyyy') || CHR(10)
                ELSE ''
            END health_history_form,
            ---
            CASE
                WHEN doc_swim.name IS NOT NULL
                THEN ' Swim Test                                  ' || TO_CHAR(longtodatec
                    (doc_swim.creation_time,doc_swim.person_center),'mm/dd/yyyy') ||
                    '                       ' || TO_CHAR(doc_swim.expiration_date,'mm/dd/yyyy') ||
                    CHR(10)
                ELSE ''
            END swim_test_form,
            ---
            CASE
                WHEN rock_wall.name IS NOT NULL
                THEN ' Climbing Waiver                         ' || TO_CHAR(longtodatec
                    (rock_wall.creation_time,rock_wall.person_center),'mm/dd/yyyy') ||
                    '                       ' || TO_CHAR(rock_wall.expiration_date,'mm/dd/yyyy') ||
                    CHR(10)
                ELSE ''
            END rock_wall_form,
            -- Allergi
            CASE
                WHEN insect_bite.txtvalue IS NOT NULL
                THEN 'Insect Bite: ' || insect_bite.txtvalue || CHR(10)
                ELSE ''
            END AS insect_bite_allergy,
            CASE
                WHEN bee_sting.txtvalue IS NOT NULL
                THEN 'Bee Sting: ' || bee_sting.txtvalue || CHR(10)
                ELSE ''
            END AS bee_sting_allergy,
            CASE
                WHEN seasonal.txtvalue IS NOT NULL
                THEN 'Seasonal Allergy: ' || seasonal.txtvalue || CHR(10)
                ELSE ''
            END AS seasonal_allergy,
            CASE
                WHEN medication.txtvalue IS NOT NULL
                THEN 'Medication Allergy: ' || medication.txtvalue || CHR(10)
                ELSE ''
            END AS medication_allergy,
            CASE
                WHEN food_allergy.txtvalue IS NOT NULL
                THEN 'Food Allergy: ' || food_allergy.txtvalue || CHR(10)
                ELSE ''
            END AS food_allergy,
            CASE
                WHEN sun_screen.txtvalue IS NOT NULL
                THEN 'Sun Screen: ' || sun_screen.txtvalue || CHR(10)
                ELSE ''
            END AS sun_screen_allergy,
            CASE
                WHEN insect_rep.txtvalue IS NOT NULL
                THEN 'Insect Repellant: ' || insect_rep.txtvalue || CHR(10)
                ELSE ''
            END AS insect_rep_allergy,
            CASE
                WHEN other_allergy.txtvalue IS NOT NULL
                THEN 'Other Allergy: ' || other_allergy.txtvalue || CHR(10)
                ELSE ''
            END AS other_allergy,
            -- Medical info
            CASE
                WHEN past_med_treatment.txtvalue IS NOT NULL
                THEN 'Injury and Medical Treatment:' || past_med_treatment.txtvalue || CHR(10)
                ELSE ''
            END AS past_med_treatment,
            CASE
                WHEN prep_medication.txtvalue IS NOT NULL
                THEN 'Prescription Medication:' || prep_medication.txtvalue || CHR(10)
                ELSE ''
            END AS prep_medication,
            CASE
                WHEN non_prepscripion_medicine.txtvalue IS NOT NULL
                THEN 'Non-prep. med.:' || non_prepscripion_medicine.txtvalue || CHR(10)
                ELSE ''
            END AS non_prepscripion_medicine,
            CASE
                WHEN will_carry_inhaler.txtvalue IS NOT NULL
                THEN 'Will carry inhaler:' || will_carry_inhaler.txtvalue || CHR(10)
                ELSE ''
            END AS will_carry_inhaler,
            CASE
                WHEN will_not_carry_inhaler.txtvalue IS NOT NULL
                THEN 'Will not carry inhaler:' || will_not_carry_inhaler.txtvalue || CHR(10)
                ELSE ''
            END AS will_not_carry_inhaler,
            CASE
                WHEN special_diet.txtvalue IS NOT NULL
                THEN 'Special Diet:' || special_diet.txtvalue || CHR(10)
                ELSE ''
            END AS special_diet,
            p.lastname,
            p.firstname
        FROM
            params
        JOIN
            bookings b
        ON
            b.center = params.centerid
        AND B.state !='CANCELLED'
        AND b.starttime BETWEEN params.from_date AND params.to_date
            --bp.startdate BETWEEN params.fromdate AND params.todate
        JOIN
            activity a
        ON
            b.activity = a.id
        AND a.activity_type = 2 -- class
        JOIN
            participations pa
        ON
            b.center = pa.booking_center
        AND b.id = pa.booking_id
        AND pa.state !='CANCELLED'
        JOIN
            persons p
        ON
            pa.participant_center=p.center
        AND pa.participant_id=p.id
        JOIN
            persons cp
        ON
            cp.center = p.current_person_center
        AND cp.id = p.current_person_id
        LEFT JOIN
            (
                SELECT
                    rank() over (partition BY p.current_person_center, p.current_person_id ORDER BY
                    qat.log_time DESC) AS rnk ,
                    p.current_person_center,
                    p.current_person_id,
                    p.center,
                    p.id,
                    qat.status,
                    qat.expiration_date,
                    qat.log_time,
                    qat.questionnaire_campaign_id
                FROM
                    questionnaire_campaigns qc_pa_agreement
                LEFT JOIN
                    questionnaire_answer qat
                ON
                    qat.questionnaire_campaign_id=qc_pa_agreement.id
                JOIN
                    persons p
                ON
                    qat.center = p.center
                AND qat.id= p.id
                WHERE
                    qc_pa_agreement.name LIKE '%Kids Participation Agreement%'
                AND qat.status = 'COMPLETED' ) qa
        ON
            qa.rnk = 1
        AND qa.current_person_center = cp.center
        AND qa.current_person_id= cp.id
        LEFT JOIN
            j_entries immun
        ON
            immun.current_person_center = cp.center
        AND immun.current_person_id = cp.id
        AND immun.rnk = 1
        AND immun.name = 'Immunization or Exemption Form'
        LEFT JOIN
            j_entries health_history_form
        ON
            health_history_form.current_person_center = cp.center
        AND health_history_form.current_person_id = cp.id
        AND health_history_form.rnk = 1
        AND health_history_form.name = 'Health History Form'
        LEFT JOIN
            j_entries rock_wall
        ON
            rock_wall.current_person_center = cp.center
        AND rock_wall.current_person_id = cp.id
        AND rock_wall.rnk = 1
        AND rock_wall.name = 'Rockwall Waiver'
        LEFT JOIN
            j_entries doc_field_trip
        ON
            doc_field_trip.current_person_center = cp.center
        AND doc_field_trip.current_person_id = cp.id
        AND doc_field_trip.rnk = 1
        AND doc_field_trip.name = 'Field Trip Permission'
        LEFT JOIN
            j_entries doc_swim
        ON
            doc_swim.current_person_center = cp.center
        AND doc_swim.current_person_id = cp.id
        AND doc_swim.rnk = 1
        AND doc_swim.name = 'Swim Test'
        LEFT JOIN
            person_ext_attrs ap1
        ON
            ap1.personcenter = p.center
        AND ap1.personid = p.id
        AND ap1.name = 'AuthorizedPickup1'
        LEFT JOIN
            person_ext_attrs ap2
        ON
            ap2.personcenter = p.center
        AND ap2.personid = p.id
        AND ap2.name = 'AuthorizedPickup2'
        LEFT JOIN
            person_ext_attrs ap3
        ON
            ap3.personcenter = p.center
        AND ap3.personid = p.id
        AND ap3.name = 'AuthorizedPickup3'
        LEFT JOIN
            person_ext_attrs ec1
        ON
            ec1.personcenter = p.center
        AND ec1.personid = p.id
        AND ec1.name = 'EmergencyContact1'
        LEFT JOIN
            person_ext_attrs ec2
        ON
            ec2.personcenter = p.center
        AND ec2.personid = p.id
        AND ec2.name = 'EmergencyContact2'
        LEFT JOIN
            person_ext_attrs ec1r
        ON
            ec1r.personcenter = p.center
        AND ec1r.personid = p.id
        AND ec1r.name = 'RelationshipEmergencyContact1'
        LEFT JOIN
            person_ext_attrs ec2r
        ON
            ec2r.personcenter = p.center
        AND ec2r.personid = p.id
        AND ec2r.name = 'RelationshipEmergencyContact2'
        LEFT JOIN
            person_ext_attrs cap1
        ON
            cap1.personcenter = p.center
        AND cap1.personid = p.id
        AND cap1.name = 'CellPhoneAuthorizedPickup1'
        LEFT JOIN
            person_ext_attrs cap2
        ON
            cap2.personcenter = p.center
        AND cap2.personid = p.id
        AND cap2.name = 'CellPhoneAuthorizedPickup2'
        LEFT JOIN
            person_ext_attrs cap3
        ON
            cap3.personcenter = p.center
        AND cap3.personid = p.id
        AND cap3.name = 'CellPhoneAuthorizedPickup3'
        LEFT JOIN
            person_ext_attrs cec1
        ON
            cec1.personcenter = p.center
        AND cec1.personid = p.id
        AND cec1.name = 'CellPhoneEmergencyContact1'
        LEFT JOIN
            person_ext_attrs cec2
        ON
            cec2.personcenter = p.center
        AND cec2.personid = p.id
        AND cec2.name = 'CellPhoneEmergencyContact2'
                
        LEFT JOIN
            person_ext_attrs parent1
        ON
            parent1.personcenter = p.center
        AND parent1.personid = p.id
        AND parent1.name = 'Parent1'
        LEFT JOIN
            person_ext_attrs parent2
        ON
            parent2.personcenter = p.center
        AND parent2.personid = p.id
        AND parent2.name = 'Parent2'
        LEFT JOIN
            person_ext_attrs parent1cell
        ON
            parent1cell.personcenter = p.center
        AND parent1cell.personid = p.id
        AND parent1cell.name = 'PhoneNumberParent1'
        LEFT JOIN
            person_ext_attrs parent2cell
        ON
            parent2cell.personcenter = p.center
        AND parent2cell.personid = p.id
        AND parent2cell.name = 'PhoneNumberParent2'
        LEFT JOIN
            person_ext_attrs insect_bite
        ON
            insect_bite.name='A201qu14an1'
        AND p.center=insect_bite.personcenter
        AND p.id=insect_bite.personid
        LEFT JOIN
            person_ext_attrs bee_sting
        ON
            bee_sting.name='A201qu14an2'
        AND p.center=bee_sting.personcenter
        AND p.id=bee_sting.personid
        LEFT JOIN
            person_ext_attrs seasonal
        ON
            seasonal.name='A201qu14an3'
        AND p.center=seasonal.personcenter
        AND p.id=seasonal.personid
        LEFT JOIN
            person_ext_attrs medication
        ON
            medication.name='A201qu14an4'
        AND p.center=medication.personcenter
        AND p.id=medication.personid
        LEFT JOIN
            person_ext_attrs food_allergy
        ON
            food_allergy.name='A201qu14an5'
        AND p.center=food_allergy.personcenter
        AND p.id=food_allergy.personid
        LEFT JOIN
            person_ext_attrs sun_screen
        ON
            sun_screen.name='A201qu14an6'
        AND p.center=sun_screen.personcenter
        AND p.id=sun_screen.personid
        LEFT JOIN
            person_ext_attrs insect_rep
        ON
            insect_rep.name='A201qu14an7'
        AND p.center=insect_rep.personcenter
        AND p.id=insect_rep.personid
        LEFT JOIN
            person_ext_attrs other_allergy
        ON
            other_allergy.name='A201qu14an8'
        AND p.center=other_allergy.personcenter
        AND p.id=other_allergy.personid
        LEFT JOIN
            person_ext_attrs past_med_treatment
        ON
            past_med_treatment.name='A201qu31an1'
        AND p.center= past_med_treatment.personcenter
        AND p.id= past_med_treatment.personid
        LEFT JOIN
            person_ext_attrs prep_medication
        ON
            prep_medication.name='A201qu33an1'
        AND p.center=prep_medication.personcenter
        AND p.id=prep_medication.personid
        LEFT JOIN
            person_ext_attrs non_prepscripion_medicine
        ON
            non_prepscripion_medicine.name='A201qu40an1'
        AND p.center=non_prepscripion_medicine.personcenter
        AND p.id=non_prepscripion_medicine.personid
        LEFT JOIN
            person_ext_attrs will_carry_inhaler
        ON
            will_carry_inhaler.name='A201qu37an1'
        AND p.center=will_carry_inhaler.personcenter
        AND p.id=will_carry_inhaler.personid
        LEFT JOIN
            person_ext_attrs will_not_carry_inhaler
        ON
            will_not_carry_inhaler.name='A201qu37an2'
        AND p.center=will_not_carry_inhaler.personcenter
        AND p.id=will_not_carry_inhaler.personid
        LEFT JOIN
            person_ext_attrs special_diet
        ON
            special_diet.name='A201qu42an1'
        AND p.center=special_diet.personcenter
        AND p.id=special_diet.personid
        WHERE
            a.external_id IN ($$external_id$$) 
        ) t
ORDER BY
    booking,
    starttime,
    lastname,
    firstname