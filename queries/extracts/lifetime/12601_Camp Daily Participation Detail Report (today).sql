WITH
params AS
(
	SELECT
		ID   AS CENTERID,
		NAME AS CENTERNAME,
		CAST(datetolongc(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD HH24:MI:SS'), c.id) AS BIGINT) AS FROM_DATE,
		CAST(datetolongc(TO_CHAR(CURRENT_DATE+1,'YYYY-MM-DD HH24:MI:SS'), c.id) AS BIGINT)-1 AS  TO_DATE
	FROM
		CENTERS C
	WHERE ID IN ($$scope$$)
), 
participants AS MATERIALIZED
(
SELECT
    CENTERNAME as center,
    booking,
    ap1 || ap2 || ap3 AS ap,
    ec1 || ec2 AS ec,
    par1 || par2  AS parents,
    starttime,
    reservation_date,
    stopdate,
    centerid,
    centername,
    program_name,
    external_id AS external,
    COALESCE(fullname,'') AS fullname,
	
    COALESCE(immunization_current,'') AS ic,

    COALESCE(participation_agr || swim_test_form  || doc_field_trip || health_history_form || rock_wall_form ,'') AS docs,
  
    COALESCE(insect_bite_allergy || bee_sting_allergy ||  seasonal_allergy || medication_allergy || food_allergy || sun_screen_allergy || insect_rep_allergy || other_allergy,'') AS allergy,
			 
    COALESCE(past_med_treatment || prep_medication ||  non_prepscripion_medicine || will_carry_inhaler || will_not_carry_inhaler || special_diet ,'') AS med,

    center as personcenter, 
    id as personid,
    lastname,
    firstname
FROM
    (
        
        SELECT 
            b.name as booking,
            CASE WHEN ap1.txtvalue IS NULL AND cap1.txtvalue IS NULL THEN ''
                 ELSE COALESCE(ap1.txtvalue, '') ||' | '||COALESCE(cap1.txtvalue,'') || CHR(10)  
            END AS AP1,
            CASE WHEN ap2.txtvalue IS NULL AND cap2.txtvalue IS NULL THEN ''
                 ELSE COALESCE(ap2.txtvalue, '') ||' | '||COALESCE(cap2.txtvalue,'') || CHR(10)  
            END AS AP2,
            CASE WHEN ap3.txtvalue IS NULL AND cap3.txtvalue IS NULL THEN ''
                 ELSE COALESCE(ap3.txtvalue, '') ||' | '||COALESCE(cap3.txtvalue,'') || CHR(10)  
            END AS AP3,
            CASE WHEN ec1.txtvalue IS NULL AND cec1.txtvalue IS NULL AND ec1r.txtvalue IS NULL THEN ''
                 ELSE COALESCE(ec1.txtvalue, '') ||' | '||COALESCE(cec1.txtvalue,'') ||' | '||COALESCE(ec1r.txtvalue,'') || CHR(10)  
            END AS EC1,
            CASE WHEN ec2.txtvalue IS NULL AND cec2.txtvalue IS NULL AND ec2r.txtvalue IS NULL THEN ''
                 ELSE COALESCE(ec2.txtvalue, '') ||' | '||COALESCE(cec2.txtvalue,'') ||' | '||COALESCE(ec2r.txtvalue,'') || CHR(10)  
            END AS EC2,            
            CASE WHEN parent1.txtvalue IS NULL AND parent1cell.txtvalue IS NULL THEN ''
                 ELSE COALESCE(parent1.txtvalue, '') ||' | '||COALESCE(parent1cell.txtvalue,'') || CHR(10)  
            END AS par1,
            CASE WHEN parent2.txtvalue IS NULL AND parent2cell.txtvalue IS NULL THEN ''
                 ELSE COALESCE(parent2.txtvalue, '') ||' | '||COALESCE(parent2cell.txtvalue,'') || CHR(10)  
            END AS par2,
            TO_CHAR(longtodateC(b.starttime,b.center),'mm/dd/yyyy HH24:MI')   AS starttime,
            TO_CHAR(bp.startdate,'mm/dd/yyyy')                       AS reservation_date,
            TO_CHAR(bp.stopdate,'mm/dd/yyyy')                        AS stopdate,
            CENTERID,
            CENTERNAME,
            bp.name AS program_name,
            p.external_id,p.center,p.id,
            CASE 
				WHEN LENGTH(p.fullname) > 19 then substring(p.fullname,1,18) ||'..'
				ELSE p.fullname 
			END AS fullname,

            case when immun.name IS NOT NULL then 'Yes' 
			     else ''
            end as immunization_current,

			case when
				qa.status = 'COMPLETED'  
				then ' Participation Agreement            ' || to_char(longtodatec(qa.log_time,qa.center),'mm/dd/yyyy') || 
				'                       ' || to_char(qa.expiration_date,'mm/dd/yyyy')  ||  chr(10)
				else ''
            end participation_agr,
			---
			case when
				doc_field_trip.name is not null 
				then ' Field Trip Permission                 ' || to_char(longtodatec(doc_field_trip.creation_time,doc_field_trip.person_center),'mm/dd/yyyy') || 
				'                       ' || to_char(doc_field_trip.expiration_date,'mm/dd/yyyy')  ||  chr(10)
				else ''
            end doc_field_trip,
			---
			case when
				health_history_form.name is not null 
				then ' Health History Form                   ' || to_char(longtodatec(health_history_form.creation_time,health_history_form.person_center),'mm/dd/yyyy') || 
				'                       ' || to_char(health_history_form.expiration_date,'mm/dd/yyyy') 	||  chr(10)
			else ''
            end health_history_form,
            ---
			case when
				doc_swim.name is not null 
				then  ' Swim Test                                  ' || to_char(longtodatec(doc_swim.creation_time,doc_swim.person_center),'mm/dd/yyyy')  || 
				'                       ' || to_char(doc_swim.expiration_date,'mm/dd/yyyy') ||  chr(10)                      
				else ''
            end swim_test_form,
             ---
			case when
				rock_wall.name is not null 
				then ' Climbing Waiver                         ' || to_char(longtodatec(rock_wall.creation_time,rock_wall.person_center),'mm/dd/yyyy') || 
				'                       ' || to_char(rock_wall.expiration_date,'mm/dd/yyyy')  ||  chr(10)
				else ''
            end rock_wall_form,
			
			-- Allergi
            case when insect_bite.txtvalue is not null then 'Insect Bite: ' || insect_bite.txtvalue || chr(10)
				else '' 
			end AS insect_bite_allergy,
            case when bee_sting.txtvalue is not null then 'Bee Sting: ' || bee_sting.txtvalue || chr(10)
				else ''
            end AS bee_sting_allergy,
            case when seasonal.txtvalue is not null then 'Seasonal Allergy: ' || seasonal.txtvalue || chr(10)
				else ''
			end AS seasonal_allergy,
            case when medication.txtvalue is not null then 'Medication Allergy: ' || medication.txtvalue || chr(10)
				else '' 
			end AS medication_allergy,
            case when food_allergy.txtvalue is not null then 'Food Allergy: ' || food_allergy.txtvalue || chr(10)
				else '' 
			end AS food_allergy,
            case when sun_screen.txtvalue is not null then 'Sun Screen: ' || sun_screen.txtvalue || chr(10)
				else '' 
			end AS sun_screen_allergy,
            case when insect_rep.txtvalue is not null then 'Insect Repellant: ' || insect_rep.txtvalue || chr(10)
				else '' 
			end  AS insect_rep_allergy,
            case when other_allergy.txtvalue is not null then 'Other Allergy: ' || other_allergy.txtvalue || chr(10)
				else '' end AS other_allergy,
				
			-- Medical info
 			case when past_med_treatment.txtvalue is not null then 'Injury and Medical Treatment:' || past_med_treatment.txtvalue || chr(10)
            else '' end  AS past_med_treatment,
			case when prep_medication.txtvalue is not null then 'Prescription Medication:' || prep_medication.txtvalue || chr(10)
            else '' end  AS prep_medication,
			case when non_prepscripion_medicine.txtvalue is not null then 'Non-prep. med.:' || non_prepscripion_medicine.txtvalue || chr(10)
            else '' end  AS non_prepscripion_medicine,
			case when will_carry_inhaler.txtvalue is not null then 'Will carry inhaler:' || will_carry_inhaler.txtvalue || chr(10)
            else '' end  AS will_carry_inhaler,
			case when will_not_carry_inhaler.txtvalue is not null then 'Will not carry inhaler:' || will_not_carry_inhaler.txtvalue || chr(10)
            else '' end  AS will_not_carry_inhaler,
			case when special_diet.txtvalue is not null then 'Special Diet:' || special_diet.txtvalue || chr(10)
            else '' end  AS special_diet, 
            p.lastname,
            p.firstname
        FROM
            params
        JOIN
            bookings b
        ON
            b.center = params.centerid
        AND B.state !='CANCELLED'
        JOIN
            booking_programs bp
        ON
            b.booking_program_id = bp.id
        AND b.starttime BETWEEN params.from_date AND params.to_date
        JOIN
            activity a
        ON
            b.activity = a.id
        AND a.activity_type = 11
        JOIN
            booking_program_types bpt
        ON
            bpt.id = bp.program_type_id
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
        (
        SELECT
            rank() over (partition BY qat.center, qat.id ORDER BY qat.log_time DESC) AS rnk,
            qat.center,
            qat.id,
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
        WHERE
            qc_pa_agreement.name like '%Kids Participation Agreement%' 
			AND qat.status = 'COMPLETED'
		) qa
		ON
			qa.rnk = 1
			AND p.center = qa.center
			AND p.id= qa.id		
			
		LEFT JOIN
     	(		
		select 
		  rank() over (partition BY person_center, person_id ORDER BY creation_time DESC) AS rnk,
		  person_center,
		  person_id,
		  creation_time,
		  expiration_date,
		  name
		from 
		  journalentries
		WHERE
		   custom_type = 2 --name = 'Immunization or Exemption Form'
		  AND state = 'ACTIVE'
		) immun
		ON
			immun.person_center = p.center
			AND immun.person_id = p.id
			AND immun.rnk = 1
		
		LEFT JOIN
     	(		
		select 
		  rank() over (partition BY person_center, person_id ORDER BY creation_time DESC) AS rnk,
		  person_center,
		  person_id,
		  creation_time,
		  expiration_date,
		  name
		from 
		  journalentries
		WHERE
		    custom_type = 51 --name = 'Health History Form'
		  AND state = 'ACTIVE'
		) health_history_form
		ON
			health_history_form.person_center = p.center
			AND health_history_form.person_id = p.id
			AND health_history_form.rnk = 1
		
		LEFT JOIN
     	(		
		select 
		  rank() over (partition BY person_center, person_id ORDER BY creation_time DESC) AS rnk,
		  person_center,
		  person_id,
		  creation_time,
		  expiration_date,
		  name
		from 
		  journalentries
		WHERE
		    custom_type = 4 --name = 'Rockwall Waiver'
		  AND state = 'ACTIVE'
		) rock_wall
		ON
			rock_wall.person_center = p.center
			AND rock_wall.person_id = p.id
			AND rock_wall.rnk = 1	
        
		LEFT JOIN
        (		
		select 
		  rank() over (partition BY person_center, person_id ORDER BY creation_time DESC) AS rnk,
		  person_center,
		  person_id,
		  creation_time,
		  expiration_date,
		  name
		from 
		  journalentries 
		WHERE
		 custom_type = 102 --name = 'Field Trip Permission'
		  AND state = 'ACTIVE'
		) doc_field_trip
		ON
			doc_field_trip.person_center = p.center
			AND doc_field_trip.person_id = p.id
			AND doc_field_trip.rnk = 1
		
		LEFT JOIN
     	(		
		select 
		  rank() over (partition BY person_center, person_id ORDER BY creation_time DESC) AS rnk,
		  person_center,
		  person_id,
		  creation_time,
		  expiration_date,
		  name
		from 
		  journalentries
		WHERE
		  name = 'Swim Test'
		  AND state = 'ACTIVE'
		) doc_swim
		ON
			doc_swim.person_center = p.center
			AND doc_swim.person_id = p.id
			AND doc_swim.rnk = 1

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
        AND    p.center=medication.personcenter
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
    ) t
)
,
-- find the family members with MEMBER and older than 18 (part 1)
famrel1 as 
(
SELECT 
    d.personcenter||'p'||d.personid as pid, d.starttime, coalesce(string_agg(pp.fullname, chr(10)),'') AS list_fam
from
    participants d
LEFT join 
(
	SELECT 
		fam.fullname,
		r.center main_mem_center, 
		r.id main_mem_id
	FROM
	   relatives r
	JOIN 
	  persons fam
	ON 
	  fam.center = r.relativecenter 
	  AND fam.id = r.relativeid
	JOIN 
	  person_ext_attrs pe
	ON
	  fam.center = pe.personcenter
	  AND fam.id = pe.personid     
	  AND pe.name = 'MMSRegistrationCategory' 
	  AND pe.txtvalue = 'Member'
	WHERE    
	  r.rtype = 18
	  AND r.status < 2
	  AND date_part('year', AGE(fam.birthdate)) > 18        
	)  pp
ON
   pp.main_mem_center  = d.personcenter 
   AND pp.main_mem_id  = d.personid
GROUP BY 	
   d.personcenter, d.personid, d.starttime
)
,
-- find the family members with MEMBER and older than 18 (part 2)
famrel2 as 
(
SELECT 
    d.personcenter||'p'||d.personid as pid, d.starttime, coalesce(string_agg(pp.fullname, chr(10)),'') AS list_fam
from
    participants d
LEFT join 
(
SELECT 
   fam.fullname,   
   r.relativecenter main_mem_center, 
   r.relativeid main_mem_id
FROM
   relatives r
JOIN 
  persons fam
ON          
  fam.center = r.center 
  AND fam.id = r.id
JOIN 
  person_ext_attrs pe
ON
  fam.center = pe.personcenter
  AND fam.id = pe.personid     
  AND pe.name = 'MMSRegistrationCategory' 
  AND pe.txtvalue = 'Member'
WHERE    
  r.rtype = 18
  AND r.status < 2
  AND date_part('year', AGE(fam.birthdate)) > 18        
)  pp
ON
   pp.main_mem_center  = d.personcenter 
   AND pp.main_mem_id  = d.personid
GROUP BY 	
   d.personcenter, d.personid, d.starttime
)

SELECT  
  pcpts.*, 
  CASE WHEN famrel1.list_fam IS NULL AND famrel2.list_fam IS NULL THEN NULL
       ELSE COALESCE(famrel1.list_fam,'') || COALESCE(famrel2.list_fam,'') 
  END AS adults
FROM 
  participants pcpts 
LEFT JOIN
  famrel1 
ON
  pcpts.personcenter ||'p'|| pcpts.personid = famrel1.pid
  AND pcpts.starttime = famrel1.starttime
LEFT JOIN 
  famrel2 
ON  
  pcpts.personcenter ||'p'|| pcpts.personid = famrel2.pid  
  AND pcpts.starttime = famrel1.starttime		
ORDER BY booking, starttime, lastname, firstname					
			