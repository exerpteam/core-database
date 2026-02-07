WITH 
params AS
(
        SELECT
                datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                c.id AS CENTER_ID,
                CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
        FROM
                centers c
),
answers AS
(
        SELECT DISTINCT
                q.center
                ,q.id
                ,q.subid
                ,q.questionnaire_campaign_id
                ,array_to_string(array_agg(DISTINCT CASE
                        WHEN qa1.number_answer = '1' THEN 'Weight Loss'
                        WHEN qa1.number_answer = '2' THEN 'Increase fitness'
                        WHEN qa1.number_answer = '3' THEN 'Stress release'
                        WHEN qa1.number_answer = '4' THEN 'Information not given'
                END ),', ') AS "Member's Goal"
                ,array_to_string(array_agg(DISTINCT CASE
                        WHEN qa2.number_answer = '1' THEN '1'
                        WHEN qa2.number_answer = '2' THEN '2'
                        WHEN qa2.number_answer = '3' THEN '3'
                        WHEN qa2.number_answer = '4' THEN '4'
                        WHEN qa2.number_answer = '5' THEN '5'
                        WHEN qa2.number_answer = '6' THEN 'Information not given'
                END ),', ') AS "On what level did you achieve this goal"
                ,array_to_string(array_agg(DISTINCT CASE
                        WHEN qa3.number_answer = '1' THEN 'Better customer service'
                        WHEN qa3.number_answer = '2' THEN 'Cleanliness'
                        WHEN qa3.number_answer = '3' THEN 'Improve equipment and facilities'
                        WHEN qa3.number_answer = '4' THEN 'Better timetable'
                        WHEN qa3.number_answer = '5' THEN 'Everything was great (club no longer convenient)'
                        WHEN qa3.number_answer = '6' THEN 'Information not given'
                END ),', ') AS "Could we have done more to assist you with your goals"
                ,array_to_string(array_agg(DISTINCT CASE
                        WHEN qa4.number_answer = '1' THEN 'Equipment and facilities'
                        WHEN qa4.number_answer = '2' THEN 'Staff'
                        WHEN qa4.number_answer = '3' THEN 'Cleanliness'
                        WHEN qa4.number_answer = '4' THEN 'Moving'
                        WHEN qa4.number_answer = '5' THEN 'Financial'
                        WHEN qa4.number_answer = '6' THEN 'No time'
                        WHEN qa4.number_answer = '7' THEN 'Medical'
                        WHEN qa4.number_answer = '8' THEN 'Convenience/location'
                        WHEN qa4.number_answer = '9' THEN 'Information not given'
                END ),', ') AS "Cancellation reason"
                ,array_to_string(array_agg(DISTINCT CASE
                        WHEN qa5.number_answer = '1' THEN '1'
                        WHEN qa5.number_answer = '2' THEN '2'
                        WHEN qa5.number_answer = '3' THEN '3'
                        WHEN qa5.number_answer = '4' THEN '4'
                        WHEN qa5.number_answer = '5' THEN '5'
                        WHEN qa5.number_answer = '6' THEN 'Information not given'
                END ),', ') AS "How likely would you re-join Fernwood"   
                ,array_to_string(array_agg(DISTINCT CASE
                        WHEN qa6.number_answer = '1' THEN '1'
                        WHEN qa6.number_answer = '2' THEN '2'
                        WHEN qa6.number_answer = '3' THEN '3'
                        WHEN qa6.number_answer = '4' THEN '4'
                        WHEN qa6.number_answer = '5' THEN '5'
                        WHEN qa6.number_answer = '6' THEN 'Information not given'
                END ),', ') AS "Would you recommend Fernwood to a friend" 
        FROM
                questionnaire_answer q
        LEFT JOIN
                question_answer qa1
                ON qa1.answer_center = q.center
                AND qa1.answer_id = q.id
                AND qa1.answer_subid = q.subid
                AND qa1.question_id = 1        
        LEFT JOIN    question_answer qa2
                ON qa2.answer_center = q.center
                AND qa2.answer_id = q.id
                AND qa2.answer_subid = q.subid
                AND qa2.question_id = 2
        LEFT JOIN 
                question_answer qa3
                ON qa3.answer_center = q.center
                AND qa3.answer_id = q.id
                AND qa3.answer_subid = q.subid
                AND qa3.question_id = 3
        LEFT JOIN 
                question_answer qa4
                ON qa4.answer_center = q.center
                AND qa4.answer_id = q.id
                AND qa4.answer_subid = q.subid
                AND qa4.question_id = 4
        LEFT JOIN 
                question_answer qa5
                ON qa5.answer_center = q.center
                AND qa5.answer_id = q.id
                AND qa5.answer_subid = q.subid
                AND qa5.question_id = 5
        LEFT JOIN 
                question_answer qa6
                ON qa6.answer_center = q.center
                AND qa6.answer_id = q.id
                AND qa6.answer_subid = q.subid
                AND qa6.question_id = 6
        WHERE
                q.questionnaire_campaign_id = 1401   
        GROUP BY 
                q.center
                ,q.id
                ,q.subid
                ,q.questionnaire_campaign_id          
)
----------Main script---------                       
SELECT 
        p.center||'p'||p.id AS "Person ID"
        ,c.shortname AS "Club Name"
        ,p.fullname AS "Member Name"
        ,peaMOBILE.txtvalue AS "Contact Number"
        ,peaEMAIL.txtvalue AS "Email"
        ,answers."Member's Goal"
        ,answers."On what level did you achieve this goal"
        ,answers."Could we have done more to assist you with your goals"
        ,answers."Cancellation reason"
        ,answers."How likely would you re-join Fernwood"   
        ,answers."Would you recommend Fernwood to a friend"  
        ,lastattend.lastattend AS "Last Visit Date"
        ,totalcount.totalcount AS "Total Visit Count"
        ,s.start_date AS "Member Start Date" 
        ,s.end_date AS "Subscription End Date"      
        ,s.binding_end_date AS "Binding Period"  
        ,prod.name AS "Subscription Name"     
FROM 
        subscriptions s
JOIN
        persons p
        ON p.center = s.owner_center
        AND p.id = s.owner_id
JOIN
        (SELECT 
                person_center,person_id,ref_center,ref_id,max(id) AS JournalID
        FROM 
                journalentries 
        WHERE 
                jetype = 18
        GROUP BY 
                person_center,person_id,ref_center,ref_id) jeMAX
        ON jeMAX.person_center = s.owner_center
        AND jeMAX.person_id = s.owner_id
        AND jeMAX.ref_center = s.center
        AND jeMAX.ref_id = s.id
JOIN 
        journalentries je
        ON jeMAX.JournalID = je.id
JOIN 
        centers c
        ON c.id = p.center
LEFT JOIN
        person_ext_attrs peaMOBILE
        ON peaMOBILE.personcenter = p.center
        AND peaMOBILE.personid = p.id
        AND peaMOBILE.name = '_eClub_PhoneSMS'
LEFT JOIN
        person_ext_attrs peaEMAIL
        ON peaEMAIL.personcenter = p.center
        AND peaEMAIL.personid = p.id
        AND peaEMAIL.name = '_eClub_Email' 
JOIN 
        products prod 
        ON prod.center = s.subscriptiontype_center 
        AND prod.id = s.subscriptiontype_id
JOIN
        fernwood.product_and_product_group_link pgl
        ON pgl.product_center = prod.center
        AND pgl.product_id = prod.id
        AND pgl.product_group_id = 5601        
LEFT JOIN
        (SELECT 
                Max(Subid) as maxid,center,id,questionnaire_campaign_id 
        FROM 
                questionnaire_answer
        WHERE 
                questionnaire_campaign_id = 1401 
        GROUP BY 
                center
                ,id
                ,questionnaire_campaign_id
        )q
        ON q.center = p.center
        AND q.id = p.id
LEFT JOIN 
        answers
        ON answers.center = q.center
        AND answers.id = q.id
        AND answers.subid = q.maxid
LEFT JOIN
        (
        SELECT
            p.center
            ,p.id
            ,TO_CHAR(longtodatetz(che.CHECKIN_TIME, cen.time_zone),'yyyy-MM-dd') AS "lastattend"
        FROM
            persons p
        JOIN
            checkins che
        ON
            che.id =
            (
                SELECT
                    id
                FROM
                    checkins c
                WHERE
                    c.person_center = p.center
                AND c.person_id = p.id
                AND c.checkin_result = 1
                ORDER BY
                    checkin_time DESC LIMIT 1 ) 
        JOIN
            centers cen
        ON
            cen.id = che.CHECKIN_CENTER 
        )lastattend
        ON lastattend.center = p.center
        AND lastattend.id = p.id 
LEFT JOIN
        (
        SELECT
                p.center
                ,p.id
                ,COUNT(che.CHECKIN_TIME) AS "totalcount"
        FROM
                persons p
        JOIN
                checkins che
                ON che.person_center = p.center
                AND che.person_id = p.id
                AND che.checkin_result = 1
        GROUP BY
                p.center
                ,p.id   
        )totalcount
        ON totalcount.center = p.center
        AND totalcount.id = p.id                                                 
JOIN
        params
        ON params.center_id = s.center                 
WHERE 
        s.end_date is not null
        AND 
        je.creation_time BETWEEN params.FromDate AND params.ToDate
        AND 
        p.center in (:SCOPE)
     