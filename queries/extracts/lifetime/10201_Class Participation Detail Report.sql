/*
--Define what columns need to use max value
--Add alergies based on person extended attributes
--Case statement for competed = true/false
--Rename columns to match Jasper report expectation
--Filter records based on what is current';
*/
SELECT distinct
t.lastname,
bookingstart,
bookingstop,
booking,
t.centername as center,
t.CENTERNAME as centername,
    COALESCE(ap1,'') ap1,
    COALESCE(ap2,'') ap2,
    COALESCE(ap3,'') ap3,
    COALESCE(ec1,'') ec1,
    COALESCE(ec2,'') ec2,
    reservation_date,
    stopdate,
    centerid,
    centername,
    program_name,
    participant_center,
    participant_id,
    external_id as external,
    COALESCE(fullname,'') fullname,
  --  COALESCE(camp_gender,'') camp_gender,
    COALESCE(participation_agreement_completed,'') pa,
    COALESCE(max(participation_agreement_expiration_from),'') pa_from,
    max(COALESCE(participation_agreement_expiration_to,'')) pa_to,
    COALESCE(immunization_expiration,'') immunization_expiration,
    COALESCE(doc_field_trip,'') doc_field_trip,
    COALESCE("Immunization or Exemption Form",'') "Immunization or Exemption Form",
     COALESCE(immunization_expiration,'')immunization_expiration,
    COALESCE(doc_field_trip_expiration,'') doc_field_trip_expiration ,
    COALESCE(doc_field_trip,'') doc_field_trip,
    COALESCE(health_history_form,'') health_history_form,
    COALESCE(health_history_form_expiration,'') health_history_form_expiration,
    COALESCE(swim_test_form,'') sw,
    COALESCE(swim_test_expiration_from,'')sw_from,
    COALESCE(swim_test_expiration_to,'') sw_to,
    COALESCE(rock_wall_form,'') rw,
    COALESCE(rock_wall_expiration_from,'') rw_from,
    COALESCE( rock_wall_expiration_to,'') rw_to,    
    COALESCE(insect_bite_allergy,'')iba,
    COALESCE(bee_sting_allergy,'')bsa,
    COALESCE(seasonal_allergy,'')sa,
    COALESCE(medication_allergy,'') ma,
    COALESCE(food_allergy,'') fa,
    COALESCE(sun_screen_allergy,'') ssa,
    COALESCE(insect_rep_allergy,'') ira,
    COALESCE(other_allergy,'') oa,
    COALESCE(immunization_current,'') as ic,
    case when bring_an_inhaler = 'Yes' or otc_prescription = 'Yes' or bring_prescription = 'Yes'
    then 'Yes' else 'No' end as maa, --medical admin authorized
    pres,
    otc,
    asthma
