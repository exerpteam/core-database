CREATE TABLE 
    document_set_to_question_cmpgn 
    ( 
        documentation_setting_id int4 NOT NULL, 
        questionnaire_campaign_id int4 NOT NULL, 
        PRIMARY KEY (documentation_setting_id, questionnaire_campaign_id), 
        CONSTRAINT docset_questioncmp_docset_fk FOREIGN KEY (documentation_setting_id) REFERENCES 
        "exerp"."documentation_settings" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT docset_questioncmp_quecmp_fk FOREIGN KEY (questionnaire_campaign_id) REFERENCES 
    "exerp"."questionnaire_campaigns" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
