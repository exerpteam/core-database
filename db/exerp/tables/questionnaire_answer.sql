CREATE TABLE 
    questionnaire_answer 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        questionnaire_campaign_id int4, 
        log_time int8 NOT NULL, 
        completed bool NOT NULL, 
        result_code VARCHAR(2000) DEFAULT 'NULL::character varying', 
        status      VARCHAR(50) DEFAULT 'NULL::character varying' NOT NULL, 
        journal_entry_id int4, 
        expiration_date DATE, 
        replaced_by_center int4, 
        replaced_by_id int4, 
        replaced_by_subid int4, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT persons FOREIGN KEY (center, id) REFERENCES "exerp"."persons" ("center", "id") 
        ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT q_answer_replaced_by FOREIGN KEY (replaced_by_center, replaced_by_id, 
    replaced_by_subid) REFERENCES "exerp"."questionnaire_answer" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT questionnaire_campaign_id FOREIGN KEY (questionnaire_campaign_id) REFERENCES 
    "exerp"."questionnaire_campaigns" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