FROM
    (
        WITH
            params AS
            (
                SELECT distinct
                    *                    
                FROM
                    (
                        SELECT distinct
                            ID   AS CENTERID,
                            NAME AS CENTERNAME,
                            c.name as club_of_camp,
                            c.id AS CENTER_ID,
                            datetolongc(TO_CHAR(to_date(:from_date, 'YYYY-MM-DD HH24:MI:SS'),
                            'YYYY-MM-DD HH24:MI:SS') , c.id) AS FROM_DATE,
                            datetolongc(TO_CHAR(to_date(:to_date, 'YYYY-MM-DD HH24:MI:SS'),
                            'YYYY-MM-DD HH24:MI:SS'), c.id) + (24*3600*1000) - 1 AS TO_DATE
                        FROM
                            CENTERS C
                            where c.id in (:scope)
                         
                    )t
            )
            ,
            questionnaire_data AS
            (
                SELECT distinct 
                    t2.*
                FROM
                    (
                        SELECT distinct
                            (row_number() over() / 1)                         AS answer_id,
                            'A'||id||'qu'||question_id||'an'||question_ops_id AS answer_check
                        FROM
                            (
                                SELECT
                                    id,
                                    CAST(CAST(unnest(xpath('//questionnaire/question/id/text()', x)
                                    )AS text)AS INTEGER) AS question_id,
                                    CAST(CAST(unnest(xpath
                                    ('//questionnaire/question/options/option/id/text()', x)) AS
                                    text) AS INTEGER) AS question_ops_id
                                FROM
                                    questionnaires q,
                                    xmlparse(document convert_from(questions, 'UTF-8')) x
                                WHERE
                                    name IN ('Kids Participation Agreement',                                            
                                             'LT Kids Participation Agreement',
                                             'Kids Participation Agreement - OLD'
                                             ) )t
                        WHERE
                            t.question_id in (18)
                        AND t.id=(select id from questionnaires where name = ('Kids Participation Agreement - OLD'))
                        GROUP BY
                            id,
                            question_id,
                            question_ops_id)t2
            )
        SELECT DISTINCT on (pa.id) 
        p.lastname,
        max(''||b.center||b.id||''||qa.subid) as sub,
       qa.subid as qasubid,
        b.center as bookingcenter,b.id as bookingid,
        longtodatec(b.starttime,b.center) as bookingstart,
        longtodatec(b.stoptime,b.center) as bookingstop,        
            b.name as booking,
            ap1.txtvalue||'| '||cap1.txtvalue                        AS AP1,
            ap2.txtvalue||' | '||cap2.txtvalue                       AS AP2,
            ap3.txtvalue||' | '||cap3.txtvalue                       AS AP3,
            ec1.txtvalue||' | '||cec1.txtvalue||' | '||ec1r.txtvalue AS EC1,
            ec2.txtvalue||' | '||cec2.txtvalue||' | '||ec2r.txtvalue AS EC2,
            to_char(longtodatec(b.starttime,b.center),'mm-dd-yyyy')                       AS reservation_date,
            to_char(longtodatec(b.stoptime,b.center),'mm-dd-yyyy')                        AS stopdate,
             case when qa.status = 'COMPLETED'
            then 'Participation Agreement'
            else '' end  AS participation_agreement_completed,
            to_char(qa.expiration_date,'mm/dd/yyyy') AS participation_agreement_expiration_to,
            to_char(longtodatec(qa.log_time,qa.center),'mm/dd/yyyy') as participation_agreement_expiration_from,
            CENTERID,
            CENTERNAME,
            b.name AS program_name,
             immun.name                          AS "Immunization or Exemption Form", 
            PA.participant_center,
            PA.participant_id,
            p.external_id,
            p.fullname,
            p.lastname||', '||p.firstname AS camper_name,
            p.sex              AS camp_gender,
          --  qa.status          AS participation_agreement_completed,
            qa.expiration_date AS participation_agreement_expiration,---get the max value here
            -- to get
            -- the latest entry and prevent duplicates.
            immun.name                          AS immunization_except_form, --"Immunization or Exemption Form",
            to_char(immun.expiration_date,'mm/dd/yyyy')               AS immunization_expiration,
            doc_field_trip.name                 AS doc_field_trip,
            to_char(doc_field_trip.expiration_date,'mm/dd/yyyy')      AS doc_field_trip_expiration,
            health_history_form.name            AS health_history_form,
            TO_CHAR(health_history_form.expiration_date,'mm/dd/yyyy') AS health_history_form_expiration,
            case when
            doc_swim.name is not null
            then 'Swim Test'
            else ''
            end swim_test_form,
            to_char(longtodatec(doc_swim.creation_time,doc_swim.person_center),'mm/dd/yyyy') swim_test_expiration_from,
            to_char(doc_swim.expiration_date,'mm/dd/yyyy') as swim_test_expiration_to,
            case when 
            rock_wall.name is not null 
            then 'Climbing Waiver'
            else '' end AS rock_wall_form,
            to_char(rock_wall.expiration_date,'mm/dd/yyyy') AS rock_wall_expiration_from,
            to_char(rock_wall.expiration_date,'mm/dd/yyyy') AS rock_wall_expiration_to,
          --  qu.questions                                                               AS questions,
           -- Qu.id                                                               AS questionnaire_id,
           -- Qu.name                                                           AS questionnaire_name,
            case when 
            insect_bite.txtvalue is not null then 'Insect Bite'
            else '' end AS insect_bite_allergy,
            case when bee_sting.txtvalue is not null
            then 'Bee Sting'
            else ''
            end AS bee_sting_allergy,
            case when seasonal.txtvalue is not null
            then 'Seasonal Allergy' end AS seasonal_allergy,
            case when medication.txtvalue is not null 
            then 'Medication Allergy' else '' end AS medication_allergy,
            case when food_allergy.txtvalue is not null then 'Food Allergy'
            else '' end AS food_allergy,
            case when sun_screen.txtvalue is not null then 'Sun Screen'
            else '' end AS sun_screen_allergy,
            case when insect_rep.txtvalue is not null then 'Insect Repellant'
            else '' end  AS insect_rep_allergy,
            case when other_allergy.txtvalue is not null then 'Other Allergy'
            else '' end AS other_allergy,
            case when immunization_current.number_answer = 1 then 'Yes' else 'No'
            end as immunization_current,
            max(immunization_current.id),
            case when 
            bring_an_inhaler.number_answer = 1 then 'Yes'
            else 'No' end as bring_an_inhaler,             
            case when
             bring_prescription.number_answer = 1 then 'Yes'
             else 'No' end as bring_prescription,
             case when otc_prescription.number_answer = 1 then 'Yes'
             else 'No' end as otc_prescription,
             case when asthma.number_answer = 1 then 'Asthma'
             else '' end as asthma,
             case when prescription.number_answer = 1 then 'Prescription Medication'
             else '' end as pres,
             case when otc.number_answer = 1 then 'Non-Prescription Medication'
             else '' end as otc
            
            FROM
            params
        JOIN
            bookings b
        ON
            b.center = centerid
        AND B.state !='CANCELLED'
        JOIN
            activity a
        ON
            b.activity = a.id
        AND a.activity_type = 2
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
        LEFT JOIN
            questionnaire_campaigns qc_pa_agreement
        ON
            qc_pa_agreement.name in('LT Kids Participation Agreement') --Kids Participation Agreement --> Change to this for Production
        LEFT JOIN
            questionnaire_answer qa
        ON
            p.center = qa.center
        AND p.id=qa.id
        AND qa.questionnaire_campaign_id=qc_pa_agreement.id
        and qa.replaced_by_center is null and qa.replaced_by_id is null
--       left join lifetime.question_answer immunization_current on immunization_current.answer_center = p.center and immunization_current.answer_id = p.id
--        AND immunization_current.question_id = 15 
        LEFT JOIN
            journalentries immun
        ON
            p.center = immun.person_center
        AND p.id =immun.person_id
        AND immun.name ='Immunization or Exemption Form'
        LEFT JOIN
            journalentries health_history_form
        ON
            p.center = health_history_form.person_center
        AND p.id =health_history_form.person_id
        AND health_history_form.name ='Health History Form'
        LEFT JOIN
            journalentries rock_wall
        ON
            p.center = rock_wall.person_center
        AND p.id =rock_wall.person_id
        AND rock_wall.name ='Rockwall Waiver'
        LEFT JOIN
            journalentries doc_field_trip
        ON
            p.center = doc_field_trip.person_center
        AND p.id =doc_field_trip.person_id
        AND doc_field_trip.name ='Field Trip Permission'
        LEFT JOIN
            lifetime.journalentries doc_swim
        ON
            p.center = doc_swim.person_center
        AND p.id =doc_swim.person_id
        AND doc_swim.name ='Swim Test'
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
        ----------------------------------------------------------
        LEFT JOIN
            person_ext_attrs insect_bite
        ON
            --insect_bite.name =p.name AND
            insect_bite.name=(select answer_check from questionnaire_data where answer_id = 1)
        AND p.center=insect_bite.personcenter
        AND p.id=insect_bite.personid
        LEFT JOIN
            person_ext_attrs bee_sting
        ON
            --bee_sting.name =p.name AND
            bee_sting.name=(select answer_check from questionnaire_data where answer_id = 2)--'A401qu18an2'
        AND p.center=bee_sting.personcenter
        AND p.id=bee_sting.personid
        LEFT JOIN
            person_ext_attrs seasonal
        ON
            --seasonal.name =p.name AND
            seasonal.name=(select answer_check from questionnaire_data where answer_id = 3)--'A401qu18an3'
        AND p.center=seasonal.personcenter
        AND p.id=seasonal.personid
        LEFT JOIN
            person_ext_attrs medication
        ON
            --    medication.name =p.name AND
            p.center=medication.personcenter
        AND p.id=medication.personid
        AND medication.name=(select answer_check from questionnaire_data where answer_id = 4)--'A401qu18an4'
        LEFT JOIN
            person_ext_attrs food_allergy
        ON
            --    food_allergy.name =p.name AND
            food_allergy.name=(select answer_check from questionnaire_data where answer_id = 5)--'A401qu18an5'
        AND p.center=food_allergy.personcenter
        AND p.id=food_allergy.personid
        LEFT JOIN
            person_ext_attrs sun_screen
        ON
            --sun_screen.name =p.name AND
            sun_screen.name=(select answer_check from questionnaire_data where answer_id = 6)--'A401qu18an6'
        AND p.center=sun_screen.personcenter
        AND p.id=sun_screen.personid
        LEFT JOIN
            person_ext_attrs insect_rep
        ON
            --insect_rep.name =p.name AND
            insect_rep.name=(select answer_check from questionnaire_data where answer_id = 7)--'A401qu18an7'
        AND p.center=insect_rep.personcenter
        AND p.id=insect_rep.personid
        LEFT JOIN
            person_ext_attrs other_allergy
        ON
            --other_allergy.name =p.name AND
            other_allergy.name=(select answer_check from questionnaire_data where answer_id = 8)--'A401qu18an8'
        AND p.center=other_allergy.personcenter
        AND p.id=other_allergy.personid 
        left join lifetime.question_answer immunization_current on immunization_current.answer_center = p.center and immunization_current.answer_id = p.id
        AND immunization_current.question_id = 15
        left join lifetime.question_answer asthma on asthma.answer_center = p.center and asthma.answer_id = p.id and asthma.question_id = 35
        left join lifetime.question_answer bring_an_inhaler on bring_an_inhaler.answer_center = p.center and bring_an_inhaler.answer_id = p.id and bring_an_inhaler.question_id = 36
        left join lifetime.question_answer prescription on prescription.answer_center = p.center and prescription.answer_id = p.id and prescription.question_id = 39
        left join lifetime.question_answer bring_prescription on bring_prescription.question_id = 40 and bring_prescription.answer_center = p.center and bring_prescription.answer_id = p.id        
        left join lifetime.question_answer otc on otc.question_id = 42 and otc.answer_center = p.center and otc.answer_id = p.id
        left join lifetime.question_answer otc_prescription on otc_prescription.question_id = 43 and otc_prescription.answer_center = p.center and otc_prescription.answer_id = p.id 
    WHERE
     b.starttime between params.from_date and params.to_date      
     and a.external_id in (:external_id) --701591130151
        group by pa.id,qa.id,b.center,b.id,b.name,ap1.txtvalue,cap1.txtvalue,ap2.txtvalue,cap2.txtvalue,ap3.txtvalue,ec1r.txtvalue,
        cap3.txtvalue,ec1.txtvalue,cec1.txtvalue,cec2.txtvalue,ec2.txtvalue,ec2r.txtvalue,b.starttime,b.center,
        b.stoptime,qa.status,qa.expiration_date,qa.log_time,qa.center,params.centerid,params.centername,immun.name,
        pa.participant_center,pa.participant_id,p.external_id,p.fullname,p.lastname,p.firstname,p.sex,immun.expiration_date,
        doc_field_trip.name,doc_field_trip.expiration_date,health_history_form.name,health_history_form.expiration_date,
        doc_swim.name,doc_swim.creation_time,doc_swim.person_center,doc_swim.expiration_date,rock_wall.name,rock_wall.expiration_date,
        insect_bite.txtvalue,bee_sting.txtvalue,seasonal.txtvalue,medication.txtvalue,food_allergy.txtvalue,sun_screen.txtvalue,insect_rep.txtvalue,
        other_allergy.txtvalue,qa.subid
      ,immunization_current.number_answer,immunization_current.id,bring_an_inhaler.number_answer,bring_prescription.number_answer,otc_prescription.number_answer,
      asthma.number_answer,prescription.number_answer,otc.number_answer
   
        )t
GROUP BY
otc,
pres,
asthma,
otc_prescription,
bring_prescription,
bring_an_inhaler,
lastname,
bookingcenter,
bookingid,
qasubid,
bookingstart,
bookingstop,
"Immunization or Exemption Form",
immunization_current,
booking,
    ap1,
    ap2,
    ap3,
    ec1,
    ec2,
    reservation_date,
    stopdate,
    centerid,
    centername,
    program_name,
    participant_center,
    participant_id,
    external_id,
    fullname,
    participation_agreement_completed,
    participation_agreement_expiration_from,
    participation_agreement_expiration_to,
    immunization_except_form,
    immunization_expiration,
    doc_field_trip,
    doc_field_trip_expiration,
    health_history_form,
    health_history_form_expiration,
    rock_wall_form,
    rock_wall_expiration_from,
    rock_wall_expiration_to,
    swim_test_form,
    swim_test_expiration_from,
    swim_test_expiration_to,
    camp_gender,
    insect_bite_allergy,
    bee_sting_allergy,
    seasonal_allergy,
    medication_allergy,
    food_allergy,
    sun_screen_allergy,
    insect_rep_allergy,
    other_allergy
       order by 1 asc
     