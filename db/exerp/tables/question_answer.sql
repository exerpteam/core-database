CREATE TABLE 
    question_answer 
    ( 
        id int4 NOT NULL, 
        answer_center int4 NOT NULL, 
        answer_id int4 NOT NULL, 
        answer_subid int4 NOT NULL, 
        question_id int4 NOT NULL, 
        text_answer text(2147483647), 
        number_answer int4, 
        encrypted_number_answer text(2147483647), 
        encrypted_text_answer   text(2147483647), 
        encryption_time int8, 
        PRIMARY KEY (id), 
        CONSTRAINT qa_qans_fk FOREIGN KEY (answer_center, answer_id, answer_subid) REFERENCES 
        "exerp"."questionnaire_answer" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
