CREATE TABLE 
    questionnaire_campaigns 
    ( 
        id int4 NOT NULL, 
        questionnaire int4, 
        name text(2147483647) NOT NULL, 
        required bool DEFAULT FALSE NOT NULL, 
        startdate DATE NOT NULL, 
        stopdate  DATE NOT NULL, 
        type int4, 
        scope_type text(2147483647), 
        scope_id int4, 
        rank int4, 
        viewresultrole int4, 
        source_id int4, 
        document_template_id int4, 
        validity_period_value int4, 
        validity_period_unit int4, 
        PRIMARY KEY (id), 
        CONSTRAINT questcamp_to_quest_fk FOREIGN KEY (questionnaire) REFERENCES 
        "exerp"."questionnaires" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT questcamp_to_emprole_fk FOREIGN KEY (viewresultrole) REFERENCES "exerp"."roles" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
