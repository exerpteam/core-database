CREATE TABLE 
    documentation_settings 
    ( 
        id int4 NOT NULL, 
        definition_key int4, 
        scope_type VARCHAR(1) NOT NULL, 
        scope_id int4 NOT NULL, 
        STATE        VARCHAR(10), 
        availability VARCHAR(2000), 
        name         VARCHAR(50), 
        override_name bool NOT NULL, 
        external_id VARCHAR(200), 
        override_external_id bool NOT NULL, 
        type VARCHAR(20), 
        override_cust_journ_doc_types bool NOT NULL, 
        contract_template_id int4, 
        override_contract_template bool DEFAULT FALSE NOT NULL, 
        override_questionnaire_campgns bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT document_set_to_template_fk FOREIGN KEY (contract_template_id) REFERENCES 
        "exerp"."templates" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );
